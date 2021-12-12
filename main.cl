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

// TODO: Add main.h
#define SIZE_RATIO_X (struct fp256){ SIGN_POS, { 1, 0x8000000000000000, 0, 0 } } // 1.5

// Thread

struct mb_result
{
    bool is_in_set;
    unsigned long long escape_iterations;
};

struct fp256 calculateMathPos(int screen_pos, struct fp256 width_reciprocal, struct fp256 size, struct fp256 center)
{
    struct fp256 offset = fp_ssub256(center, fp_asr256(size));
    return fp_sadd256(fp_smul256(fp_smul256(int_to_fp256(screen_pos), width_reciprocal), size), offset);
}

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
    global struct mb_result *results)
{
    int i = get_global_id(0);
    int screen_x = i % width;
    int screen_y = i / width;
    struct fp256 math_x = calculateMathPos(screen_x, width_reciprocal, size_x, center_x);
    struct fp256 math_y = calculateMathPos(height - screen_y, height_reciprocal, size, center_y);
    results[i] = process_mandelbrot(math_x, math_y, iterations);
}

__kernel void vector_add(__global const int *A, __global const int *B, __global int *C)
{ 
    // Get the index of the current element to be processed
    int i = get_global_id(0);
 
    // Do the operation
    C[i] = A[i] + B[i];
}