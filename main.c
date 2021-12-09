#include <SDL2/SDL.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define WINDOW_WIDTH 900
#define WINDOW_HEIGHT 600

#define INNER_COLOR (struct color){ 255, 255, 0 }
#define OUTER_COLOR (struct color){ 0, 0, 255 }
#define MAX_ITERATIONS 128
#define MAX_COLOR_ITERATIONS MAX_ITERATIONS

#define INITIAL_CENTER_X -0.74529f
#define INITIAL_CENTER_Y 0.113075f
#define INITIAL_SIZE 2
#define SIZE_RATIO_X 1.5f
#define SIZE_RATIO_Y 1

float calculateMathPos(float screenPos, float screenWidth, float size, float center)
{
    float offset = center - size/2;
    return screenPos/screenWidth*size + offset;
}

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

int main()
{
    // Start SDL

    SDL_Renderer *renderer;
    SDL_Window *window;

    SDL_Init(SDL_INIT_VIDEO);
    SDL_CreateWindowAndRenderer(WINDOW_WIDTH, WINDOW_HEIGHT, 0, &window, &renderer);
    SDL_Texture *texture = SDL_CreateTexture(renderer,
        SDL_PIXELFORMAT_ABGR8888, SDL_TEXTUREACCESS_STREAMING, WINDOW_WIDTH, WINDOW_HEIGHT);
    puts("Started.");

    // Main loop

    float size = INITIAL_SIZE;
    float center_x = INITIAL_CENTER_X;
    float center_y = INITIAL_CENTER_Y;

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
            SDL_LockTexture(texture, NULL, (void**)&pixels, &pitch);

            for (int screen_x = 0; screen_x < WINDOW_WIDTH; screen_x++)
                for (int screen_y = 0; screen_y < WINDOW_HEIGHT; screen_y++)
                {
                    float math_x = calculateMathPos((float)screen_x, WINDOW_WIDTH, size*SIZE_RATIO_X, center_x);
                    float math_y = calculateMathPos(WINDOW_HEIGHT - (float)screen_y, WINDOW_HEIGHT, size*SIZE_RATIO_Y, center_y);
                    struct mb_result result = process_mandelbrot(math_x, math_y);

                    struct color color;
                    if (result.is_in_set)
                        color = (struct color){ 0, 0, 0 };
                    else
                        color = color_lerp(OUTER_COLOR, INNER_COLOR,
                            (float)result.escape_iterations / MAX_COLOR_ITERATIONS);
                    
                    int r_offset = screen_y*pitch + screen_x*4;
                    pixels[r_offset + 0] = (uint8_t) color.r;
                    pixels[r_offset + 1] = (uint8_t) color.g;
                    pixels[r_offset + 2] = (uint8_t) color.b;
                    pixels[r_offset + 3] = 255;
                }
            
            SDL_UnlockTexture(texture);

            uint64_t end_time = SDL_GetPerformanceCounter();
            float time_taken = (float)(end_time - begin_time) / (float)SDL_GetPerformanceFrequency();
            printf("Time taken: %fs. Waiting for next click.\n", time_taken);
        }

        SDL_RenderCopy(renderer, texture, NULL, NULL);
        SDL_RenderPresent(renderer);
    }

    // Quit SDL

    puts("Quitting...");
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}