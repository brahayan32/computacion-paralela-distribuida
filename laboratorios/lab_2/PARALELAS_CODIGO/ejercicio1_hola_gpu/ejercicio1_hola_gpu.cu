#include <stdio.h>
#include <cuda_runtime.h>

#define N 10

int main() {

    int h_datos[N];
    int h_resultado[N];

    for (int i = 0; i < N; i++)
        h_datos[i] = i * 3;

    int *d_datos;
    cudaMalloc((void**)&d_datos, N * sizeof(int));

    cudaMemcpy(d_datos, h_datos, N * sizeof(int), cudaMemcpyHostToDevice);

    printf("Datos copiados a GPU correctamente.\n");

    cudaMemcpy(h_resultado, d_datos, N * sizeof(int), cudaMemcpyDeviceToHost);

    printf("Verificacion de datos:\n");

    int ok = 1;

    for (int i = 0; i < N; i++) {

        printf("  h_datos[%d]=%d, h_resultado[%d]=%d",
               i, h_datos[i], i, h_resultado[i]);

        if (h_datos[i] != h_resultado[i]) {
            printf(" *** ERROR ***");
            ok = 0;
        }

        printf("\n");
    }

    printf(ok ? "\n[OK] Transferencia exitosa!\n"
              : "\n[FALLO] Hay errores.\n");

    cudaFree(d_datos);

    return 0;
}