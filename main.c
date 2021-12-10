#include <SDL2/SDL.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <pthread.h>
#include <sysexits.h>

// Config

#define MAX_TITLE_LENGTH 128 
#define WINDOW_WIDTH 900
#define WINDOW_HEIGHT 600
#define PIXELS_SIZE (WINDOW_WIDTH * WINDOW_HEIGHT * 4)
#define THREADS 8
#define SHOW_X_INTERVAL 5
#define THREAD_X_SIZE 225

#define PREVIEW_WIDTH 240
#define PREVIEW_HEIGHT 160
#define PREVIEW_X_SIZE 30
#define SHOW_PREVIEW_WHEN_RENDERING 0

struct thread_block
{
    int x_start;
    int x_end;
    int y_start;
    int y_end;
};

struct thread_block thread_blocks[THREADS] = {
    { 0, 224, 0, 299 },
    { 225, 449, 0, 299 },
    { 450, 674, 0, 299 },
    { 675, 899, 0, 299 },
    { 0, 224, 300, 599 },
    { 225, 449, 300, 599 },
    { 450, 674, 300, 599 },
    { 675, 899, 300, 599 },
};

#define INNER_COLOR (struct color){ 255, 255, 0 }
#define OUTER_COLOR (struct color){ 0, 0, 255 }
#define MAX_ITERATIONS 256
#define MAX_COLOR_ITERATIONS MAX_ITERATIONS

#define INITIAL_CENTER_X -0.5f
#define INITIAL_CENTER_Y 0
#define INITIAL_SIZE 2
#define SIZE_RATIO_X 1.5f
#define SIZE_RATIO_Y 1

#define PAN_SPEED 1
#define ZOOM_SPEED 1

enum state
{
    STATE_PREVIEW,
    STATE_FULL
};

// Color

struct color
{
    float r;
    float g;
    float b;
};

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

// Complex

struct complex
{
    double x;
    double y;
};

struct complex complex_add(struct complex a, struct complex b)
{
    return (struct complex) { a.x + b.x, a.y + b.y };
}

struct complex complex_mul(struct complex a, struct complex b)
{
    return (struct complex) { a.x*b.x - a.y*b.y, a.x*b.y + b.x*a.y };
}

struct complex complex_sqr(struct complex a)
{
    return complex_mul(a, a);
}

double complex_sqrmag(struct complex a)
{
    return a.x*a.x + a.y*a.y;
}

struct mb_result
{
    bool is_in_set;
    int escape_iterations;
};

// Thread

struct thread_data
{
    int x_start;
    int x_end;
    int y_start;
    int y_end;
    int width;
    int height;
    double size;
    double center_x;
    double center_y;
    uint8_t *pixels;
};

double calculateMathPos(int screenPos, int screenWidth, double size, double center)
{
    double offset = center - size/2;
    return (double)screenPos/(double)screenWidth*size + offset;
}

struct mb_result process_mandelbrot(double math_x, double math_y)
{
    struct complex c = { math_x, math_y };
    struct complex z = { 0, 0 };
    for (int i = 0; i < MAX_ITERATIONS; i++)
    {
        z = complex_add(complex_sqr(z), c);
        if (complex_sqrmag(z) > 4) // sqr(2), where 2 is "radius of escape"
            return (struct mb_result) { false, i };
    }
    return (struct mb_result) { true, -1 };
}

void *thread(void *arg)
{
    struct thread_data *data = (struct thread_data*)arg;

    for (int screen_x = data->x_start; screen_x <= data->x_end; screen_x++)
    {
        double math_x = calculateMathPos(screen_x, data->width, data->size*SIZE_RATIO_X, data->center_x);

        for (int screen_y = data->y_start; screen_y <= data->y_end; screen_y++)
        {
            double math_y = calculateMathPos(data->height - screen_y, data->height, data->size*SIZE_RATIO_Y, data->center_y);
            struct mb_result result = process_mandelbrot(math_x, math_y);

            struct color color;
            if (result.is_in_set)
                color = (struct color){ 0, 0, 0 };
            else
                color = color_lerp(OUTER_COLOR, INNER_COLOR,
                    (float)result.escape_iterations / MAX_COLOR_ITERATIONS);
            
            int r_offset = (screen_y*data->width + screen_x)*4;
            data->pixels[r_offset + 0] = (uint8_t) color.r;
            data->pixels[r_offset + 1] = (uint8_t) color.g;
            data->pixels[r_offset + 2] = (uint8_t) color.b;
            data->pixels[r_offset + 3] = 255;
        }
    }

    pthread_exit(NULL);
}

// Main

