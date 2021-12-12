#define CL_UINT uint
#define CL_ULONG ulong
#include "bigfloat.h"
#undef CL_ULONG
#undef CL_UINT

#include "shared.h"

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
uint complex_sqrmag_whole(struct complex a)
{
    struct fp256 c = fp_sadd256(fp_ssqr256(a.x), fp_ssqr256(a.y));
    return c.man[0];
}

// Thread

ulong process_mandelbrot(struct fp256 math_x, struct fp256 math_y, ulong iterations)
{
    struct complex c = { math_x, math_y };
    struct complex z = { { SIGN_ZERO, {0} }, { SIGN_ZERO, {0} } };
    for (ulong i = 0; i < iterations; i++)
    {
        z = complex_add(complex_sqr(z), c);
        if (complex_sqrmag_whole(z) >= 4) // sqr(2), where 2 is "radius of escape"
            return i;
    }
    return -1UL;
}

kernel void process_pixel(
    const int width,
    const int height,
    const struct fp256 width_reciprocal,
    const struct fp256 height_reciprocal,
    const struct fp256 size,
    const struct fp256 size_x,
    const struct fp256 center_x,
    const struct fp256 center_y,
    const ulong iterations,
    global ulong *results) // Workaround for Metal compiler
{
    size_t i = get_global_id(0);
    int screen_x = i % width;
    int screen_y = i / width;
    if (screen_y >= height)
        return;
    
    struct fp256 math_x = calculateMathPos(screen_x, width_reciprocal, size_x, center_x);
    struct fp256 math_y = calculateMathPos(height - screen_y, height_reciprocal, size, center_y);
    results[i] = process_mandelbrot(math_x, math_y, iterations);
    /*if (result.is_in_set)
        results[i] = -1;
    else
        results[i] = escape_iterations;*/
}