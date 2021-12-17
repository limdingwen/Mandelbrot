// INTRODUCTION
//
// Hi, welcome to the Metal version of the program. This version is currently
// not documented as it's in alpha.

#include <stdint.h>
#include <stdbool.h>
#include "BigFloat.h"
#include "SDL2/SDL_video.h"
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wconversion"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
#pragma clang diagnostic pop
#include <stdio.h>
#include <math.h>

bool init_metal_compute(int pixels_size);
bool metal_compute_pixels(int width,
                          int height,
                          struct fp256 width_reciprocal,
                          struct fp256 height_reciprocal,
                          struct fp256 size,
                          struct fp256 size_x,
                          struct fp256 center_x,
                          struct fp256 center_y,
                          uint64_t iterations,
                          uint8_t *pixels,
                          int offset,
                          int interval);

#define WINDOW_WIDTH 1920
#define WINDOW_HEIGHT 1080
#define WINDOW_WIDTH_RECIPROCAL  (struct fp256){ SIGN_POS,  { 0, 0x00222222, 0x22222222, 0x22222222, 0x22222222, 0x22222222, 0x22222222 } }
#define WINDOW_HEIGHT_RECIPROCAL (struct fp256){ SIGN_POS,  { 0, 0x003CAE75, 0x9203CAE7, 0x59203CAE, 0x759203CA, 0xE759203C, 0xAE759203 } }
#define FULL_SHOW_X_INTERVAL 10

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
    { 0, 479, 0, 539 },
    { 480, 959, 0, 539 },
    { 960, 1439, 0, 539 },
    { 1440, 1919, 0, 539 },
    { 0, 479, 540, 1079 },
    { 480, 959, 540, 1079 },
    { 960, 1439, 540, 1079 },
    { 1440, 1919, 540, 1079 },
};

#define FULL_THREAD_X_SIZE 480

#define SHOW_PREVIEW_WHEN_RENDERING 1
#define PREVIEW_WIDTH 240
#define PREVIEW_HEIGHT 160
#define PREVIEW_WIDTH_RECIPROCAL (struct fp256){ SIGN_POS,  { 0, 0x01111111, 0x11111111, 0x11111111, 0x11111111, 0x11111111, 0x11111111 } }
#define PREVIEW_HEIGHT_RECIPROCAL (struct fp256){ SIGN_POS, { 0, 0x01999999, 0x99999999, 0x99999999, 0x99999999, 0x99999999, 0x99999999 } }
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

#define GRADIENT_ITERATION_SIZE 16 // Use 2^x for best performance

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

#define INITIAL_CENTER_X (struct fp256){ SIGN_NEG, { 0, 0x80000000 } } // -0.5
#define INITIAL_CENTER_Y (struct fp256){ SIGN_ZERO, {0} } // 0
#define INITIAL_SIZE (struct fp256){ SIGN_POS, { 2, 0, 0, 0 }} // 2
#define SIZE_RATIO_X (struct fp256){ SIGN_POS, { 1, 0xC71C71C7, 0x1C71C71C, 0x71C71C71, 0xC71C71C7, 0x1C71C71C, 0x71C71C71 } } // 1920/1080

#define ZOOM_IMAGE_PATH "zoom.png"
#define ZOOM (struct fp256){ SIGN_POS, { 0, 0x40000000 } } // 0.25
#define ZOOM_RECIPROCAL (struct fp256){ SIGN_POS, { 4, 0, 0, 0 } }
#define ZOOM_IMAGE_SIZE_X 225
#define ZOOM_IMAGE_SIZE_Y 150

#define MOVIE 0
#define MOVIE_FULL_SHOW_X_INTERVAL 160
// Coordinates from "Eye of the Universe"
#define MOVIE_INITIAL_CENTER_X (struct fp256){ SIGN_POS, { 0, 0x5C38B7BB, 0x42D6E499, 0x134BFE57, 0x98655AA0, 0xCB8925EC, 0x9853B954 } }
#define MOVIE_INITIAL_CENTER_Y (struct fp256){ SIGN_NEG, { 0, 0xA42D17BF, 0xC55EFB99, 0x9B8E8100, 0xEB7161E1, 0xCA1080A9, 0xF02EBC2A } }
#define MOVIE_ZOOM_PER_FRAME   (struct fp256){ SIGN_POS, { 0, 0xfa2727db, 0x62aebb76, 0x126ec759, 0x85ae7fe5, 0x1be434c7, 0x706da711 } }
//#define MOVIE_ZOOM_PER_FRAME   (struct fp256){ SIGN_POS, { 0, 0xFD0F413D0D9C5EF1, 0xDBE485CFBA44A80F, 0x30D9409A2D2212AF } } // 0.5 / 60
#define MOVIE_PREFIX "movie/frame"
#define MOVIE_PREFIX_LEN 11
#define MOVIE_INITIAL_FRAME 1724

