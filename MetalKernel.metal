#include <metal_stdlib>
using namespace metal;

#include "BigFloat.h"

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

struct gradient
{
    int stop_count;
    int size;
    const struct color *stops;
};

struct color gradient_color(struct gradient gradient, float x)
{
    x = fmodf(x, (float)gradient.size);
    
    int stop_prev = (int)((float)x / (float)gradient.size * (float)gradient.stop_count);
    int stop_next = stop_prev + 1;
    float stop_x = (float)x / (float)gradient.size * (float)gradient.stop_count - (float)stop_prev;
    return color_lerp(gradient.stops[stop_prev], gradient.stops[stop_next], stop_x);
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
    struct fp256 x2 = { SIGN_ZERO, {0} };
    struct fp256 y2 = { SIGN_ZERO, {0} };
    struct fp256 x = { SIGN_ZERO, {0} };
    struct fp256 y = { SIGN_ZERO, {0} };

    for (unsigned long long i = 0; i < iterations; i++)
    {
        y = fp_sadd256(fp_asl256(fp_smul256(x, y)), math_y);
        x = fp_sadd256(fp_ssub256(x2, y2), math_x);
        x2 = fp_ssqr256(x);
        y2 = fp_ssqr256(y);
        if (fp_sadd256(x2, y2).man[0] >= 4)
            return (struct mb_result){ false, i };
    }
    return (struct mb_result){ true, -1ULL };
}

kernel void process_pixel(int width,
                          int height,
                          struct fp256 width_reciprocal,
                          struct fp256 height_reciprocal,
                          struct fp256 size,
                          struct fp256 size_x,
                          struct fp256 center_x,
                          struct fp256 center_y,
                          uint64_t iterations,
                          device uint8_t *pixels,
                          int offset,
                          uint index [[thread_position_in_grid]])
{
    int real_index = index + offset;
    int screen_x = real_index % width;
    int screen_y = real_index / width;
    if (screen_y >= height)
        return;
    
    struct fp256 math_x = calculateMathPos(screen_x, width_reciprocal, size_x, center_x);
    struct fp256 math_y = calculateMathPos(height - screen_y, height_reciprocal, size, center_y);
    struct mb_result result = process_mandelbrot(math_x, math_y, iterations);

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
        color = gradient_color(gradient, (float)sqrt((double)result.escape_iterations));
    }
    
    int r_offset = (screen_y*width + screen_x)*4;
    pixels[r_offset + 0] = (uint8_t) color.r;
    pixels[r_offset + 1] = (uint8_t) color.g;
    pixels[r_offset + 2] = (uint8_t) color.b;
    pixels[r_offset + 3] = 255;
}
