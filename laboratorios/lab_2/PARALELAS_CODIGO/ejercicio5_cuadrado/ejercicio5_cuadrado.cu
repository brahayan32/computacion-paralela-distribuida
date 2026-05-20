#include <stdio.h>
#include <cuda_runtime.h>

#define N 20

__global__ void cuadradoInPlace(int *d_datos, int n) {

    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < n)
        d_datos[idx] = d_datos[idx] * d_datos[idx];
}

int main() {

    int h_datos[N];

    for (int i = 0; i < N; i++)
        h_datos[i] = i + 1;

    printf("Datos originales:\n");

    for (int i = 0; i < N; i++)
        printf("%4d", h_datos[i]);

    printf("\n");

    int *d_datos;

    cudaMalloc((void**)&d_datos, N * sizeof(int));

    cudaMemcpy(d_datos, h_datos, N * sizeof(int),
               cudaMemcpyHostToDevice);

    cuadradoInPlace<<<1, N>>>(d_datos, N);

    cudaDeviceSynchronize();

    cudaMemcpy(h_datos, d_datos, N * sizeof(int),
               cudaMemcpyDeviceToHost);

    printf("Despues de elevar al cuadrado en GPU:\n");

    for (int i = 0; i < N; i++)
        printf("%4d", h_datos[i]);

    printf("\n");

    int ok = 1;

    for (int i = 0; i < N; i++) {

        int esperado = (i + 1) * (i + 1);

        if (h_datos[i] != esperado) {

            printf("ERROR en posicion %d\n", i);
            printf("Valor obtenido: %d\n", h_datos[i]);
            printf("Valor esperado: %d\n", esperado);

            ok = 0;
        }
    }

    if (ok)
        printf("\n[OK] Todos los valores son correctos.\n");
    else
        printf("\n[FALLO] Hay errores en los resultados.\n");

    cudaFree(d_datos);

    return 0;
}