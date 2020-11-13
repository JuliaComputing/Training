// Linux: gcc -shared -o libhello.so hello.c
// macOS: gcc -shared -o libhello.dylib hello.c
// Windows: compiler? what compiler?

#include <stdio.h>

void hello(char *name)
{
    printf("Hello, %s!\n", name);
}

double sqr(double x)
{
    return x*x;
}

void outputarg(int *val)
{
    *val = 42;
}
