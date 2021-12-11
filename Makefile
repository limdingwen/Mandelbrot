CC_DBG=-O0 -g
CC_RLS=-Ofast
CC_PRO=-Ofast -g

mandelbrot: main.c Makefile
	clang main.c -o $@ $(CC_RLS) -Werror -Wall -Wextra -Wconversion -I/opt/homebrew/include -L/opt/homebrew/lib -lsdl2 -lsdl2_image

mandelbrot.s: main.c Makefile
	clang main.c -o $@ -S -Ofast -I/opt/homebrew/include

mandelbrot.e: main.c Makefile
	clang main.c -o $@ -E -I/opt/homebrew/include