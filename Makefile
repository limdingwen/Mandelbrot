CC_DBG=-fsanitize=undefined,address -g -O0
CC_RLS=-Ofast

mandelbrot: main.c Makefile
	clang main.c -o $@ $(CC_DBG) -Werror -Wall -Wextra -Wconversion -I/opt/homebrew/include #-L/opt/homebrew/lib -lsdl2

mandelbrot.s: main.c Makefile
	clang main.c -o $@ -S -O0 -I/opt/homebrew/include