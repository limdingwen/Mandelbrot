#include <metal_stdlib>
using namespace metal;

#include "BigFloat.h"

// Thread

struct fp256 calculateMathPos(int screen_pos, struct fp256 width_reciprocal, struct fp256 size, struct fp256 center)
{
    struct fp256 offset = fp_ssub256(center, fp_asr256(size));
    return fp_sadd256(fp_smul256(fp_smul256(int_to_fp256(screen_pos), width_reciprocal), size), offset);
}

struct mb_result
{
    bool is_in_set;
    unsigned long escape_iterations;
};

struct mb_result process_mandelbrot(struct fp256 math_x, struct fp256 math_y, unsigned long iterations)
{
    struct fp256 x2 = { SIGN_ZERO, {0} };
    struct fp256 y2 = { SIGN_ZERO, {0} };
    struct fp256 x = { SIGN_ZERO, {0} };
    struct fp256 y = { SIGN_ZERO, {0} };

    for (unsigned long i = 0; i < iterations; i++)
    {
        y = fp_sadd256(fp_asl256(fp_smul256(x, y)), math_y);
        x = fp_sadd256(fp_ssub256(x2, y2), math_x);
        x2 = fp_ssqr256(x);
        y2 = fp_ssqr256(y);
        if (fp_sadd256(x2, y2).man[0] >= 4)
            return (struct mb_result){ false, i };
    }
    return (struct mb_result){ true, -1UL };
}

kernel void process_pixel(constant int &width,
                          constant int &height,
                          constant struct fp256 &width_reciprocal,
                          constant struct fp256 &height_reciprocal,
                          constant struct fp256 &size,
                          constant struct fp256 &size_x,
                          constant struct fp256 &center_x,
                          constant struct fp256 &center_y,
                          constant uint64_t &iterations,
                          device uint64_t *results,
                          constant uint64_t &offset,
                          uint index [[thread_position_in_grid]])
{
    uint64_t real_index = index + offset;
    int screen_x = real_index % width;
    int screen_y = real_index / width;
    if (screen_y >= height)
        return;
    
    struct fp256 math_x = calculateMathPos(screen_x, width_reciprocal, size_x, center_x);
    struct fp256 math_y = calculateMathPos(height - screen_y, height_reciprocal, size, center_y);
    struct mb_result result = process_mandelbrot(math_x, math_y, iterations);
    results[real_index] = result.escape_iterations;
}
