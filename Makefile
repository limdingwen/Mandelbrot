CC_DBG=-fsanitize=undefined,address -g 
CC_RLS=-Os

mandelbrot: main.c Makefile
	clang main.c -o $@ $(CC_DBG) -Werror -Wall -Wextra -Wconversion -I/opt/homebrew/include -L/opt/homebrew/lib -lsdl2