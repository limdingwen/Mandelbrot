// INTRODUCTION
//
// Welcome to Mandelbrot, with big floats. This is a work in progress, so in the
// meantime, here's a TODO list of things I still need to do.
//
// TODO: Better colouring
// TODO: Better iteration calculation
// TODO: Optimise (OpenCL?)
// TODO: Scan-build not working?
// TODO: Make movie
// And of course, TODO: Make video.
//
// This program renders the mandelbrot set, which may be zoomed in via clicking.
// It has two modes; preview and full-sized rendering. Both modes are nearly
// identical except for the resolution in which they are rendered at. A special
// function of this program is that it relies not on single or double precision
// floats, but rather handmade "big floats". These big floats allow for
// abitrarily precise math, but be warned as it is rather slow.
//
// As of writing, the big floats are limited at 256 bits, but may be expanded
// in the future.
//
// I'm currently trying out using GPU for processing, as mandelbrot and other
// fractal programs lends itself very well to parallel computing. We shall use
// OpenCL for that, so let's include it here:

#ifdef __APPLE__
#include <OpenCL/opencl.h>
#else
#include <CL/cl.h>
#endif

// We depend on SDL2 and SDL2_image for rendering and windowing, and C stdlib.

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <assert.h>

// TODO: Document
#define CL_UINT cl_uint
#define CL_ULONG cl_ulong
#include "bigfloat.h"
#undef CL_ULONG
#undef CL_UINT

#include "shared.h"

// RENDERING CONFIGURATION
//
// First, let's define some properties for full-sized rendering. We assume that
// full-size is 1:1 to the window, and thus window size = full-size dimensions.

#define WINDOW_WIDTH 900
#define WINDOW_HEIGHT 600

// Here, we also define reciprocals (1/x) of the width and height, as our big
// float implementation is currently unable to divide; only multiply. We will
// elaborate on the big float implementation later. Currently, this represents
// the raw hexadecimal value of the big float as converting from a decimal
// value is too difficult.

#define WINDOW_WIDTH_RECIPROCAL (struct fp256){ SIGN_POS,   { 0, 0x0048d159, 0xe26af37c, 0x048d159e, 0x26af37c0, 0x48d159e2, 0x6af37c04 } }
#define WINDOW_HEIGHT_RECIPROCAL (struct fp256){ SIGN_POS,  { 0, 0x006d3a06, 0xd3a06d3a, 0x06d3a06d, 0x3a06d3a0, 0x6d3a06d3, 0xa06d3a06 } }

// This defines how many pixels we draw before presenting a frame to the user.
// Making this smaller will result in a smoother animation with more progress
// updates, but in overall slower rendering.
//
// This value will be used as the OpenCL global work size, so make sure that
// this is a multiple of LOCAL_WORK_SIZE. This value does not have to be a
// factor of WINDOW_WIDTH * WINDOW_HEIGHT as we will automatically stop
// calculations that are out of bounds.

#define FULL_SHOW_PIXELS_INTERVAL 32768
#define LOCAL_WORK_SIZE 64

// When switching from preview to full-mode rendering, the user might want to
// see a black screen so the progress of the render might be easier to see,
// or they might want to see the preview behind the partly-done full-mode render
// so the image progressively looks clearer.

#define SHOW_PREVIEW_WHEN_RENDERING 1

// Next, we define the same rendering settings, but for the preview mode. The
// preview mode differs in that it is much smaller and faster to render, but
// is almost identical in every other way.
//
// Do note that PREVIEW_SHOW_PIXELS_INTERVAL also has to be a multiple of
// LOCAL_WORK_SIZE.

#define PREVIEW_WIDTH 240
#define PREVIEW_HEIGHT 160
#define PREVIEW_WIDTH_RECIPROCAL (struct fp256){ SIGN_POS,  { 0, 0x01111111, 0x11111111, 0x11111111, 0x11111111, 0x11111111, 0x11111111 } }
#define PREVIEW_HEIGHT_RECIPROCAL (struct fp256){ SIGN_POS, { 0, 0x01999999, 0x99999999, 0x99999999, 0x99999999, 0x99999999, 0x99999999 } }
#define PREVIEW_SHOW_PIXELS_INTERVAL 16384

