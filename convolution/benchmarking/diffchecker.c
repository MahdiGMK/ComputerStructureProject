#include <math.h>
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char *argv[]) {
    FILE *inp = fopen(argv[1], "r");
    unsigned int n, m;
    fscanf(inp, "%u%u", &n, &m);
    fclose(inp);

    FILE *out1 = fopen(argv[2], "r");
    FILE *out2 = fopen(argv[3], "r");

    n = n - m + 1;
    for (int i = 0; i < n * n; i++) {
        float f1 = -1e9, f2 = 1e9;
        fscanf(out1, "%f", &f1);
        fscanf(out2, "%f", &f2);

        if (fabsf(f1 - f2) / fminf(fabsf(f1), fabsf(f2)) > 0.01f) {
            printf("TOO MUCH DIFF : %f , %f\n", f1, f2);
            fclose(out2);
            fclose(out1);
            return 1;
        }
    }

    fclose(out2);
    fclose(out1);

    return 0;
}