#define INITIAL_ITERATIONS 64

#define METAL_INTERVAL 691200

// TODO: Make shared
struct fp256 calculateMathPos(int screen_pos, struct fp256 width_reciprocal, struct fp256 size, struct fp256 center)
{
    struct fp256 offset = fp_ssub256(center, fp_asr256(size));
    return fp_sadd256(fp_smul256(fp_smul256(int_to_fp256(screen_pos), width_reciprocal), size), offset);
}

int main()
{
    int err;
    int exit_code = EXIT_SUCCESS;
    
    // Start Metal
    
    init_metal_compute(WINDOW_WIDTH * WINDOW_HEIGHT * 4);

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
    SDL_SetWindowTitle(window, "Mandelbrot: Your CPU is on fire");
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
    struct fp256 center_x = MOVIE ? MOVIE_INITIAL_CENTER_X : INITIAL_CENTER_X;
    struct fp256 center_y = MOVIE ? MOVIE_INITIAL_CENTER_Y : INITIAL_CENTER_Y;
    unsigned long long iterations = INITIAL_ITERATIONS;
    unsigned long long zoom = 0;
    int movie_current_frame = MOVIE_INITIAL_FRAME;

    if (MOVIE)
    {
        for (int i = 0; i < MOVIE_INITIAL_FRAME - 1; i++)
        {
            size = fp_smul256(size, MOVIE_ZOOM_PER_FRAME);
            iterations += 2; // TODO: Iterations setting
            printf("Fast forward to frame %d...\n", i + 2);
        }
    }

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
    enum state state = MOVIE ? STATE_FULL : STATE_PREVIEW;
    bool haveToRender = true;

    bool running = true;
    while (running)
    {
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
                    if (MOVIE)
                        break;
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
                            iterations = INITIAL_ITERATIONS;
                            zoom = 0;
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
                    if (MOVIE)
                        break;
                    if (event.button.button == SDL_BUTTON_LEFT)
                    {
                        haveToRender = true;
                        struct fp256 size_x = fp_smul256(size, SIZE_RATIO_X);
                        center_x = calculateMathPos(mouse_x, WINDOW_WIDTH_RECIPROCAL, size_x, center_x);
                        center_y = calculateMathPos(WINDOW_HEIGHT - mouse_y, WINDOW_HEIGHT_RECIPROCAL, size, center_y);
                        size = fp_smul256(size, ZOOM);
                        iterations += 64; // TODO: Iterations setting
                        zoom++;
                        printf("Zoom: 4^%llu\n", zoom);
                        memset(full_stored_pixels, 0, full_pixels_size);
                        memset(preview_stored_pixels, 0, preview_pixels_size);
                    }
                    else if (event.button.button == SDL_BUTTON_RIGHT)
                    {
                        haveToRender = true;
                        size = fp_smul256(size, ZOOM_RECIPROCAL);
                        iterations -= 64; // TODO: Iterations setting
                        zoom--;
                        printf("Zoom: 4^%llu\n", zoom);
                        memset(full_stored_pixels, 0, full_pixels_size);
                        memset(preview_stored_pixels, 0, preview_pixels_size);
                    }
                }
                break;

                default:
                break;
            }
        }

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

            if (MOVIE)
            {
                show_x_interval = MOVIE_FULL_SHOW_X_INTERVAL;
            }
            
            struct fp256 size_x = fp_smul256(size, SIZE_RATIO_X);
            
            for (int pixel = 0; pixel < width * height; pixel += METAL_INTERVAL)
            {
                metal_compute_pixels(width, height, width_reciprocal, height_reciprocal, size, size_x, center_x, center_y, iterations, stored_pixels, pixel, METAL_INTERVAL);

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

            if (MOVIE)
            {
                static const int movie_path_len = MOVIE_PREFIX_LEN + 4 + 4 + 1;
                char movie_path[movie_path_len]; // + 0001 + .png + \0
                snprintf(movie_path, movie_path_len, MOVIE_PREFIX "%04d.png", movie_current_frame);
                movie_current_frame++;
                if (stbi_write_png(movie_path, WINDOW_WIDTH, WINDOW_HEIGHT, 4, full_stored_pixels, WINDOW_WIDTH * 4) == 0)
                {
                    fprintf(stderr, "Unable to write to frame file for the movie. Continuing just in case...");
                }

                haveToRender = true;
                size = fp_smul256(size, MOVIE_ZOOM_PER_FRAME);
                iterations += 2; // TODO: Iterations setting
                printf("Frame: %d\n", movie_current_frame);
                memset(full_stored_pixels, 0, full_pixels_size);
                memset(preview_stored_pixels, 0, preview_pixels_size);
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
        if (cursor_in_window && !MOVIE)
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
