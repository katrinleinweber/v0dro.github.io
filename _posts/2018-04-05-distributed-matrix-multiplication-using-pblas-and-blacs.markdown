---
title: Distributed matrix multiplication using PBLAS and BLACS.
date: 2018-04-05T13:50:59+09:00
---

PBLAS (or Parallel BLAS) is a parallel version of BLAS that use BLACS internally for
parallel computing. It expects the matrix to be already distributed among processors
before it starts computing. You first create the data in each process and then provide 
PBLAS with information that will help it determine how exactly the matrix is distributed.
Each process can access only its local data.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Array descriptor](#array-descriptor)
- [Multiplication function description](#multiplication-function-description)
- [Full code](#full-code)
- [Resources](#resources)

<!-- markdown-toc end -->

# Array descriptor

You also need to define an 'array descriptor' for the matrix that you are working on. 
The array descriptor is an integer array of length 9 that contains the following data:
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

Although you can do it yourself, using the `descinit` function for initializing the array descriptor is a good way to keep the code clean. This function looks as follows:
```
void descinit_ (
    int *desc, 
    const int *m, 
    const int *n, 
    const int *mb, 
    const int *nb, 
    const int *irsrc, 
    const int *icsrc, 
    const int *ictxt, 
    const int *lld, 
    int *info
);
```

# Multiplication function description

According to PBLAS conventions, the global matrix can be denoted by `A` and the 
block of matrix possessed by the particlar process as `sub(A)`. The number of
rows and columns of a global dense matrix that a particular process in a grid
receives after data distributing is denoted by `LOCr()` and `LOCc()`, respectively.
To compute these numbers, you can use the ScaLAPACK tool routine `numroc`.

To explain with example, see the prototype of the `pdgemm` routine 
([intel](https://software.intel.com/en-us/mkl-developer-reference-c-p-gemm#5258C6E6-D85C-4E79-A64C-A45F300B0C3C) resource):
``` cpp
void pdgemm_(
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
The above function looks very similar to non-parallel `dgemm` from BLAS, with
additions for making it easy to find elements in a parallel scenario. Keep in
mind that there are some arguments that refer to the global array properties
and some that refer to the local array properties.

A function called `numroc` from ScaLAPACK is useful for determining how many
rows or cols of the global matrix are present in a particular process. The 
prototype looks as follows:
``` cpp
int numroc_(
    const int *n,       // (g) number of rows/cols in dist matrix (global matrix).
    const int *nb,      // (g input) block size. (must be square blocks)
    const int *iproc,   // (l input) co-ordinate of process whole local array row/col is to be determined.
    const int *srcproc, // (g input) co-ordinate of the process that contains the frist row or col of the dist matrix.
    const int *nprocs   // (g input) total number of processes.
)
```

When compiling these functions, don't forget to link with the `-lgfortran` flag.

# Full code

A simple implementation of matrix multiplication using BLACS and PBLAS:

``` cpp
#include "mpi.h"
#include <iostream>
#include <cstdlib>
#include <cmath>
using namespace std;

extern "C" {
  /* Cblacs declarations */
  void Cblacs_pinfo(int*, int*);
  void Cblacs_get(int, int, int*);
  void Cblacs_gridinit(int*, const char*, int, int);
  void Cblacs_pcoord(int, int, int*, int*);
  void Cblacs_gridexit(int);
  void Cblacs_barrier(int, const char*);
 
  int numroc_(int*, int*, int*, int*, int*);

  void descinit_(int *desc, const int *m,  const int *n, const int *mb, 
    const int *nb, const int *irsrc, const int *icsrc, const int *ictxt, 
    const int *lld, int *info);

  void pdgemm_( char* TRANSA, char* TRANSB,
                int * M, int * N, int * K,
                double * ALPHA,
                double * A, int * IA, int * JA, int * DESCA,
                double * B, int * IB, int * JB, int * DESCB,
                double * BETA,
                double * C, int * IC, int * JC, int * DESCC );
}


int main(int argc, char ** argv)
{
  // MPI init
  MPI_Init(&argc, &argv);
  int mpi_rank, mpi_size;
  MPI_Comm_rank(MPI_COMM_WORLD, &mpi_rank);
  MPI_Comm_size(MPI_COMM_WORLD, &mpi_size);
  // end MPI init

  // BLACS init
  int BLACS_CONTEXT, proc_nrows, proc_ncols, myrow, mycol;
  int proc_id, num_procs;
  proc_nrows = 2; proc_ncols = 2;
n  //int proc_dims[2] = {proc_nrows, proc_ncols};
  Cblacs_pinfo(&proc_id, &num_procs);
  Cblacs_get( -1, 0, &BLACS_CONTEXT );
  Cblacs_gridinit( &BLACS_CONTEXT, "Row", proc_nrows, proc_ncols );
  Cblacs_pcoord(BLACS_CONTEXT, mpi_rank, &myrow, &mycol);
  cout << "myrow " << myrow << " mycol " << mycol << endl;
  cout << "procid " << proc_id << " num_procs " << num_procs << endl;
  // end BLACS init

  // matrix properties
  int N = 8, nb = 4; // mat size, blk size.
  double* a = (double*)malloc(sizeof(double)*nb*nb);
  double* b = (double*)malloc(sizeof(double)*nb*nb);
  double* c = (double*)malloc(sizeof(double)*nb*nb);

  // generate matrix data
  for (int i = 0; i < nb*nb; ++i) {
    a[i] = 1;
    b[i] = 2;
    c[i] = 0;
  }
  // end matrix properties

  // create array descriptor
  int desca[9];
  int descb[9];
  int descc[9];
  int rsrc = 0, csrc = 0, info;
  descinit_(desca, &N, &N, &nb, &nb, &rsrc, &csrc, &BLACS_CONTEXT, &nb, &info);
  descinit_(descb, &N, &N, &nb, &nb, &rsrc, &csrc, &BLACS_CONTEXT, &nb, &info);
  descinit_(descc, &N, &N, &nb, &nb, &rsrc, &csrc, &BLACS_CONTEXT, &nb, &info);
  cout << proc_id << " info: " << info << endl;
  // end create array descriptor
  
  Cblacs_barrier(BLACS_CONTEXT, "All");
  int ia = 1, ja = 1, ib = 1, jb = 1, ic = 1, jc = 1;
  double alpha = 1, beta = 1;
  pdgemm_("T", "T", &N, &N, &N, &alpha, a, &ia, &ja, desca, b, &ib, &jb, descb,
          &beta, c, &ic, &jc, descc);

  // print results on a per-process basis
  if (proc_id == 0) {
    cout << "proc : " << proc_id << endl;
    for (int i = 0; i < nb; ++i) {
      for (int j = 0; j < nb; ++j) {
        cout << "(" << nb*myrow + i << "," <<
          nb*mycol + j << ") " << c[i*nb + j] << " ";
      }
      cout << endl;
    }
    cout << endl;
  }

  if (proc_id == 1) {
    cout << "proc : " << proc_id << endl;
    for (int i = 0; i < nb; ++i) {
      for (int j = 0; j < nb; ++j) {
        cout << "(" << nb*myrow + i << "," <<
          nb*mycol + j << ") " << c[i*nb + j] << " ";
      }
      cout << endl;
    }
    cout << endl;
  }

  if (proc_id == 2) {
    cout << "proc : " << proc_id << endl;
    for (int i = 0; i < nb; ++i) {
      for (int j = 0; j < nb; ++j) {
        cout << "(" << nb*myrow + i << "," <<
          nb*mycol + j << ") " << c[i*nb + j] << " ";
      }
      cout << endl;
    }
    cout << endl;
  }

  if (proc_id == 3) {
    cout << "proc : " << proc_id << endl;
    for (int i = 0; i < nb; ++i) {
      for (int j = 0; j < nb; ++j) {
        cout << "(" << nb*myrow + i << "," <<
          nb*mycol + j << ") " << c[i*nb + j] << " ";
      }
      cout << endl;
    }
    cout << endl;
  }

  MPI_Finalize();
}
```

# Resources

* [Use of PBLAS from netlib.](http://www.netlib.org/utk/papers/pblas/node20.html)
* [numroc IBM explanation.](https://www.ibm.com/support/knowledgecenter/en/SSNR5K_5.1.0/com.ibm.cluster.pessl.v5r1.pssl100.doc/am6gr_lnumroc.htm) 

