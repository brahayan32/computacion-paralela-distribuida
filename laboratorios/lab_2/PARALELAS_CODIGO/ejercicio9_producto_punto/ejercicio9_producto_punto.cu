#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <cuda_runtime.h>

#define N 4096
#define THREADS 256

__global__ void productoPunto(float *d_A, float *d_B,
                              float *d_parciales, int n) {

    extern __shared__ float s_datos[];

    int tid = threadIdx.x;
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    s_datos[tid] = (idx < n) ? d_A[idx] * d_B[idx] : 0.0f;

    __syncthreads();

    for (int stride = blockDim.x / 2; stride > 0; stride /= 2) {

        if (tid < stride)
            s_datos[tid] += s_datos[tid + stride];

        __syncthreads();
    }

    if (tid == 0)
        d_parciales[blockIdx.x] = s_datos[0];
}

int main() {

    srand(time(NULL));

    float *h_A = (float*)malloc(N * sizeof(float));
    float *h_B = (float*)malloc(N * sizeof(float));

    for (int i = 0; i < N; i++) {
        h_A[i] = (float)(rand() % 10);
        h_B[i] = (float)(rand() % 10);
    }

    float resultado_cpu = 0.0f;

    for (int i = 0; i < N; i++)
        resultado_cpu += h_A[i] * h_B[i];

    int numBloques = (N + THREADS - 1) / THREADS;

    float *h_parciales = (float*)malloc(numBloques * sizeof(float));

    float *d_A, *d_B, *d_parciales;

    cudaMalloc((void**)&d_A,         N          * sizeof(float));
    cudaMalloc((void**)&d_B,         N          * sizeof(float));
    cudaMalloc((void**)&d_parciales, numBloques * sizeof(float));

    cudaMemcpy(d_A, h_A, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, N * sizeof(float), cudaMemcpyHostToDevice);

    int sharedBytes = THREADS * sizeof(float);

    productoPunto<<<numBloques, THREADS, sharedBytes>>>(d_A, d_B, d_parciales, N);

    cudaDeviceSynchronize();

    cudaMemcpy(h_parciales, d_parciales, numBloques * sizeof(float),
               cudaMemcpyDeviceToHost);

    float resultado_gpu = 0.0f;

    for (int i = 0; i < numBloques; i++)
        resultado_gpu += h_parciales[i];

    printf("Producto punto GPU = %.2f\n", resultado_gpu);
    printf("Producto punto CPU = %.2f\n", resultado_cpu);

    if (resultado_gpu == resultado_cpu)
        printf("[OK] Resultados identicos\n");
    else {
        printf("[ERROR] Resultados diferentes\n");
        printf("Diferencia = %.2f\n", resultado_cpu - resultado_gpu);
    }

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_parciales);

    free(h_A);
    free(h_B);
    free(h_parciales);

    return 0;
}