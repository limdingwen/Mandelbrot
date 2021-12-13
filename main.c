// INTRODUCTION
//
// Welcome to Mandelbrot, with big floats. This is a work in progress, so in the
// meantime, here's a TODO list of things I still need to do.
//
// TODO: Better colouring
// TODO: Better iteration calculation
// TODO: Optimise
// TODO: Make movie
// And of course, TODO: Make video.
//
// DEPENDENCIES
// We depend on SDL2 and SDL2_image, both of which was downloaded from Homebrew
// on the author's machine. Aside from that, we only depend on the stdlib,
// as well as POSIX threads. C11 threads were not available on the author's Mac.

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <pthread.h>
#include <math.h>
#include <assert.h>

// RENDERING CONFIGURATION
//
// This version of the program has two modes; preview and full-sized rendering.
// Both modes are nearly identical except for the resolution in which they are
// rendered at. In an earlier version of this program, the preview mode was able
// to run at 60fps, navigatable by keyboard. However, ever since the switch from
// doubles to big floats, the program does not run fast enough to enjoy that
// level of interactivity. As such, both modes operate on click-to-zoom.
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

#define WINDOW_WIDTH_RECIPROCAL (struct fp256){ SIGN_POS,   { 0, 0x0048d159e26af37c, 0x048d159e26af37c0, 0x48d159e26af37c04 } }
#define WINDOW_HEIGHT_RECIPROCAL (struct fp256){ SIGN_POS,  { 0, 0x006d3a06d3a06d3a, 0x06d3a06d3a06d3a0, 0x6d3a06d3a06d3a06 } }

// This defines how many columns of pixels we draw before presenting a frame
// to the user. Doing this after too little columns results in slower rendering.

#define FULL_SHOW_X_INTERVAL 5

// We are going to render multicore, and the simplest way to do so is to divide
// up fixed blocks of pixels for each core to render.

#define THREADS 8

struct thread_block
{
    int x_start;
    int x_end;
    int y_start;
    int y_end;
};

const struct thread_block full_thread_blocks[THREADS] =
{
    { 0, 224, 0, 299 },
    { 225, 449, 0, 299 },
    { 450, 674, 0, 299 },
    { 675, 899, 0, 299 },
    { 0, 224, 300, 599 },
    { 225, 449, 300, 599 },
    { 450, 674, 300, 599 },
    { 675, 899, 300, 599 },
};

// Since this is multicore, the program must be able to know how many columns
// it should render for each block; it can't just loop through the entire
// window.

#define FULL_THREAD_X_SIZE 225

// When switching from preview to full-mode rendering, the user might want to
// see a black screen so the progress of the render might be easier to see,
// or they might want to see the preview behind the partly-done full-mode render
// so the image progressively looks clearer.

#define SHOW_PREVIEW_WHEN_RENDERING 1

// Next, we define the same rendering settings, but for the preview mode. The
// preview mode differs in that it is much smaller and faster to render, but
// is almost identical in every other way.

#define PREVIEW_WIDTH 240
#define PREVIEW_HEIGHT 160
#define PREVIEW_WIDTH_RECIPROCAL (struct fp256){ SIGN_POS,  { 0, 0x0111111111111111, 0x1111111111111111, 0x1111111111111111 } }
#define PREVIEW_HEIGHT_RECIPROCAL (struct fp256){ SIGN_POS, { 0, 0x0199999999999999, 0x9999999999999999, 0x9999999999999999 } }
#define PREVIEW_SHOW_X_INTERVAL 5
#define PREVIEW_THREAD_X_SIZE 60

const struct thread_block preview_thread_blocks[THREADS] =
{
    { 0, 59, 0, 79 },
    { 60, 119, 0, 79, },
    { 120, 179, 0, 79 },
    { 180, 239, 0, 79 },
    { 0, 59, 80, 159 },
    { 60, 119, 80, 159, },
    { 120, 179, 80, 159 },
    { 180, 239, 80, 159 },
};

// GRADIENT CONFIGURATION
//
// Next, we'll define the color gradient for all the diverging values of the
// mandelbrot set. The gradient is set to loop for every GRADIENT_ITERATION_SIZE
// number of iterations. Since the program will use modulus to loop the
// gradient, using a power-of-two number hopefully triggers the compiler
// optimiser to use a mask instead. This is important since gradient is
// calculated for every pixel on the screen.

