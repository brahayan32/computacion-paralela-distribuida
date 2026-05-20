#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <cuda_runtime.h>

#define N 10000000
#define THREADS 256

__global__ void escalarMult(float *d_vec, float escalar, int n) {

    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < n)
        d_vec[idx] *= escalar;
}

int main() {

    float escalar = 2.5f;
    size_t bytes = N * sizeof(float);

    float *h_vec = (float*)malloc(bytes);

    for (int i = 0; i < N; i++)
        h_vec[i] = 1.0f;

    clock_t inicio_cpu = clock();

    for (int i = 0; i < N; i++)
        h_vec[i] *= escalar;

    clock_t fin_cpu = clock();

    double tiempo_cpu =
        ((double)(fin_cpu - inicio_cpu) / CLOCKS_PER_SEC) * 1000.0;

    printf("Tiempo CPU: %.4f ms\n", tiempo_cpu);

    for (int i = 0; i < N; i++)
        h_vec[i] = 1.0f;

    float *d_vec;

    cudaMalloc((void**)&d_vec, bytes);
    cudaMemcpy(d_vec, h_vec, bytes, cudaMemcpyHostToDevice);

    cudaEvent_t inicio, fin;

    cudaEventCreate(&inicio);
    cudaEventCreate(&fin);

    int numBloques = (N + THREADS - 1) / THREADS;

    cudaEventRecord(inicio);

    escalarMult<<<numBloques, THREADS>>>(d_vec, escalar, N);

    cudaEventRecord(fin);
    cudaEventSynchronize(fin);

    float ms = 0;
    cudaEventElapsedTime(&ms, inicio, fin);

    printf("Tiempo GPU: %.4f ms\n", ms);

    float gb = (2.0f * bytes) / (1024.0f * 1024.0f * 1024.0f);
    float bandwidth = gb / (ms / 1000.0f);

    printf("Bandwidth efectivo: %.2f GB/s\n", bandwidth);

    cudaMemcpy(h_vec, d_vec, sizeof(float), cudaMemcpyDeviceToHost);

    printf("h_vec[0] = %.1f (esperado %.1f)\n", h_vec[0], escalar);

    if (tiempo_cpu > ms)
        printf("La GPU fue mas rapida.\n");
    else
        printf("La CPU fue mas rapida.\n");

    cudaEventDestroy(inicio);
    cudaEventDestroy(fin);

    cudaFree(d_vec);
    free(h_vec);

    return 0;
}