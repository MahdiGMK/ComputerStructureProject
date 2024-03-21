#include <stdio.h>
#define SIZE 512

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

float mat1[SIZE][SIZE], mat2[SIZE][SIZE], mat3[SIZE][SIZE];
int main(int argc, char *argv[]) {
    // printf("input dim of matrix (0 <= n <= 512) : ");
    // fflush(stdout);
    unsigned int n;
    n = read_uint();
    while (n > 512) {
        write_str("input a valid n (0 <= n <= 512)\n");
        fflush(stdout);
        n = read_uint();
    }

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            mat1[i][j] = read_float();
        }
    }
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            mat2[i][j] = read_float();
        }
    }
    for (int i = 0; i < n; i++) {
        for (int k = 0; k < n; k++) {
            for (int j = 0; j < n; j++) {
                mat3[i][j] += mat1[i][k] * mat2[k][j];
            }
        }
    }
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            write_float(mat3[i][j]);
            write_char(' ');
        }
        write_char('\n');
    }
    return 0;
}