#define GRADIENT_ITERATION_SIZE 64 // Use 2^x for best performance

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
    { 0x44, 0x44, 0xFF },
    { 0x44, 0xFF, 0x44 },
    { 0xFF, 0xFF, 0x44 },
    { 0xFF, 0x44, 0x44 },
    { 0x44, 0x44, 0xFF }, // For looping
};

// OTHER CONFIGURATION
//
// First, the initial center and size of the view. Size represents the length
// of the visible Y axis, while the X axis may be derived by multiplying by
// SIZE_RATIO_X. This ratio may be derived using WINDOW_WIDTH / WINDOW_HEIGHT.

#define INITIAL_CENTER_X (struct fp256){ SIGN_NEG, { 0, 0x8000000000000000, 0, 0 } } // -0.5
#define INITIAL_CENTER_Y (struct fp256){ SIGN_ZERO, {0} } // 0
#define INITIAL_SIZE (struct fp256){ SIGN_POS, { 2, 0, 0, 0 }} // 2
#define SIZE_RATIO_X (struct fp256){ SIGN_POS, { 1, 0x8000000000000000, 0, 0 } } // 1.5

// The program uses a click-to-zoom mechanic, and thus we need to show the user
// an image so the user knows where they will be zooming into. As with all
// resources, the image may be found in the same folder as the executable.

#define ZOOM_IMAGE_PATH "zoom.png"

// Here, we may configure how much zoom we want to apply per click; it shall be
// calculated as size *= ZOOM when zooming in, and size /= ZOOM when zooming
// out. For instance, a zoom of 0.25 will zoom the user in by 4x every click.
// The zoom should divide WINDOW_WIDTH and WINDOW_HEIGHT, as we shall soon see.

#define ZOOM (struct fp256){ SIGN_POS, { 0, 0x4000000000000000, 0, 0 } } // 0.25
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

// BigFloat

enum sign
{
    SIGN_NEG,
    SIGN_ZERO,
    SIGN_POS
};

struct fp256
{
    enum sign sign;
    uint64_t man[4];
};

struct fp512
{
    enum sign sign;
    uint64_t man[8];
};

#define DEF_FP_UADDSUB256(name, op, opc) struct fp256 fp_u##name##256(struct fp256 a, struct fp256 b) \
{ \
    struct fp256 c; \
    asm(#op  "S %3, %7, %11\n" \
        #opc "S %2, %6, %10\n" \
        #opc "S %1, %5, %9\n" \
        #opc "  %0, %4, %8" \
        : \
        "=&r"(c.man[0]), /* 0 */ \
        "=&r"(c.man[1]), /* 1 */ \
        "=&r"(c.man[2]), /* 2 */ \
        "=&r"(c.man[3])  /* 3 */ \
        : \
        "r"  (a.man[0]), /* 4 */ \
        "r"  (a.man[1]), /* 5 */ \
        "r"  (a.man[2]), /* 6 */ \
        "r"  (a.man[3]), /* 7 */ \
        "r"  (b.man[0]), /* 8 */ \
        "r"  (b.man[1]), /* 9 */ \
        "r"  (b.man[2]), /* 10 */ \
        "r"  (b.man[3])  /* 11 */ \
        : \
        "cc"); \
    return c; \
}
DEF_FP_UADDSUB256(add, ADD, ADC);
// Note: a > b must be true if using sub, except if for comparing.
DEF_FP_UADDSUB256(sub, SUB, SBC);
#undef DEF_FP_UADDSUB256

struct fp512 fp_uadd512(struct fp512 a, struct fp512 b)
{
    struct fp512 c;
    asm("ADDS %7, %15, %23\n"
        "ADCS %6, %14, %22\n"
        "ADCS %5, %13, %21\n"
        "ADCS %4, %12, %20\n"
        "ADCS %3, %11, %19\n"
        "ADCS %2, %10, %18\n"
        "ADCS %1, %9, %17\n"
        "ADC  %0, %8, %16"
        :
        "=&r"(c.man[0]), // 0
        "=&r"(c.man[1]), // 1
        "=&r"(c.man[2]), // 2
        "=&r"(c.man[3]), // 3
        "=&r"(c.man[4]), // 4
        "=&r"(c.man[5]), // 5
        "=&r"(c.man[6]), // 6
        "=&r"(c.man[7])  // 7
        :
        "r"  (a.man[0]), // 8
        "r"  (a.man[1]), // 9
        "r"  (a.man[2]), // 10
        "r"  (a.man[3]), // 11
        "r"  (a.man[4]), // 12
        "r"  (a.man[5]), // 13
        "r"  (a.man[6]), // 14
        "r"  (a.man[7]), // 15
        "r"  (b.man[0]), // 16
        "r"  (b.man[1]), // 17
        "r"  (b.man[2]), // 18
        "r"  (b.man[3]), // 19
        "r"  (b.man[4]), // 20
        "r"  (b.man[5]), // 21
        "r"  (b.man[6]), // 22
        "r"  (b.man[7])  // 23
        :
        "cc");
    return c;
}

