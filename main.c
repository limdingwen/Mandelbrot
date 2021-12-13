// INTRODUCTION
//
// Welcome to Mandelbrot, with big floats. This is a work in progress, so in the
// meantime, here's a TODO list of things I still need to do.
//
// TODO: Documentation
// And of course, TODO: Make video.
//
// COMPILATION
//
// You can compile this program with make, but you'll probably need to change
// the Makefile to suit your system. Before doing so, install SDL2 and
// SDL2_image. Then configure the Makefile to point to your system's include
// files and library files (such as .so on Linux or .dylib on Mac).
//
// The Makefile also uses clang; either install clang or change that to any
// compiler that you use, such as gcc.
//
// OUTLINE
//
// This version of the program has two modes; preview and full-sized rendering.
// Both modes are nearly identical except for the resolution in which they are
// rendered at. In an earlier version of this program, the preview mode was able
// to run at 60fps, navigatable by keyboard. However, ever since the switch from
// doubles to big floats, the program does not run fast enough to enjoy that
// level of interactivity. As such, both modes operate on click-to-zoom.
//
// Controls:
// H - Return home
// Left click - Zoom in
// Right click - Zoom out
// Tab - Change between preview and full resolution (may take a long time!)
//
// There's actually a movie mode as well TODO:
//
// BIG FLOAT
//
// One of the core parts of Mandelbrot is the floating point precision, so it
// makes sense to go over them first.
//
// We do not use any floating points in our program; instead, we have an array
// of uint64s, and then we simply imagine the decimal point to be in-between
// the first uint64 and the second. That way our calculations are immensely
// simplified. Adding and subtracting can ignore the decimal point entirely,
// while multiplication just involves taking a slice of the resulting bits.
//
// While we can technically achieve abitrary precision, it was easier to limit
// ourselves to 256-bits and 512-bits for now. You may also notice that we are
// wasting quite a lot of bits by having 64 bits be part of the "whole number".
// However, doing so makes the program a lot simpler and seems to be good enough
// for now.
//
// Finally, we use a sign-magnitude representation instead of 2s complement.
// While this makes adding and subtracting much harder, it makes multiplication
// much easier. I'm unsure if this was a good tradeoff, but it seems like most
// bignum libraries use sign-magnitude as well.

#include <stdint.h>

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

// Let's start with unsigned addition. This is the exciting bit; we get to use
// some easy inline assembly! As you can see, we simply add the LSB (Least
// Significant Bit) of a and b, saving the carry, and then repeat all the way
// to the MSB (Most Significant Bit) while propogating the carry.
//
// We do use quite a lot of registers here, which is another reason for fixing
// ourselves at 512-bits max. ARM only has about 30 usage registers, so we're
// quite near the limit. Any more, and we'll have to start writing code to spill
// registers mid-way through the calculation.

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

// We do the same thing for 256-bits, but we will use a macro to help us reuse
// the same code for both adding (ADD/ADC) and subtracting (SUB/SBC).
//
// Do note that since we are using signed-magnitude comparison, we must ensure
// that a > b before subtracting, so as to ensure that the resulting magnitude
// does not wrap around in 2s complement representation. The only exception is
// if we're comparing a and b, in which we will throw away the results after
// (and not use it as a magnitude).

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
DEF_FP_UADDSUB256(sub, SUB, SBC);
#undef DEF_FP_UADDSUB256

// This allows us to compare the magnitudes of two numbers (note that this
// function is unsigned and ignores the signs of the numbers)! We can do so
// by simply performing (a - b). Then, if it's negative, b must be more than a.
// If it's non-negative, it can either be 0 (same) or a is more than b.

enum cmp
{
    CMP_SAME,
    CMP_A_BIG,
    CMP_B_BIG
};

#include <string.h>
#include <stdbool.h>

enum cmp fp_ucmp256(struct fp256 a, struct fp256 b)
{
    static const uint64_t zero[4]; // Static variables are 0 by default
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

// With unsigned add, sub and cmp functions, we can use this to build a signed
// addition function. First, we check for the special case in which one or both
// of the inputs are 0:

#include <assert.h>

struct fp256 fp_sadd256(struct fp256 a, struct fp256 b)
{
    if (a.sign == SIGN_ZERO && b.sign == SIGN_ZERO)
        return a;
    if (b.sign == SIGN_ZERO)
        return a;
    if (a.sign == SIGN_ZERO)
        return b;

// First, if both are of the same sign, we can simply add the magnitudes and
// inherit the sign.

    if ((a.sign == SIGN_POS && b.sign == SIGN_POS) ||
        (a.sign == SIGN_NEG && b.sign == SIGN_NEG))
    {
        struct fp256 c = fp_uadd256(a, b);
        c.sign = a.sign;
        return c;
    }

// At this point, there are only 2 possibilities: -a and +b, or +a and -b.

    assert((a.sign == SIGN_POS && b.sign == SIGN_NEG) ||
           (a.sign == SIGN_NEG && b.sign == SIGN_POS));

// It should be obvious that if we have a - b or b - a, if a = b, then the
// answer is 0.

    enum cmp cmp = fp_ucmp256(a, b);
    if (cmp == CMP_SAME)
        return (struct fp256) { SIGN_ZERO, {0} };

// And then we can simply follow this chart for the remaining possibilities:
// https://www.tutorialspoint.com/explain-the-performance-of-addition-and-subtraction-with-signed-magnitude-data-in-computer-architecture

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

// We can build upon signed addition to created signed subtraction, by simply
// inverting the second operand's sign.

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

// Now for the big gun; multiplication. There exists harder and more efficient
// multiplication algorithms, but I'll go with the naive, elementary-school-like
// way of doing it.

struct fp256 fp_smul256(struct fp256 a, struct fp256 b)
{

// First, the obvious x * 0 = 0.

