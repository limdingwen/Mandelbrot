#include <SDL2/SDL.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <pthread.h>
#include <sysexits.h>
#include <math.h>
#include <assert.h>

#define MAX_TITLE_LENGTH 256 
#define WINDOW_WIDTH 900
#define WINDOW_HEIGHT 600
#define PIXELS_SIZE (WINDOW_WIDTH * WINDOW_HEIGHT * 4)
#define THREADS 8
#define SHOW_X_INTERVAL 5
#define THREAD_X_SIZE 225

#define PREVIEW_WIDTH 240
#define PREVIEW_HEIGHT 160
#define PREVIEW_X_SIZE 30
#define SHOW_PREVIEW_WHEN_RENDERING 1

struct thread_block
{
    int x_start;
    int x_end;
    int y_start;
    int y_end;
};

const struct thread_block thread_blocks[THREADS] =
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

#define GRADIENT_STOP_COUNT 4
#define GRADIENT_ITERATION_SIZE 64 // Use 2^x for best performance

struct color
{
    float r;
    float g;
    float b;
};

const struct color gradient_stops[GRADIENT_STOP_COUNT + 1] =
{
    { 0, 0, 255 },
    { 255, 255, 0 },
    { 0, 255, 0 },
    { 255, 0, 0 },
    { 0, 0, 255 }, // For looping
};

#define ITERATIONS_M 2
#define ITERATIONS_C 16

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

struct gradient
{
    int stop_count;
    int size;
    const struct color *stops;
};

struct color gradient_color(struct gradient gradient, int x)
{
    x %= gradient.size;
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

struct fp4
{
    enum sign sign;
    uint64_t man[4];
};

struct fp8
{
    enum sign sign;
    uint64_t man[8];
};

struct fp4 fp_uadd4(struct fp4 a, struct fp4 b)
{
    struct fp4 c;
    asm("ADDS %3, %7, %11\n"
        "ADCS %2, %6, %10\n"
        "ADCS %1, %5, %9\n"
        "ADCS %0, %4, %8"
        :
        "=&r"(c.man[0]), // 0
        "=&r"(c.man[1]), // 1
        "=&r"(c.man[2]), // 2
        "=&r"(c.man[3])  // 3
        :
        "r"  (a.man[0]), // 4
        "r"  (a.man[1]), // 5
        "r"  (a.man[2]), // 6
        "r"  (a.man[3]), // 7
        "r"  (b.man[0]), // 8
        "r"  (b.man[1]), // 9
        "r"  (b.man[2]), // 10
        "r"  (b.man[3])  // 11
        :
        "cc");
    return c;
}

struct fp8 fp_uadd8(struct fp8 a, struct fp8 b)
{
    struct fp8 c;
    asm("ADDS %7, %15, %23\n"
        "ADCS %6, %14, %22\n"
        "ADCS %5, %13, %21\n"
        "ADCS %4, %12, %20\n"
        "ADCS %3, %11, %19\n"
        "ADCS %2, %10, %18\n"
        "ADCS %1, %9, %17\n"
        "ADCS %0, %8, %16"
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

struct fp4 fp_smul4(struct fp4 a, struct fp4 b)
{
    if (a.sign == SIGN_ZERO || b.sign == SIGN_ZERO)
        return (struct fp4) { SIGN_ZERO, {0} };

    enum sign sign;
    if (a.sign == SIGN_NEG && b.sign == SIGN_NEG)
        sign = SIGN_POS;
    else if (a.sign == SIGN_NEG || b.sign == SIGN_NEG)
        sign = SIGN_NEG;
    else
        sign = SIGN_POS;

    struct fp8 c = {0};
    for (int i = 3; i >= 0; i--) // a
    {
        for (int j = 3; j >= 0; j--) // b
        {
            int low_offset = 7 - (3 - i) - (3 - j);
            assert(low_offset >= 1);
            int high_offset = low_offset - 1;

            __uint128_t mult = (__uint128_t)a.man[i] * (__uint128_t)b.man[j];
            struct fp8 temp = {0};
            temp.man[low_offset] = (uint64_t)mult;
            temp.man[high_offset] = mult >> 64;

            for (int k = 0; k < 8; k++)
                printf("%llx ", temp.man[k]);
            puts("");

            c = fp_uadd8(c, temp);
        }
    }

    struct fp4 c4;
    c4.sign = sign;
    memcpy(c4.man, c.man + 1, 4 * sizeof(uint64_t));

    return c4;
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
    int iterations;
    uint8_t *pixels;
};

double calculateMathPos(int screenPos, int screenWidth, double size, double center)
{
    double offset = center - size/2;
    return (double)screenPos/(double)screenWidth*size + offset;
}

struct mb_result process_mandelbrot(double math_x, double math_y, int iterations)
{
    struct complex c = { math_x, math_y };
    struct complex z = { 0, 0 };
    for (int i = 0; i < iterations; i++)
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

                color = gradient_color(gradient, result.escape_iterations);
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
    // Test bigfloat

    struct fp4 a = { SIGN_NEG, { 2, 0xC000000000000000, 0, 0 } };
    struct fp4 b = { SIGN_POS, { 5, 0x2000000000000000, 0, 0 } };
    struct fp4 c = fp_smul4(a, b);
    printf("c = ");
    if (c.sign == SIGN_NEG) printf("- ");
    for (int i = 0; i < 4; i++)
        printf("%llx ", c.man[i]);
    puts("");

    return 0;

/*
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

        double iterations_x = -log10(size);
        if (iterations_x < 0) iterations_x = 0;
        double iterations_graph = ITERATIONS_M * iterations_x + ITERATIONS_C;
        int iterations = (int)(iterations_graph * iterations_graph);

        char title_str[MAX_TITLE_LENGTH];
        snprintf(title_str, MAX_TITLE_LENGTH, "X: %.17g, Y: %.17g, Size: %.17g, Iterations: %d", center_x, center_y, size, iterations);
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
                                iterations,
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
                        iterations,
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

    cleanup:
    puts("Quitting...");
    free(stored_pixels);
    SDL_DestroyTexture(preview_texture);
    SDL_DestroyTexture(full_texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return exit_code;
*/
}