enum cmp
{
    CMP_SAME,
    CMP_A_BIG,
    CMP_B_BIG
};

enum cmp fp_ucmp256(struct fp256 a, struct fp256 b)
{
    static const uint64_t zero[4]; // static is 0 by default
    struct fp256 c = fp_usub256(a, b);
    bool is_negative = (c.man[0] >> 63) == 1;
    if (is_negative)
        return CMP_B_BIG;
    else
        if (memcmp(c.man, zero, 4 * sizeof(uint64_t)) == 0)
            return CMP_SAME;
        else
            return CMP_A_BIG;
}

struct fp256 fp_sadd256(struct fp256 a, struct fp256 b)
{
    if (a.sign == SIGN_ZERO && b.sign == SIGN_ZERO)
        return a;
    if (b.sign == SIGN_ZERO)
        return a;
    if (a.sign == SIGN_ZERO)
        return b;
    if ((a.sign == SIGN_POS && b.sign == SIGN_POS) ||
        (a.sign == SIGN_NEG && b.sign == SIGN_NEG))
    {
        struct fp256 c = fp_uadd256(a, b);
        c.sign = a.sign;
        return c;
    }

    assert((a.sign == SIGN_POS && b.sign == SIGN_NEG) ||
           (a.sign == SIGN_NEG && b.sign == SIGN_POS));
    enum cmp cmp = fp_ucmp256(a, b);
    if (cmp == CMP_SAME)
        return (struct fp256) { SIGN_ZERO, {0} };
    
    if (a.sign == SIGN_POS && b.sign == SIGN_NEG)
    {
        if (cmp == CMP_A_BIG)
        {
            struct fp256 c = fp_usub256(a, b);
            c.sign = SIGN_POS;
            return c;
        }
        else
        {
            struct fp256 c = fp_usub256(b, a);
            c.sign = SIGN_NEG;
            return c;
        }
    }
    else
    {
        if (cmp == CMP_A_BIG)
        {
            struct fp256 c = fp_usub256(a, b);
            c.sign = SIGN_NEG;
            return c;
        }
        else
        {
            struct fp256 c = fp_usub256(b, a);
            c.sign = SIGN_POS;
            return c;
        }
    }
}

struct fp256 fp_sinv256(struct fp256 a)
{
    if (a.sign == SIGN_POS) a.sign = SIGN_NEG;
    else if (a.sign == SIGN_NEG) a.sign = SIGN_POS;
    return a;
}

struct fp256 fp_ssub256(struct fp256 a, struct fp256 b)
{
    return fp_sadd256(a, fp_sinv256(b));
}

struct fp256 fp_smul256(struct fp256 a, struct fp256 b)
{
    if (a.sign == SIGN_ZERO || b.sign == SIGN_ZERO)
        return (struct fp256) { SIGN_ZERO, {0} };

    enum sign sign;
    if (a.sign == SIGN_NEG && b.sign == SIGN_NEG)
        sign = SIGN_POS;
    else if (a.sign == SIGN_NEG || b.sign == SIGN_NEG)
        sign = SIGN_NEG;
    else
        sign = SIGN_POS;

    struct fp512 c = {0};
    for (int i = 3; i >= 0; i--) // a
    {
        for (int j = 3; j >= 0; j--) // b
        {
            int low_offset = 7 - (3 - i) - (3 - j);
            assert(low_offset >= 1);
            int high_offset = low_offset - 1;

            __uint128_t mult = (__uint128_t)a.man[i] * (__uint128_t)b.man[j];
            struct fp512 temp = {0};
            temp.man[low_offset] = (uint64_t)mult;
            temp.man[high_offset] = mult >> 64;

            c = fp_uadd512(c, temp);
        }
    }