// GRADIENT CONFIGURATION
//
// Next, we'll define the color gradient for all the diverging values of the
// mandelbrot set. The gradient is set to loop for every GRADIENT_ITERATION_SIZE
// number of iterations. Since the program will use modulus to loop the
// gradient, using a power-of-two number hopefully triggers the compiler
// optimiser to use a mask instead. This is important since gradient is
// calculated for every pixel on the screen.

#define GRADIENT_ITERATION_SIZE 64

// Next, we define the actual gradient, in 0-255 RGB format. We also duplicate
// the first and last stops, so that it will be easier for the program to loop
// it later on, as you will see.

struct color
{
    float r;
    float g;
    float b;
};

#define GRADIENT_STOP_COUNT 4
const struct color gradient_stops[GRADIENT_STOP_COUNT + 1] =
{
    { 0, 0, 255 },
    { 255, 255, 0 },
    { 0, 255, 0 },
    { 255, 0, 0 },
    { 0, 0, 255 }, // For looping
};

// OTHER CONFIGURATION
//
// First, the initial center and size of the view. Size represents the length
// of the visible Y axis, while the X axis may be derived by multiplying by
// SIZE_RATIO_X. This ratio may be derived using WINDOW_WIDTH / WINDOW_HEIGHT.

#define INITIAL_CENTER_X (struct fp256){ SIGN_NEG, { 0, 0x80000000 } } // -0.5
#define INITIAL_CENTER_Y (struct fp256){ SIGN_ZERO, {0} } // 0
#define INITIAL_SIZE (struct fp256){ SIGN_POS, { 2, 0, 0, 0 }} // 2
#define SIZE_RATIO_X (struct fp256){ SIGN_POS, { 1, 0x80000000 } } // 1.5

// The program uses a click-to-zoom mechanic, and thus we need to show the user
// an image so the user knows where they will be zooming into. As with all
// resources, the image may be found in the same folder as the executable.

#define ZOOM_IMAGE_PATH "zoom.png"

// Here, we may configure how much zoom we want to apply per click; it shall be
// calculated as size *= ZOOM when zooming in, and size /= ZOOM when zooming
// out. For instance, a zoom of 0.25 will zoom the user in by 4x every click.
// The zoom should divide WINDOW_WIDTH and WINDOW_HEIGHT, as we shall soon see.

#define ZOOM (struct fp256){ SIGN_POS, { 0, 0x40000000 } } // 0.25
#define ZOOM_RECIPROCAL (struct fp256){ SIGN_POS, { 4, 0, 0, 0 } }

// Here, we define not the size of the image as seen on disk, but rather how big
// the image should be when rendered on screen. It should be obvious now why
// ZOOM should divide the width and height; it is so that we may have nice
// values for the zoom image, such as WINDOW_WIDTH / 4 and WINDOW_HEIGHT / 4.

#define ZOOM_IMAGE_SIZE_X 225
#define ZOOM_IMAGE_SIZE_Y 150

// Finally, for efficiency sake, we'll use a fixed length for the title string.

#define MAX_TITLE_LENGTH 256 

// GRADIENT IMPLEMENTATION
//
// We have already defined the structure of color in GRADIENT CONFIGURATION,
// as it was needed at the time. Here, we shall define a trivial function for
// lerping between two colors, for the gradient to use. We also clamp x so that
// colors may not end up as more than 255 or less than 0.

struct color color_lerp(struct color a, struct color b, float x)
{
    if (x > 1) x = 1;
    if (x < 0) x = 0;
    return (struct color)
    {
        a.r + (b.r - a.r)*x,
        a.g + (b.g - a.g)*x,
        a.b + (b.b - a.b)*x
    };
}

// We use a gradient struct instead of the configuration seen above so we do not
// tie our implementation to this source file. Rather, any caller may pass in
// any gradient configuration to our function.

struct gradient
{
    int stop_count;
    int size;
    const struct color *stops;
};

// For a particular point on a looping gradient, return a color.

struct color gradient_color(struct gradient gradient, int x)
{

// As said before, first we perform a modulus on x so to make the gradient loop.