int main()
{
    int err;
    int exit_code = EX_OK;

    // Start SDL

    uint8_t *stored_pixels = NULL;
    SDL_Renderer *renderer = NULL;
    SDL_Window *window = NULL;
    SDL_Texture *full_texture = NULL, *preview_texture = NULL;

    if (SDL_Init(SDL_INIT_VIDEO) < 0)
    {
        fprintf(stderr, "Unable to init SDL: %s\n", SDL_GetError());
        exit_code = EX_OSERR;
        goto cleanup;
    }
    if (SDL_CreateWindowAndRenderer(WINDOW_WIDTH, WINDOW_HEIGHT, 0, &window, &renderer) == -1)
    {
        fprintf(stderr, "Unable to create window and renderer: %s\n", SDL_GetError());
        exit_code = EX_OSERR;
        goto cleanup;
    }
    full_texture = SDL_CreateTexture(renderer,
        SDL_PIXELFORMAT_ABGR8888, SDL_TEXTUREACCESS_STREAMING, WINDOW_WIDTH, WINDOW_HEIGHT);
    if (full_texture == NULL)
    {
        fprintf(stderr, "Unable to create full texture: %s\n", SDL_GetError());
        exit_code = EX_OSERR;
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
        exit_code = EX_OSERR;
        goto cleanup;
    }
    puts("Started.");

    // Main loop

    double size = INITIAL_SIZE;
    double center_x = INITIAL_CENTER_X;
    double center_y = INITIAL_CENTER_Y;

    stored_pixels = calloc(1, PIXELS_SIZE * sizeof(uint8_t));
    if (stored_pixels == NULL)
    {
        fputs("Unable to allocate memory for stored_pixels.", stderr);
        exit_code = EX_OSERR;
        goto cleanup;
    }
    const uint8_t *keys = SDL_GetKeyboardState(NULL);

    bool running = true;
    uint64_t now = SDL_GetPerformanceCounter();
    uint64_t last = 0;
    float dt = 0;

    enum state state = STATE_PREVIEW;
    bool haveToRenderFull = false;

    while (running)
    {
        // Handle events

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
                    if (event.key.keysym.scancode == SDL_SCANCODE_TAB)
                    {
                        state = (state == STATE_FULL) ? STATE_PREVIEW : STATE_FULL;
                    
                        // State init logic

                        if (state == STATE_FULL)
                        {
                            haveToRenderFull = true;
                            memset(stored_pixels, 0, PIXELS_SIZE);
                        }
                    }
                }
                break;
            }
        }

        char title_str[MAX_TITLE_LENGTH];
        snprintf(title_str, MAX_TITLE_LENGTH, "X: %.17g, Y: %.17g, Size: %.17g", center_x, center_y, size);
        SDL_SetWindowTitle(window, title_str);

        switch (state)
        {
            case STATE_FULL:
            {
                // Render mandelbrot

                if (haveToRenderFull)
                {
                    haveToRenderFull = false;
                    uint64_t begin_time = SDL_GetPerformanceCounter();
                    
                    for (int x = 0; x < THREAD_X_SIZE; x += SHOW_X_INTERVAL)
                    {
                        uint8_t *pixels;
                        int pitch;
                        if (SDL_LockTexture(full_texture, NULL, (void**)&pixels, &pitch) < 0)
                        {
                            fprintf(stderr, "Unable to lock full texture: %s\n", SDL_GetError());
                            exit_code = EX_OSERR;
                            goto cleanup;
                        }

                        pthread_t thread_ids[THREADS];
                        struct thread_data thread_datas[THREADS];
                        for (int i = 0; i < THREADS; i++)
                        {
                            // Quick hack for "bottom blocks reverse X" effect
                            int visual_x = (i < 4) ? x : (THREAD_X_SIZE - x - SHOW_X_INTERVAL);
                            thread_datas[i] = (struct thread_data){
                                thread_blocks[i].x_start + visual_x,
                                thread_blocks[i].x_start + visual_x + SHOW_X_INTERVAL - 1,
                                thread_blocks[i].y_start,
                                thread_blocks[i].y_end,
                                WINDOW_WIDTH,
                                WINDOW_HEIGHT,
                                size,
                                center_x,
                                center_y,
                                stored_pixels
                            };
                            err = pthread_create(&thread_ids[i], NULL, thread, &thread_datas[i]);
                            if (err != 0)
                            {
                                fprintf(stderr, "Unable to create thread: Error code %d\n", err);
                                exit_code = EX_OSERR;
                                goto cleanup;
                            }
                        }

                        for (int i = 0; i < THREADS; i++)
                        {
                            err = pthread_join(thread_ids[i], NULL);
                            if (err != 0)
                            {
                                fprintf(stderr, "Unable to join thread: Error code %d\n", err);
                                exit_code = EX_OSERR;
                                goto cleanup;
                            }
                        }

                        memcpy(pixels, stored_pixels, PIXELS_SIZE);
                        SDL_UnlockTexture(full_texture);
                        if (SHOW_PREVIEW_WHEN_RENDERING)
                        {
                            if (SDL_RenderCopy(renderer, preview_texture, NULL, NULL) < 0)
                            {
                                fprintf(stderr, "Unable to copy preview texture: %s\n", SDL_GetError());
                                exit_code = EX_OSERR;
                                goto cleanup;
                            }
                        }
                        if (SDL_RenderCopy(renderer, full_texture, NULL, NULL) < 0)
                        {
                            fprintf(stderr, "Unable to copy full texture: %s\n", SDL_GetError());
                            exit_code = EX_OSERR;
                            goto cleanup;
                        }
                        SDL_RenderPresent(renderer);
                    }

                    uint64_t end_time = SDL_GetPerformanceCounter();
                    float time_taken = (float)(end_time - begin_time) / (float)SDL_GetPerformanceFrequency() * 1000;
                    printf("Full render completed. Time taken: %fms.\n", time_taken);
                }

                if (SDL_RenderCopy(renderer, full_texture, NULL, NULL) < 0)
                {
                    fprintf(stderr, "Unable to copy full texture: %s\n", SDL_GetError());
                    exit_code = EX_OSERR;
                    goto cleanup;
                }
                SDL_RenderPresent(renderer);
            }
            break;

            case STATE_PREVIEW:
            {
                // Handle input

                if (keys[SDL_SCANCODE_W]) center_y += size * PAN_SPEED * dt;
                if (keys[SDL_SCANCODE_A]) center_x -= size * PAN_SPEED * dt;
                if (keys[SDL_SCANCODE_S]) center_y -= size * PAN_SPEED * dt;
                if (keys[SDL_SCANCODE_D]) center_x += size * PAN_SPEED * dt;
                if (keys[SDL_SCANCODE_R]) size -= size * ZOOM_SPEED * dt;
                if (keys[SDL_SCANCODE_F]) size += size * ZOOM_SPEED * dt;

                // Render mandelbrot
                // TODO: Only render when needed

                uint8_t *pixels;
                int pitch;
                if (SDL_LockTexture(preview_texture, NULL, (void**)&pixels, &pitch) < 0)
                {
                    fprintf(stderr, "Unable to lock preview texture: %s\n", SDL_GetError());
                    exit_code = EX_OSERR;
                    goto cleanup;
                }

                pthread_t thread_ids[THREADS];
                struct thread_data thread_datas[THREADS];
                for (int i = 0; i < THREADS; i++)
                {
                    thread_datas[i] = (struct thread_data){
                        PREVIEW_X_SIZE * i,
                        PREVIEW_X_SIZE * (i + 1) - 1,
                        0,
                        PREVIEW_HEIGHT,
                        PREVIEW_WIDTH,
                        PREVIEW_HEIGHT,
                        size,
                        center_x,
                        center_y,
                        pixels
                    };
                    err = pthread_create(&thread_ids[i], NULL, thread, &thread_datas[i]);
                    if (err != 0)
                    {
                        fprintf(stderr, "Unable to create thread: Error code %d\n", err);
                        exit_code = EX_OSERR;
                        goto cleanup;
                    }
                }

                for (int i = 0; i < THREADS; i++)
                {
                    err = pthread_join(thread_ids[i], NULL);
                    if (err != 0)
                    {
                        fprintf(stderr, "Unable to join thread: Error code %d\n", err);
                        exit_code = EX_OSERR;
                        goto cleanup;
                    }
                }

                SDL_UnlockTexture(preview_texture);
                if (SDL_RenderCopy(renderer, preview_texture, NULL, NULL) < 0)
                {
                    fprintf(stderr, "Unable to copy preview texture: %s\n", SDL_GetError());
                    exit_code = EX_OSERR;
                    goto cleanup;
                }
                SDL_RenderPresent(renderer);

                // Calculate dt

                last = now;
                now = SDL_GetPerformanceCounter();
                dt = (float)(now - last) / (float)SDL_GetPerformanceFrequency();
                printf("Preview render completed. Time taken: %fms.\n", dt * 1000);
            }
            break;
        }
    }

    // Clean up memory

    cleanup:
    free(stored_pixels);

    // Quit SDL

    puts("Quitting...");
    SDL_DestroyTexture(preview_texture);
    SDL_DestroyTexture(full_texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return exit_code;
}