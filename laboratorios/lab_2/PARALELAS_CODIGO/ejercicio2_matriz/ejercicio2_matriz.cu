#include <stdio.h>
#include <math.h>
#include <cuda_runtime.h>

#define FILAS 3
#define COLS 4
#define N (FILAS * COLS)

void imprimirMatriz(float *m, int filas, int cols) {

    for (int i = 0; i < filas; i++) {

        for (int j = 0; j < cols; j++)
            printf("%6.1f ", m[i * cols + j]);

        printf("\n");
    }
}

int main() {

    float h_original[N], h_recuperada[N];

    for (int i = 0; i < N; i++)
        h_original[i] = (float)(i + 1) * 1.5f;

    printf("Matriz original (CPU):\n");
    imprimirMatriz(h_original, FILAS, COLS);

    float *d_matriz;

    cudaMalloc((void**)&d_matriz, N * sizeof(float));

    cudaMemcpy(d_matriz, h_original, N * sizeof(float),
               cudaMemcpyHostToDevice);

    printf("\n[OK] Datos enviados a la GPU\n");

    cudaMemcpy(h_recuperada, d_matriz, N * sizeof(float),
               cudaMemcpyDeviceToHost);

    printf("\nMatriz recuperada desde GPU:\n");
    imprimirMatriz(h_recuperada, FILAS, COLS);

    int ok = 1;

    for (int i = 0; i < N; i++) {

        if (fabsf(h_original[i] - h_recuperada[i]) >= 1e-5f) {

            printf("\nERROR en posicion %d\n", i);
            printf("Original: %.5f | Recuperado: %.5f\n",
                   h_original[i], h_recuperada[i]);

            ok = 0;
        }
    }

    if (ok)
        printf("\n[OK] Todos los datos coinciden correctamente.\n");
    else
        printf("\n[FALLO] Existen diferencias en los datos.\n");

    cudaFree(d_matriz);

    return 0;
}