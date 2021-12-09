#include <SDL2/SDL.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <pthread.h>
#include <sysexits.h>

// Config

#define WINDOW_WIDTH 900
#define WINDOW_HEIGHT 600
#define PIXELS_SIZE WINDOW_WIDTH*WINDOW_HEIGHT*4
#define SHOW_X_INTERVAL 20
#define THREADS 8

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

#define INITIAL_CENTER_X -0.74529f
#define INITIAL_CENTER_Y 0.113075f
#define INITIAL_SIZE 0.0001f
#define SIZE_RATIO_X 1.5f
#define SIZE_RATIO_Y 1

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
    float x;
    float y;
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

float complex_sqrmag(struct complex a)
{
    return a.x*a.x + a.y*a.y;
}

struct mb_result
{
    bool is_in_set;
    int escape_iterations;
};

// Thread

uint8_t* stored_pixels = NULL;

struct thread_data
{
    int x_start;
    int x_end;
    int y_start;
    int y_end;
    float size;
    float center_x;
    float center_y;
};

float calculateMathPos(float screenPos, float screenWidth, float size, float center)
{
    float offset = center - size/2;
    return screenPos/screenWidth*size + offset;
}

struct mb_result process_mandelbrot(float math_x, float math_y)
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
        float math_x = calculateMathPos((float)screen_x,
            WINDOW_WIDTH, data->size*SIZE_RATIO_X, data->center_x);

        for (int screen_y = data->y_start; screen_y <= data->y_end; screen_y++)
        {
            float math_y = calculateMathPos(WINDOW_HEIGHT - (float)screen_y,
                WINDOW_HEIGHT, data->size*SIZE_RATIO_Y, data->center_y);
            struct mb_result result = process_mandelbrot(math_x, math_y);

            struct color color;
            if (result.is_in_set)
                color = (struct color){ 0, 0, 0 };
            else
                color = color_lerp(OUTER_COLOR, INNER_COLOR,
                    (float)result.escape_iterations / MAX_COLOR_ITERATIONS);
            
            int r_offset = (screen_y*WINDOW_WIDTH + screen_x)*4;
            stored_pixels[r_offset + 0] = (uint8_t) color.r;
            stored_pixels[r_offset + 1] = (uint8_t) color.g;
            stored_pixels[r_offset + 2] = (uint8_t) color.b;
            stored_pixels[r_offset + 3] = 255;
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

    SDL_Renderer *renderer = NULL;
    SDL_Window *window = NULL;
    SDL_Texture *texture = NULL;

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
    texture = SDL_CreateTexture(renderer,
        SDL_PIXELFORMAT_ABGR8888, SDL_TEXTUREACCESS_STREAMING, WINDOW_WIDTH, WINDOW_HEIGHT);
    if (texture == NULL)
    {
        fprintf(stderr, "Unable to create texture: %s\n", SDL_GetError());
        exit_code = EX_OSERR;
        goto cleanup;
    }
    puts("Started.");

    // Main loop

    float size = INITIAL_SIZE;
    float center_x = INITIAL_CENTER_X;
    float center_y = INITIAL_CENTER_Y;

    stored_pixels = calloc(1, PIXELS_SIZE*sizeof(uint8_t));
    if (stored_pixels == NULL)
    {
        fputs("Unable to allocate memory for stored_pixels.", stderr);
        exit_code = EX_OSERR;
        goto cleanup;
    }

    bool running = true;
    bool haveToRender = true;
    while (running)
    {
        // Handle events

        SDL_Event event;
        while (SDL_PollEvent(&event))
        {
            switch (event.type)
            {
                case SDL_QUIT:
                    running = false;
                    break;
            }
        }

        // Render Mandelbrot

        if (haveToRender)
        {
            haveToRender = false;
            uint64_t begin_time = SDL_GetPerformanceCounter();
            
            uint8_t *pixels;
            int pitch;
            if (SDL_LockTexture(texture, NULL, (void**)&pixels, &pitch) < 0)
            {
                fprintf(stderr, "Unable to lock texture: %s\n", SDL_GetError());
                exit_code = EX_OSERR;
                goto cleanup;
            }

            pthread_t thread_ids[THREADS];
            struct thread_data thread_datas[THREADS];
            for (int i = 0; i < THREADS; i++)
            {
                thread_datas[i] = (struct thread_data){
                    thread_blocks[i].x_start,
                    thread_blocks[i].x_end,
                    thread_blocks[i].y_start,
                    thread_blocks[i].y_end,
                    size,
                    center_x,
                    center_y
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
            SDL_UnlockTexture(texture);

            uint64_t end_time = SDL_GetPerformanceCounter();
            float time_taken = (float)(end_time - begin_time) / (float)SDL_GetPerformanceFrequency();
            printf("Time taken: %fs. Waiting for next click.\n", time_taken);
        }

        if (SDL_RenderCopy(renderer, texture, NULL, NULL) < 0)
        {
            fprintf(stderr, "Unable to copy texture: %s\n", SDL_GetError());
            exit_code = EX_OSERR;
            goto cleanup;
        }
        SDL_RenderPresent(renderer);
    }

    // Clean up memory

    cleanup:
    free(stored_pixels);

    // Quit SDL

    puts("Quitting...");
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return exit_code;
}