    struct fp256 c256;
    c256.sign = sign;
    memcpy(c256.man, c.man + 1, 4 * sizeof(uint64_t));

    return c256;
}

struct fp256 fp_ssqr256(struct fp256 a)
{
    return fp_smul256(a, a);
}

struct fp256 fp_asr256(struct fp256 a)
{
    a.man[3] >>= 1;
    a.man[3] |= (a.man[2] & 0x1) << 63;
    a.man[2] >>= 1;
    a.man[2] |= (a.man[1] & 0x1) << 63;
    a.man[1] >>= 1;
    a.man[1] |= (a.man[0] & 0x1) << 63;
    a.man[0] >>= 1;
    return a;
}

struct fp256 int_to_fp256(int a)
{
    if (a == 0)
        return (struct fp256){ SIGN_ZERO, {0} };
    
    struct fp256 b = {0};
    if (a < 0)
    {
        b.sign = SIGN_NEG;
        a = -a;
    }
    else
        b.sign = SIGN_POS;
    
    b.man[0] = (uint64_t)a;
    return b;
}

// Complex

struct complex
{
    struct fp256 x;
    struct fp256 y;
};

struct complex complex_add(struct complex a, struct complex b)
{
    return (struct complex) { fp_sadd256(a.x, b.x), fp_sadd256(a.y, b.y) };
}

struct complex complex_mul(struct complex a, struct complex b)
{
    return (struct complex)
    {
        fp_ssub256(fp_smul256(a.x, b.x), fp_smul256(a.y, b.y)),
        fp_sadd256(fp_smul256(a.x, b.y), fp_smul256(b.x, a.y))
    };
}

struct complex complex_sqr(struct complex a)
{
    return complex_mul(a, a);
}

// Only returns the whole number part
uint64_t complex_sqrmag_whole(struct complex a)
{
    struct fp256 c = fp_sadd256(fp_ssqr256(a.x), fp_ssqr256(a.y));
    return c.man[0];
}

// Thread

struct fp256 calculateMathPos(int screen_pos, struct fp256 width_reciprocal, struct fp256 size, struct fp256 center)
{
    struct fp256 offset = fp_ssub256(center, fp_asr256(size));
    return fp_sadd256(fp_smul256(fp_smul256(int_to_fp256(screen_pos), width_reciprocal), size), offset);
}

struct mb_result
{
    bool is_in_set;
    unsigned long long escape_iterations;
};

struct mb_result process_mandelbrot(struct fp256 math_x, struct fp256 math_y, unsigned long long iterations)
{
    struct complex c = { math_x, math_y };
    struct complex z = { { SIGN_ZERO, {0} }, { SIGN_ZERO, {0} } };
    for (unsigned long long i = 0; i < iterations; i++)
    {
        z = complex_add(complex_sqr(z), c);
        if (complex_sqrmag_whole(z) >= 4) // sqr(2), where 2 is "radius of escape"
            return (struct mb_result) { false, i };
    }
    return (struct mb_result) { true, -1ULL };
}

struct thread_data
{
    int x_start;
    int x_end;
    int y_start;
    int y_end;
    int width;
    int height;
    struct fp256 width_reciprocal;
    struct fp256 height_reciprocal;
    struct fp256 size;
    struct fp256 center_x;
    struct fp256 center_y;
    unsigned long long iterations;
    uint8_t *pixels;
};

void *thread(void *arg)
{
    struct thread_data *data = (struct thread_data*)arg;
    struct fp256 size_x = fp_smul256(data->size, SIZE_RATIO_X);

    for (int screen_x = data->x_start; screen_x <= data->x_end; screen_x++)
    {
        struct fp256 math_x = calculateMathPos(screen_x, data->width_reciprocal, size_x, data->center_x);

        for (int screen_y = data->y_start; screen_y <= data->y_end; screen_y++)
        {
            struct fp256 math_y = calculateMathPos(data->height - screen_y, data->height_reciprocal, data->size, data->center_y);
            struct mb_result result = process_mandelbrot(math_x, math_y, data->iterations);

            struct color color;
            if (result.is_in_set)
                color = (struct color){ 0, 0, 0 };
            else
            {
                const static struct gradient gradient =
                {
                    GRADIENT_STOP_COUNT,
                    GRADIENT_ITERATION_SIZE,
                    gradient_stops
                };
                color = gradient_color(gradient, (int)result.escape_iterations); // TODO: If got problems, make this unsigned long long
            }
            
            int r_offset = (screen_y*data->width + screen_x)*4;
            data->pixels[r_offset + 0] = (uint8_t) color.r;
            data->pixels[r_offset + 1] = (uint8_t) color.g;
            data->pixels[r_offset + 2] = (uint8_t) color.b;
            data->pixels[r_offset + 3] = 255;
        }
    }

    pthread_exit(NULL);
}

