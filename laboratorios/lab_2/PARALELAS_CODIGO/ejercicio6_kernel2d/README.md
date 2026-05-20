# Ejercicio 6 — Kernel 2D: Inicialización de Matriz

**Integrantes:** Brahayan Aldhair Campo Sanchez — Diego Gilberto Rodriguez Portilla

## ¿Qué hace?
Inicializa una matriz 4×5 en la GPU usando hilos bidimensionales. Cada celda
almacena la suma de su fila más su columna (`fila + col`).

## Compilar y ejecutar
```bash
nvcc ejercicio6_kernel2d.cu -o ejercicio6 -arch=sm_75
ejercicio6.exe
```

## Diferencias respecto al código base del taller
El taller pedía como TAREA cambiar el valor de cada celda de índice lineal
a `fila + col`. Se modificó una sola línea dentro del kernel:

```c
// Taller (original):
d_mat[idx] = idx;

// Implementación (TAREA):
d_mat[fila * cols + col] = fila + col;
```

Resultado obtenido:
0   1   2   3   4
1   2   3   4   5
2   3   4   5   6
3   4   5   6   7

## Conceptos practicados
- `dim3` para dimensiones 2D de bloque y grilla
- Indexación 2D: `threadIdx.x/y` y `blockIdx.x/y`
- Conversión de índice 2D a lineal: `fila * cols + col`
- Guard 2D: `if (fila < filas && col < cols)`