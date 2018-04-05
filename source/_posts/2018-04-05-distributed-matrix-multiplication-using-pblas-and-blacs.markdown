---
title: Distributed matrix multiplication using PBLAS and BLACS.
date: 2018-04-05T13:50:59+09:00
---

PBLAS (or Parallel BLAS) is a parallel version of BLAS that use BLACS internally for parallel computing. It expects the matrix to be already distributed among processors before it starts computing. You first create the data in each process and then provide PBLAS with information that will help it determine how exactly the matrix is distributed. Each process can access only its local data.

# Array descriptor

You also need to define an 'array descriptor' for the matrix that you are working on. The array descriptor is an integer array of length 9 that contains the following data:
``` cpp
int array_desc[9] = {
    dtype,   // descriptor type (=1 for dense matrix)
    context, // BLACS context handle for process grid
    m,       // num of rows in the global array
    n,       // num of cols in the global array
    mb,      // num of rows in a block
    nb,      // num of cols in a block
    rsrc,    // process row over which first row of the global array is distributed
    csrc,    // process col over which first col of the global array is distributed
    lld      // leading dimension of the local array
}
```

According to PBLAS conventions, the global matrix can be denoted by `A` and the block of matrix possessed by the particlar process as `sub(A)`. The number of rows and columns of a global dense matrix that a particular process in a grid receives after data distributing is denoted by `LOCr()` and `LOCc()`, respectively. To compute these numbers, you can use the ScaLAPACK tool routine `numroc`.

To explain with example, see the prototype of the `pdgemm` routine ([intel](https://software.intel.com/en-us/mkl-developer-reference-c-p-gemm#5258C6E6-D85C-4E79-A64C-A45F300B0C3C) resource):
``` cpp
pdgemm(
    const char *transa ,  // (g) form of sub(A)
    const char *transb ,  // (g) form of sub(B)
    const int *m ,        // (g) number of rows of sub(A) and sub(C)
    const int *n ,        // (g) number of cols of sub(B) and sub(C)
    const int *k ,        // (g) Number of cols of sub(A) and rows of sub(A)
    const double *alpha , // (g) scalar alpha
    // array that contains local pieces of distributed matrix sub(A). size lld_a by kla.
    //   kla is LOCq(ja+m-1) for C code (transposed).
    const double *a ,     // (l)
    const int *ia ,       // (g) row index in the distributed matrix A indicating first row of sub(A)
    const int *ja ,       // (g) col index in the distributed matrix A indicating first col of sub(A)
    const int *desca ,    // (g & l)array of dim 9. Array descriptor of A.
    // array that contains local pieces of dist matrix sub(B). size lld_b by klb.
    //   klb is LOCq(jb+k-1) for C code (transposed).
    const double *b ,     // (l)
    const int *ib ,       // (g) row index of dist matrix B indicating first row of sub(B)
    const int *jb ,       // (g) col index of dist matrix B indicating first col of sub(B)
    const int *descb ,    // (g & l) array desc of matrix B (dim 9).
    const double *beta ,  // (g) scalar beta
    double *c ,           // (l) Array of size (lld_a, LOCq(jc+n-1)). contains sub(C) pieces.
    const int *ic ,       // (g) row index of dist matrix C indicating first row of sub(C)
    const int *jc ,       // (g) col index of dist matrix C indicating first col of sub(C)
    const int *descc      // (g & l) array of dim 9. Array desc of C.
)
```
The above function looks very similar to non-parallel `dgemm` from BLAS, with additions for making it easy to find elements in a parallel scenario. Keep in mind that there are some arguments that refer to the global array properties and some that refer to the local array properties.

A function called `numroc` from ScaLAPACK is useful for determining how many rows or cols of the global matrix are present in a particular process. The prototype looks as follows:
``` cpp
int numroc_(
    const int *n,       // (g) number of rows/cols in dist matrix (global matrix).
    const int *nb,      // (g input) block size. (must be square blocks)
    const int *iproc,   // (l input) co-ordinate of process whole local array row/col is to be determined.
    const int *srcproc, // (g input) co-ordinate of the process that contains the frist row or col of the dist matrix.
    const int *nprocs   // (g input) total number of processes.
)
```

A simple implementation of matrix multiplication using BLACS and PBLAS can be found [here](URL). 
