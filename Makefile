CC_DBG=-fsanitize=undefined,address -g -O0
CC_RLS=-Ofast

mandelbrot: main.c Makefile
	clang main.c -o $@ $(CC_DBG) -Werror -Wall -Wextra -Wconversion -I/opt/homebrew/include -L/opt/homebrew/lib -lsdl2

mandelbrot.s: main.c Makefile
	clang main.c -o $@ -S -Ofast -I/opt/homebrew/include

mandelbrot.e: main.c Makefile
	clang main.c -o $@ -E -I/opt/homebrew/include