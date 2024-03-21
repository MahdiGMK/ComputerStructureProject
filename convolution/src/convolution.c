#include <stdio.h>
#define SIZE 1024
float mat1[SIZE][SIZE], mat2[SIZE][SIZE], mat3[SIZE][SIZE];
int n, m;

int main() {
    scanf("%u%u", &n, &m);
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            scanf("%f", &mat1[i][j]);
    for (int i = 0; i < m; i++)
        for (int j = 0; j < m; j++)
            scanf("%f", &mat2[i][j]);

    for (int i = 0; i < n - m + 1; i++) {
        for (int j = 0; j < n - m + 1; j++) {
            for (int k = 0; k < m; k++) {
                for (int l = 0; l < m; l++) {
                    mat3[i][j] += mat1[i + k][j + l] * mat2[k][l];
                }
            }
        }
    }

    for (int i = 0; i < n - m + 1; i++) {
        for (int j = 0; j < n - m + 1; j++) {
            printf("%f ", mat3[i][j]);
        }
        printf("\n");
    }

    return 0;
}
