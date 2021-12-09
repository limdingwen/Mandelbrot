CC_DBG=-fsanitize=undefined,address -g -Og
CC_RLS=-Ofast

mandelbrot: main.c Makefile
	clang main.c -o $@ $(CC_DBG) -Werror -Wall -Wextra -Wconversion -I/opt/homebrew/include -L/opt/homebrew/lib -lsdl2