int main()
{
    int err;
    int exit_code = EXIT_SUCCESS;

    // Start SDL

    uint8_t *full_stored_pixels = NULL, *preview_stored_pixels = NULL;
    SDL_Renderer *renderer = NULL;
    SDL_Window *window = NULL;
    SDL_Texture *full_texture = NULL, *preview_texture = NULL, *zoom_image = NULL;

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
    unsigned long long iterations = 64;
    unsigned long long zoom = 1;

    static const int full_pixels_size = WINDOW_WIDTH * WINDOW_HEIGHT * 4;
    static const int preview_pixels_size = PREVIEW_WIDTH * PREVIEW_HEIGHT * 4;

    full_stored_pixels = calloc(1, full_pixels_size * sizeof(uint8_t));
    preview_stored_pixels = calloc(1, preview_pixels_size * sizeof(uint8_t));
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
                            zoom = 1;
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
                        iterations *= 2; // TODO: Less hardcoded
                        zoom *= 4;
                        printf("Zoom: %llu\n", zoom);
                        memset(full_stored_pixels, 0, full_pixels_size);
                        memset(preview_stored_pixels, 0, preview_pixels_size);
                    }
                    else if (event.button.button == SDL_BUTTON_RIGHT)
                    {
                        haveToRender = true;
                        size = fp_smul256(size, ZOOM_RECIPROCAL);
                        iterations /= 2;
                        zoom /= 4;
                        printf("Zoom: %llu\n", zoom);
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

            int thread_x_size;
            int show_x_interval;
            const struct thread_block *thread_blocks;
            int width;
            int height;
            struct fp256 width_reciprocal;
            struct fp256 height_reciprocal;
            uint8_t *stored_pixels;

            if (state == STATE_PREVIEW)
            {
                thread_x_size =  PREVIEW_THREAD_X_SIZE;
                show_x_interval = PREVIEW_SHOW_X_INTERVAL;
                thread_blocks = preview_thread_blocks;
                width = PREVIEW_WIDTH;
                height = PREVIEW_HEIGHT;
                width_reciprocal = PREVIEW_WIDTH_RECIPROCAL;
                height_reciprocal = PREVIEW_HEIGHT_RECIPROCAL;
                stored_pixels = preview_stored_pixels;
            }
            else if (state == STATE_FULL)
            {
                thread_x_size =  FULL_THREAD_X_SIZE;
                show_x_interval = FULL_SHOW_X_INTERVAL;
                thread_blocks = full_thread_blocks;
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
            
            for (int x = 0; x < thread_x_size; x += show_x_interval)
            {
                pthread_t thread_ids[THREADS];
                struct thread_data thread_datas[THREADS];
                for (int i = 0; i < THREADS; i++)
                {
                    // Quick hack for "bottom blocks reverse X" effect
                    int visual_x = (i < 4) ? x : (thread_x_size - x - show_x_interval);
                    thread_datas[i] = (struct thread_data){
                        thread_blocks[i].x_start + visual_x,
                        thread_blocks[i].x_start + visual_x + show_x_interval - 1,
                        thread_blocks[i].y_start,
                        thread_blocks[i].y_end,
                        width,
                        height,
                        width_reciprocal,
                        height_reciprocal,
                        size,
                        center_x,
                        center_y,
                        iterations,
                        stored_pixels
                    };
                    err = pthread_create(&thread_ids[i], NULL, thread, &thread_datas[i]);
                    if (err != 0)
                    {
                        fprintf(stderr, "Unable to create thread: Error code %d\n", err);
                        exit_code = EXIT_FAILURE;
                        goto cleanup;
                    }
                }

                for (int i = 0; i < THREADS; i++)
                {
                    err = pthread_join(thread_ids[i], NULL);
                    if (err != 0)
                    {
                        fprintf(stderr, "Unable to join thread: Error code %d\n", err);
                        exit_code = EXIT_FAILURE;
                        goto cleanup;
                    }
                }

                // TODO: Error handling
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

    return exit_code;
}