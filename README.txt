// ################
// # INTRODUCTION #
// ################
//
// Welcome to Mandelbrot, with big floats. This program allows you to
// interactively zoom into the fractal, or render a deep-zoom movie up to a max
// limit of 10^57 zoom.
//
// Youtube link:
//
// This is the CPU bigfloat version.
// CPU doubles version (faster but 10^15 limit): https://github.com/limdingwen/Mandelbrot/tree/fast
// GPU OpenCL version (slower): https://github.com/limdingwen/Mandelbrot/tree/bigfloat-gpu
// GPU Metal version (slower and may crash your Mac): https://github.com/limdingwen/Mandelbrot/tree/bigfloat-metal
//
// #############
// # DOWNLOADS #
// #############
//
// M1 Mac: https://github.com/limdingwen/Mandelbrot/releases/download/v1.0.0/M1.Mac.zip
// (If you want Intel Mac or Intel Windows version just contact me.)
//
// All of these downloads are for interactive zooming; if you want to use the
// movie rendering mode, you'll need to compile the code yourself, and edit the
// configuration (search for #define MOVIE to find it).
//
// ###########
// # OUTLINE #
// ###########
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
// ###############
// # COMPILATION #
// ###############
//
// This program was originally written for Clang+Make, then ported to XCode.
// As such, I'll only provide general instructions for building this.
//
// First of all, this program only supports ARM due to use of inline ARM asm.
// If you would like x86 support, please contact me and I'll add it in; I just
// don't want to waste my time if no one cares anyway.
//
// You only need to compile main.c, and remember to enable -Ofast optimisation.
// You'll need to link SDL2 and SDL2_image, as well as tell the compiler where
// to find their header files. Finally, remember that zoom.png needs to
// accompany the binary.
//
// #############
// # BIG FLOAT #
// #############
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

(Read more: https://github.com/limdingwen/Mandelbrot/blob/bigfloat-cpu/main.c)