    x %= gradient.size;

// 

    int stop_prev = (int)((float)x / (float)gradient.size * (float)gradient.stop_count);
    int stop_next = stop_prev + 1;
    float stop_x = (float)x / (float)gradient.size * (float)gradient.stop_count - (float)stop_prev;
    return color_lerp(gradient.stops[stop_prev], gradient.stops[stop_next], stop_x);
}

// TODO:
#define MAX_KERNEL_SRC_SIZE 0x100000
#define KERNEL_SRC_PATH "main.cl"

int main()
{
    int exit_code = EXIT_SUCCESS;

// We'll declare our free-able variables at the top of the function, so that
// when we jump to cleanup, all of them will have known values, even if the
// initialising code has not been run yet (in which case it'll be NULL).
//
// FIXME: OpenCL does not accept NULL as free targets.

    FILE *kernel_src_fp = NULL;
    char *kernel_src_str = NULL;
    cl_command_queue command_queue = NULL;
    cl_kernel kernel = NULL;
    cl_program program = NULL;
    cl_mem results_mem = NULL;
    cl_context context = NULL;
    cl_ulong *results = NULL;
    uint8_t *full_stored_pixels = NULL, *preview_stored_pixels = NULL;
    SDL_Renderer *renderer = NULL;
    SDL_Window *window = NULL;
    SDL_Texture *full_texture = NULL, *preview_texture = NULL, *zoom_image = NULL;

// OPENCL INITIALISATION
//
// First, read in the entire source file of our OpenCL kernel. We'll use the
// heap to store the kernel source string, as it might be too big for the stack.

    kernel_src_fp = fopen(KERNEL_SRC_PATH, "r");
    if (kernel_src_fp == NULL)
    {
        fputs("Unable to load kernel " KERNEL_SRC_PATH ".", stderr);
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }
    kernel_src_str = malloc(MAX_KERNEL_SRC_SIZE);
    if (kernel_src_str == NULL)
    {
        fputs("Unable to allocate memory for the kernel source code.", stderr);
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }
    size_t kernel_source_size = fread(kernel_src_str, 1, MAX_KERNEL_SRC_SIZE, kernel_src_fp);
    if (kernel_source_size == 0 && ferror(kernel_src_fp))
    {
        fputs("Unable to read the kernel source code.", stderr);
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }

// We need to find out what OpenCL platforms and devices exist, for use
// in later functions. Here, we'll ignore all other platforms and devices,
// assuming that there's only one.

    cl_int cl_err;
    cl_platform_id platform_id;
    cl_err = clGetPlatformIDs(1, &platform_id, NULL);
    if (cl_err != CL_SUCCESS)
    {
        fprintf(stderr, "Unable to get OpenCL platform ID: %d\n", cl_err);
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }

    cl_device_id device_id;
    cl_err = clGetDeviceIDs(platform_id, CL_DEVICE_TYPE_DEFAULT, 1, &device_id, NULL);
    if (cl_err != CL_SUCCESS)
    {
        fprintf(stderr, "Unable to get OpenCL device ID: %d\n", cl_err);
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }

// Some more boilerplate...

    context = clCreateContext(NULL, 1, &device_id, NULL, NULL, &cl_err);
    if (cl_err != CL_SUCCESS)
    {
        fprintf(stderr, "Unable to create OpenCL context: %d\n", cl_err);
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }

    command_queue = clCreateCommandQueue(context, device_id, 0, &cl_err);
    if (cl_err != CL_SUCCESS)
    {
        fprintf(stderr, "Unable to create OpenCL command queue: %d\n", cl_err);
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }

// Next, we'll create a buffer for the GPU to write the mandelbrot results to.
// We'll use the full-sized dimensions as we assume it to be bigger (and thus
// able to hold) than the preview dimensions.
//
// We'll also create a corresponding buffer for the CPU, so we can copy the
// results from the GPU to the CPU later on.

    static const size_t results_size = WINDOW_WIDTH * WINDOW_HEIGHT * sizeof(cl_ulong);
    results_mem = clCreateBuffer(context, CL_MEM_WRITE_ONLY, results_size, NULL, &cl_err);
    if (cl_err != CL_SUCCESS)
    {
        fprintf(stderr, "Unable to create OpenCL results buffer: %d\n", cl_err);
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }

    results = malloc(results_size);
    if (results == NULL)
    {
        fputs("Unable to allocate memory for the results buffer.", stderr);
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }

// Now, compile the source code. There's some weird casting going on here.
// That's because the API can accept multiple source files to compile from, but
// since we only have 1, we can simply cast it into a C array using its address.

    program = clCreateProgramWithSource(context, 1,
        (const char**)&kernel_src_str, (const size_t*)&kernel_source_size, &cl_err);
    if (cl_err != CL_SUCCESS)
    {
        fprintf(stderr, "Unable to create OpenCL program: %d\n", cl_err);
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }

    cl_err = clBuildProgram(program, 1, &device_id, NULL, NULL, NULL);
    if (cl_err != CL_SUCCESS)
    {
        fprintf(stderr, "Unable to build OpenCL program: %d\n", cl_err);
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }

// Finally, we'll create the kernel that we'll call later on to run the
// calculations, and that ends our OpenCL initialisation.

    kernel = clCreateKernel(program, "process_pixel", &cl_err);
    if (cl_err != CL_SUCCESS)
    {
        fprintf(stderr, "Unable to create OpenCL kernel: %d\n", cl_err);
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }
 
    // Start SDL

    if (SDL_Init(SDL_INIT_VIDEO) < 0)
    {
        fprintf(stderr, "Unable to init SDL2: %s\n", SDL_GetError());
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }
    if (SDL_CreateWindowAndRenderer(WINDOW_WIDTH, WINDOW_HEIGHT, 0, &window, &renderer) == -1)
    {
        fprintf(stderr, "Unable to create window and renderer: %s\n", SDL_GetError());
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }
    full_texture = SDL_CreateTexture(renderer,
        SDL_PIXELFORMAT_ABGR8888, SDL_TEXTUREACCESS_STREAMING, WINDOW_WIDTH, WINDOW_HEIGHT);
    if (full_texture == NULL)
    {
        fprintf(stderr, "Unable to create full texture: %s\n", SDL_GetError());
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }
    if (SHOW_PREVIEW_WHEN_RENDERING)
    {
        if (SDL_SetTextureBlendMode(full_texture, SDL_BLENDMODE_BLEND) == -1)
        {
            fputs("Blend blendmode not supported on this platform.", stderr);
            fputs("Preview may not be shown during the render.", stderr);
            fputs("You may wish to disable SHOW_PREVIEW_WHEN_RENDERING.", stderr);
        }
    }
    preview_texture = SDL_CreateTexture(renderer,
        SDL_PIXELFORMAT_ABGR8888, SDL_TEXTUREACCESS_STREAMING, PREVIEW_WIDTH, PREVIEW_HEIGHT);
    if (preview_texture == NULL)
    {
        fprintf(stderr, "Unable to create preview texture: %s\n", SDL_GetError());
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }
    if (IMG_Init(IMG_INIT_PNG) == 0)
    {
        fprintf(stderr, "Unable to initialise SDL2 image: %s\n", IMG_GetError());
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }
    zoom_image = IMG_LoadTexture(renderer, ZOOM_IMAGE_PATH);
    if (zoom_image == NULL)
    {
        fprintf(stderr, "Unable to load zoom image: %s\n", IMG_GetError());
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }
    if (SDL_SetTextureBlendMode(zoom_image, SDL_BLENDMODE_BLEND) == -1)
    {
        fputs("Blend blendmode not supported on this platform.", stderr);
        fputs("Zoom image may not show correctly.", stderr);
    }
    puts("Mandelbrot started.");

    // Main loop
    struct fp256 size = INITIAL_SIZE;
    struct fp256 center_x = INITIAL_CENTER_X;
    struct fp256 center_y = INITIAL_CENTER_Y;
    cl_ulong iterations = 32;

    static const size_t full_pixels_size = WINDOW_WIDTH * WINDOW_HEIGHT * 4 * sizeof(uint8_t);
    static const size_t preview_pixels_size = PREVIEW_WIDTH * PREVIEW_HEIGHT * 4 * sizeof(uint8_t);

    full_stored_pixels = calloc(1, full_pixels_size);
    preview_stored_pixels = calloc(1, preview_pixels_size);
    if (full_stored_pixels == NULL || preview_stored_pixels == NULL)
    {
        fputs("Unable to allocate memory for storing pixels.", stderr);
        exit_code = EXIT_FAILURE;
        goto cleanup;
    }

    enum state
    {
        STATE_PREVIEW,
        STATE_FULL
    };
    enum state state = STATE_PREVIEW;
    bool haveToRender = true;

    bool running = true;
    while (running)
    {
        // FIXME: Mouse lag
        int mouse_x, mouse_y;
        SDL_PumpEvents();
        SDL_GetMouseState(&mouse_x, &mouse_y);
        SDL_Window *window_cursor = SDL_GetMouseFocus();
        bool cursor_in_window = window_cursor != NULL;

        SDL_Event event;
        while (SDL_PollEvent(&event))
        {
            switch (event.type)
            {
                case SDL_QUIT:
                {
                    running = false;
                }
                break;
                
                case SDL_KEYDOWN:
                {
                    switch (event.key.keysym.scancode)
                    {
                        case SDL_SCANCODE_TAB:
                        {
                            state = (state == STATE_FULL) ? STATE_PREVIEW : STATE_FULL;
                        
                            // State init logic

                            haveToRender = true;
                            if (state == STATE_FULL)
                                memset(full_stored_pixels, 0, full_pixels_size);
                            else if (state == STATE_PREVIEW)
                                memset(preview_stored_pixels, 0, preview_pixels_size);
                        }
                        break;

                        case SDL_SCANCODE_H:
                        {
                            haveToRender = true;
                            center_x = INITIAL_CENTER_X;
                            center_y = INITIAL_CENTER_Y;
                            size = INITIAL_SIZE;
                            iterations = 32;
                            // Not doing memset is intended, for the visual effect.
                        }
                        break;

                        default:
                        break;
                    }
                }
                break;

                case SDL_MOUSEBUTTONUP:
                {
                    if (event.button.button == SDL_BUTTON_LEFT)
                    {
                        haveToRender = true;
                        struct fp256 size_x = fp_smul256(size, SIZE_RATIO_X);
                        center_x = calculateMathPos(mouse_x, WINDOW_WIDTH_RECIPROCAL, size_x, center_x);
                        center_y = calculateMathPos(WINDOW_HEIGHT - mouse_y, WINDOW_HEIGHT_RECIPROCAL, size, center_y);
                        size = fp_smul256(size, ZOOM);
                        iterations *= 4; // TODO: Less hardcoded
                        memset(full_stored_pixels, 0, full_pixels_size);
                        memset(preview_stored_pixels, 0, preview_pixels_size);
                    }
                    else if (event.button.button == SDL_BUTTON_RIGHT)
                    {
                        haveToRender = true;
                        size = fp_smul256(size, ZOOM_RECIPROCAL);
                        iterations /= 4;
                        memset(full_stored_pixels, 0, full_pixels_size);
                        memset(preview_stored_pixels, 0, preview_pixels_size);
                    }
                }
                break;

                default:
                break;
            }
        }

        //char title_str[MAX_TITLE_LENGTH];
        //snprintf(title_str, MAX_TITLE_LENGTH, "X: %.17g, Y: %.17g, Size: %.17g, Iterations: %d", center_x, center_y, size, iterations);
        //SDL_SetWindowTitle(window, title_str);

        // Render mandelbrot

        if (haveToRender)
        {
            haveToRender = false;
            uint64_t begin_time = SDL_GetPerformanceCounter();

            long long show_pixels_interval;
            cl_int width;
            cl_int height;
            struct fp256 width_reciprocal;
            struct fp256 height_reciprocal;
            uint8_t *stored_pixels;

            if (state == STATE_PREVIEW)
            {
                show_pixels_interval = PREVIEW_SHOW_PIXELS_INTERVAL;
                width = PREVIEW_WIDTH;
                height = PREVIEW_HEIGHT;
                width_reciprocal = PREVIEW_WIDTH_RECIPROCAL;
                height_reciprocal = PREVIEW_HEIGHT_RECIPROCAL;
                stored_pixels = preview_stored_pixels;
            }
            else if (state == STATE_FULL)
            {
                show_pixels_interval = FULL_SHOW_PIXELS_INTERVAL;
                width = WINDOW_WIDTH;
                height = WINDOW_HEIGHT;
                width_reciprocal = WINDOW_WIDTH_RECIPROCAL;
                height_reciprocal = WINDOW_HEIGHT_RECIPROCAL;
                stored_pixels = full_stored_pixels;
            }
            else
            {
                fputs("Found invalid state when rendering.", stderr);
                exit_code = EXIT_FAILURE;
                goto cleanup;
            }

            struct fp256 size_x = fp_smul256(size, SIZE_RATIO_X);
            
            for (int offset = 0; offset < (width * height); offset += show_pixels_interval)
            {
                cl_err = clSetKernelArg(kernel, 0, sizeof(cl_int), &width);
                cl_err = clSetKernelArg(kernel, 1, sizeof(cl_int), &height);
                cl_err = clSetKernelArg(kernel, 2, sizeof(struct fp256), &width_reciprocal);
                cl_err = clSetKernelArg(kernel, 3, sizeof(struct fp256), &height_reciprocal);
                cl_err = clSetKernelArg(kernel, 4, sizeof(struct fp256), &size);
                cl_err = clSetKernelArg(kernel, 5, sizeof(struct fp256), &size_x);
                cl_err = clSetKernelArg(kernel, 6, sizeof(struct fp256), &center_x);
                cl_err = clSetKernelArg(kernel, 7, sizeof(struct fp256), &center_y);
                cl_err = clSetKernelArg(kernel, 8, sizeof(cl_ulong), &iterations);
                cl_err = clSetKernelArg(kernel, 9, sizeof(cl_mem), &results_mem);

                size_t global_work_offset = (size_t)offset;
                size_t global_work_size = (size_t)show_pixels_interval;
                size_t local_work_size = LOCAL_WORK_SIZE;
                cl_err = clEnqueueNDRangeKernel(command_queue, kernel, 1,
                    &global_work_offset, &global_work_size, &local_work_size,
                    0, NULL, NULL);
                if (cl_err != CL_SUCCESS)
                {
                    fprintf(stderr, "Unable to run the OpenCL kernel: %d\n", cl_err);
                    exit_code = EXIT_FAILURE;
                    goto cleanup;
                }

                printf("Enqueue kernel completed. Time taken: %fms.\n",
                    (float)(SDL_GetPerformanceCounter() - begin_time) / (float)SDL_GetPerformanceFrequency() * 1000);

                clFinish(command_queue);

                printf("Kernel completed. Time taken: %fms.\n",
                    (float)(SDL_GetPerformanceCounter() - begin_time) / (float)SDL_GetPerformanceFrequency() * 1000);

                cl_err = clEnqueueReadBuffer(command_queue, results_mem, CL_TRUE, 0,
                    results_size, results, 0, NULL, NULL);
                if (cl_err != CL_SUCCESS)
                {
                    fprintf(stderr, "Unable to read the OpenCL results buffer: %d\n", cl_err);
                    exit_code = EXIT_FAILURE;
                    goto cleanup;
                }

                printf("Reading buffer completed. Time taken: %fms.\n",
                    (float)(SDL_GetPerformanceCounter() - begin_time) / (float)SDL_GetPerformanceFrequency() * 1000);

                for (int i = offset; i < offset + show_pixels_interval; i++)
                {
                    cl_ulong result = results[i];
                    if (result == (cl_ulong)-1)
                    {
                        stored_pixels[i * 4 + 0] = 0;
                        stored_pixels[i * 4 + 1] = 0;
                        stored_pixels[i * 4 + 2] = 0;
                        stored_pixels[i * 4 + 3] = 255;
                    }
                    else
                    {
                        static const struct gradient gradient =
                        {
                            GRADIENT_STOP_COUNT,
                            GRADIENT_ITERATION_SIZE,
                            gradient_stops
                        };
                        struct color color = gradient_color(gradient,
                            (int)result); // Assume no problem since modding
                        stored_pixels[i * 4 + 0] = (uint8_t)color.r;
                        stored_pixels[i * 4 + 1] = (uint8_t)color.g;
                        stored_pixels[i * 4 + 2] = (uint8_t)color.b;
                        stored_pixels[i * 4 + 3] = 255;
                    }
                }

                printf("Gradient completed. Time taken: %fms.\n",
                    (float)(SDL_GetPerformanceCounter() - begin_time) / (float)SDL_GetPerformanceFrequency() * 1000);

                // TODO: Error handling. Also, is this even needed?
                SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
                SDL_RenderClear(renderer);
                if (state == STATE_PREVIEW || SHOW_PREVIEW_WHEN_RENDERING)
                {
                    uint8_t *pixels;
                    int pitch;
                    if (SDL_LockTexture(preview_texture, NULL, (void**)&pixels, &pitch) < 0)
                    {
                        fprintf(stderr, "Unable to lock preview texture: %s\n", SDL_GetError());
                        exit_code = EXIT_FAILURE;
                        goto cleanup;
                    }
                    memcpy(pixels, preview_stored_pixels, preview_pixels_size);
                    SDL_UnlockTexture(preview_texture);

                    if (SDL_RenderCopy(renderer, preview_texture, NULL, NULL) < 0)
                    {
                        fprintf(stderr, "Unable to copy preview texture: %s\n", SDL_GetError());
                        exit_code = EXIT_FAILURE;
                        goto cleanup;
                    }
                }
                if (state == STATE_FULL)
                {
                    uint8_t *pixels;
                    int pitch;
                    if (SDL_LockTexture(full_texture, NULL, (void**)&pixels, &pitch) < 0)
                    {
                        fprintf(stderr, "Unable to lock full texture: %s\n", SDL_GetError());
                        exit_code = EXIT_FAILURE;
                        goto cleanup;
                    }
                    memcpy(pixels, full_stored_pixels, full_pixels_size);
                    SDL_UnlockTexture(full_texture);

                    if (SDL_RenderCopy(renderer, full_texture, NULL, NULL) < 0)
                    {
                        fprintf(stderr, "Unable to copy full texture: %s\n", SDL_GetError());
                        exit_code = EXIT_FAILURE;
                        goto cleanup;
                    }
                }
                SDL_RenderPresent(renderer);
            }

            uint64_t end_time = SDL_GetPerformanceCounter();
            float time_taken = (float)(end_time - begin_time) / (float)SDL_GetPerformanceFrequency() * 1000;
            printf("%s render completed. Time taken: %fms. Iterations: %llu\n", (state == STATE_PREVIEW) ? "Preview" : "Full", time_taken, iterations);
        }

        if (SDL_RenderCopy(renderer, (state == STATE_PREVIEW) ? preview_texture : full_texture, NULL, NULL) < 0)
        {
            fprintf(stderr, "Unable to copy %s texture: %s\n", (state == STATE_PREVIEW) ? "preview" : "full", SDL_GetError());
            exit_code = EXIT_FAILURE;
            goto cleanup;
        }

        // Show zoom highlight
        if (cursor_in_window)
        {
            SDL_Rect dest_zoom_rect =
            {
                mouse_x - ZOOM_IMAGE_SIZE_X / 2,
                mouse_y - ZOOM_IMAGE_SIZE_Y / 2,
                ZOOM_IMAGE_SIZE_X,
                ZOOM_IMAGE_SIZE_Y
            };
            SDL_RenderCopy(renderer, zoom_image, NULL, &dest_zoom_rect);
        }

        SDL_RenderPresent(renderer);
    }

    cleanup:
    puts("Quitting Mandelbrot...");
    free(preview_stored_pixels);
    free(full_stored_pixels);
    SDL_DestroyTexture(preview_texture);
    SDL_DestroyTexture(full_texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    clFlush(command_queue);
    clFinish(command_queue);
    clReleaseKernel(kernel);
    clReleaseProgram(program);
    clReleaseMemObject(results_mem);
    clReleaseCommandQueue(command_queue);
    clReleaseContext(context);
    fclose(kernel_src_fp);

    return exit_code;
}