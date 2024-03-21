void asm_main();
#include <stdio.h>
typedef unsigned int uint;

float __attribute__((noinline)) read_float() {
    float x = 0.0f;
    scanf("%f", &x);
    return x;
}
unsigned long long __attribute__((noinline)) read_uint() {
    unsigned long long x = 0;
    scanf("%llu", &x);
    return x;
}
void __attribute__((noinline)) write_float(float x) { printf("%f", x); }
void __attribute__((noinline)) write_uint(unsigned long long x) {
    printf("%llx", x);
}

void __attribute__((noinline)) write_char(char ch) { printf("%c", ch); }
void __attribute__((noinline)) write_str(char *str) { printf("%s", str); }

void flush() { fflush(stdout); }

int main() {
    asm_main();
    return 0;
}
