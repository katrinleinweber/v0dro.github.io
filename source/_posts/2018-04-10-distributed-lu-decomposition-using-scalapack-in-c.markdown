---
title: Distributed LU decomposition using scalapack in C++
date: 2018-04-10T15:53:31+09:00
---

ScaLAPACK is the distributed version of LAPACK. The interface of most functions is almost similar. However, not much documentation and example code is available for scalapack in C++, which is why I'm writing this blog post to document my learnings. Hopefully this will be useful for others too.

This post is part of a larger post where I've implemented and benchmarked synchronous and asynchronous block LU deocomposition. That post can be found [here](URL). [This](https://software.intel.com/en-us/mkl-developer-reference-c-p-getrf) intel resource is also helpful for this purpose.

# Scalapack protips

There are certain terminologies that are pretty widely used in scalapack. They are as follows:
* Scalapack docs assume that a matrix of `K` rows or columns is distributed over a process grid of dimensions p x q.
* `LOCr` :: `LOCr(K)` denotes the number of elements of K that a process would receive if K were distributed over the p processes of its process column.
* `LOCc` :: `LOCc(K)` denotes the number of elements of K that a process would receive if K were distributed over the q processes of its process row.
* The values of `LOCc` and `LOCr` can be determined using a call to the `numroc` function.
* **IMPORTANT** :: None of these functions have C interfaces the way there are for LAPACK via LAPACKE. Therefore, you must take care to pass all variables by address, not by value and store all your data in FORTRAN-style, i.e. column-major format not row-major.

The `numroc` function is useful in almost every scalapack function. It computes the number of rows and columns of a distributed matrix ownded by the process (the return value). Here's an explanation alongwith the prototype:
``` cpp
int numroc_(
    const int *n, // (global) the number of rows/cols in dist matrix
    const int *nb, // (global) block size. size of blocks the distributed matrix is split into.
    const int *iproc, // (local input) coord of the process whose local array row is to be determined.
    const int *srcproc, // (global input) coord of the process that has the first row/col of distributed matrix.
    const int *nprocs // (global input) total no. of processes over which the matrix is distributed.
);
```

# Function usage protips

As with other PBLAS or ScaLAPACK functions, this function expects the matrix to be already distributed over the BLACS process grid (and of course the BLACS process grid should be initialized).

The function in scalapack for LU decomposition is `pdgetrf_`. The C++ prototype of this function is
as follows:
``` cpp
void pdgetrf_(
    int *m,   // (global) The number of rows in the distributed matrix sub(A)
    int *n,   // (global) The number of columns in the distributed matrix sub(A)
    // (local) Pointer into the local memory to an array of local size.
    // Contains the local pieces of the distributed matrix sub(A) to be factored.
    double *a,
    int *ia,  // (global) row index in the global matrix A indicating first row matrix sub(A)
    int *ja,  // (global) col index in the global matrix A indicating first col matrix sub(A)
    int *desca, // array descriptor of A
    int *ipiv, // contains the pivoting information. array of size
    int *info // information about execution.
);
```

# Source code

Here's a full source implementing a simple LU decomposition using ScaLAPACK:
``` cpp
// Implement simple distributed LU decomposition using scalapack.
// author: Sameer Deshmukh (@v0dro)

#include "mpi.h"
#include <cstdlib>
#include <cmath>
#include <iostream>
using namespace std;

extern "C" {
  /* Cblacs declarations */
  void Cblacs_pinfo(int*, int*);
  void Cblacs_get(int, int, int*);
  void Cblacs_gridinit(int*, const char*, int, int);
  void Cblacs_pcoord(int, int, int*, int*);
  void Cblacs_gridexit(int);
  void Cblacs_barrier(int, const char*);
 
  void descinit_(int *desc, const int *m,  const int *n, const int *mb, 
    const int *nb, const int *irsrc, const int *icsrc, const int *ictxt, 
    const int *lld, int *info);
  void pdgetrf_(
                int *m, int *n, double *a, int *ia, int *ja, int *desca,
                int *ipiv,int *info);
}

int main(int argc, char ** argv)
{
  // MPI init
  MPI_Init(&argc, &argv);
  // end MPI Init
  
  // BLACS init
  int BLACS_CONTEXT, proc_nrows, proc_ncols, myrow, mycol;
  int proc_id, num_procs;
  proc_nrows = 2; proc_ncols = 2;
  Cblacs_pinfo(&proc_id, &num_procs);
  Cblacs_get( -1, 0, &BLACS_CONTEXT );
  Cblacs_gridinit( &BLACS_CONTEXT, "Row", proc_nrows, proc_ncols );
  Cblacs_pcoord(BLACS_CONTEXT, proc_id, &myrow, &mycol);
  // end BLACS init

  // matrix properties
  // mat size, blk size, portion of block per process
  int N = 8, nb = 4, process_block_size = 2;
  int num_blocks_per_process = N/process_block_size;
  int block_size_per_process_r = sqrt(num_blocks_per_process);
  int block_size_per_process_c = sqrt(num_blocks_per_process);
  double* a = (double*)malloc(sizeof(double)*nb*nb);
  // generate matrix data
  for (int j = 0; j < nb; ++j) {
    for (int i = 0; i < nb; ++i) {
      int index = i*nb + j;
      int row_i = myrow*nb + i;
      int col_j = mycol*nb + j;
      a[index] = row_i + col_j;
    }
    cout << endl;
  }
  // end matrix properties

  // create array descriptor
  int desca[9];
  int rsrc = 0, csrc = 0, info;
  descinit_(desca, &N, &N, &nb, &nb, &rsrc, &csrc, &BLACS_CONTEXT, &nb, &info);
  // end create array descriptor

  Cblacs_barrier(BLACS_CONTEXT, "All");

  // LU decomposition
  int ia = 1, ja = 1;
  int *ipiv = (int*)malloc(sizeof(int)*N);
  pdgetrf_(&N, &N, a, &ia, &ja, desca, ipiv, &info);
  // end LU decomposition

  MPI_Finalize();
}
```

# Resources

* [Intel Q and A on numroc](https://software.intel.com/en-us/forums/intel-math-kernel-library/topic/288028)
* [Numroc fortran docs](http://www.netlib.org/scalapack/explore-html/d4/d48/numroc_8f_source.html) 
* [Using PBLAS/ScaLAPACK in your C code by intel (MKL specific)](https://software.intel.com/en-us/articles/using-cluster-mkl-pblasscalapack-fortran-routine-in-your-c-program) 

