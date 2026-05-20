#include <stdio.h>
#include <cuda_runtime.h>

#define FILAS 4
#define COLS 5

__global__ void inicializarMatriz(int *d_mat, int filas, int cols) {

    int col  = blockIdx.x * blockDim.x + threadIdx.x;
    int fila = blockIdx.y * blockDim.y + threadIdx.y;

    if (fila < filas && col < cols)
        d_mat[fila * cols + col] = fila + col;
}

int main() {

    int h_mat[FILAS * COLS];
    int *d_mat;

    cudaMalloc((void**)&d_mat, FILAS * COLS * sizeof(int));

    dim3 hilosPorBloque(COLS, FILAS);
    dim3 numBloques(1, 1);

    inicializarMatriz<<<numBloques, hilosPorBloque>>>(d_mat, FILAS, COLS);

    cudaDeviceSynchronize();

    cudaMemcpy(h_mat, d_mat, FILAS * COLS * sizeof(int),
               cudaMemcpyDeviceToHost);

    printf("Matriz inicializada por la GPU:\n");

    for (int i = 0; i < FILAS; i++) {

        for (int j = 0; j < COLS; j++)
            printf("%3d ", h_mat[i * COLS + j]);

        printf("\n");
    }

    cudaFree(d_mat);

    return 0;
}