    if (a.sign == SIGN_ZERO || b.sign == SIGN_ZERO)
        return (struct fp256) { SIGN_ZERO, {0} };

// Next, we calculate the magnitude of a * the magnitude of b to create our
// final magnitude (c). We create a 512-bit number to hold all the possible
// bits of a 256 * 256 bit multiplication.

    struct fp512 c = {0};

// Just like in elementary school, we literally just multiply each word (digit)
// with all the words in the other operand.

    for (int i = 3; i >= 0; i--) // a
    {
        for (int j = 3; j >= 0; j--) // b
        {

// First, we use a 128-bit number to multiply our two 64-bit words (digit). We
// do this because ARM's 128-bit multiplication was so hard to understand. Plus,
// it's portable!
//
// Also yes, we could have done this for adding as well, but 1) inline assembly
// is kinda fun and 2) I'm unsure if the compiler would have generated the
// optimal ADDS/ADCS code.

#ifndef __SIZEOF_INT128__
#error Your compiler or platform does not support 128 bits.
#endif

            __uint128_t mult = (__uint128_t)a.man[i] * (__uint128_t)b.man[j];

// We then put this 128-bit number into 2 64-bit words (digits), and that makes
// up 1 "row", like you normally see in pencil-and-paper multiplication. Then
// we can simply repeatedly accumulate this into the final answer.

            int low_offset = 7 - (3 - i) - (3 - j);
            assert(low_offset >= 1);
            int high_offset = low_offset - 1;

            struct fp512 temp = {0};
            temp.man[low_offset] = (uint64_t)mult;
            temp.man[high_offset] = mult >> 64;

            c = fp_uadd512(c, temp);
        }
    }

// With the magnitude calculated, finding the sign of the result is trivial:

    enum sign sign;
    if (a.sign == SIGN_NEG && b.sign == SIGN_NEG)
        sign = SIGN_POS;
    else if (a.sign == SIGN_NEG || b.sign == SIGN_NEG)
        sign = SIGN_NEG;
    else
        sign = SIGN_POS;

// Finally, we need to convert the 512-bit result back into 256-bits. Take note
// that 1.234 * 5.678 = 12.345678 (the numbers represent the word position),
// and so we need to take the slice [2, 5].

    struct fp256 c256;
    c256.sign = sign;
    memcpy(c256.man, c.man + 1, 4 * sizeof(uint64_t));

    return c256;
}

struct fp256 fp_ssqr256(struct fp256 a)
{
    return fp_smul256(a, a);
}

// There's an easier way to multiply or divide by 2 however; bit shifting!
// For shifting to the right (ASR), we first shift the least significant word
// to the right, then take the least signifiant bit of the second word, and then
// put it at the most significant bit of the least significant word.
//
// In effect, it's as if we take the entire 256 bits and shift it once to the
// right, where the original least significant bit gets ignored, while the
// new most significant bit is 0.

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

struct fp256 fp_asl256(struct fp256 a)
{
    a.man[0] <<= 1;
    a.man[0] |= (a.man[1] & 0x8000000000000000) >> 63;
    a.man[1] <<= 1;
    a.man[1] |= (a.man[2] & 0x8000000000000000) >> 63;
    a.man[2] <<= 1;
    a.man[2] |= (a.man[3] & 0x8000000000000000) >> 63;
    a.man[3] <<= 1;
    return a;
}

// Finally, to convert a signed into a number, first we remove the sign (and
// store it as the sign enum), then we put the magnitude into the first word
// of the mantissa (which is defined to be the whole number).

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

// With that, we can use big floats to implement complex numbers. The
// implementation is rather trivial:

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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wconversion"
#include "SDL2/SDL_video.h"
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
#include <stdio.h>
#include <pthread.h>
#include <math.h>
#pragma clang diagnostic pop

// RENDERING CONFIGURATION
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

#define GRADIENT_ITERATION_SIZE 16 // Use 2^x for best performance

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

#define MOVIE 1
#define MOVIE_FULL_SHOW_X_INTERVAL 75
#define MOVIE_INITIAL_CENTER_X (struct fp256){ SIGN_NEG, { 1, 0xFFF1315BACAC51F1, 0xD039000000000000 } }
#define MOVIE_INITIAL_CENTER_Y (struct fp256){ SIGN_NEG, { 0, 0x0000000E217005DA, 0x86D3000000000000 } }
#define MOVIE_ZOOM_PER_FRAME (struct fp256){ SIGN_POS, { 0, 0x8000000000000000 } } // 0.5
#define MOVIE_PREFIX "movie/frame"
#define MOVIE_PREFIX_LEN 11

#define INITIAL_ITERATIONS 64

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

struct color gradient_color(struct gradient gradient, float x)
{

// As said before, first we perform a modulus on x so to make the gradient loop.

    x = fmodf(x, (float)gradient.size);

// 

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
                color = gradient_color(gradient, (float)sqrt((double)result.escape_iterations));
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
    int movie_current_frame = 1;

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
    enum state state = STATE_FULL;
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
                iterations += 64; // TODO: Iterations setting
                zoom++;
                printf("Zoom: 4^%llu\n", zoom);
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