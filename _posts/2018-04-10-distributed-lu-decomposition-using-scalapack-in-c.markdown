---
title: Distributed LU decomposition using scalapack in C++
date: 2018-04-10T15:53:31+09:00
---

ScaLAPACK is the distributed version of LAPACK. The interface of most functions is 
almost similar. However, not much documentation and example code is available for 
scalapack in C++, which is why I'm writing this blog post to document my learnings.
Hopefully this will be useful for others too. The full source code can be found in
[this repo](https://github.com/v0dro/scalapack-lu). This program calls fortran routines
from CPP and therefore all array storage is column major.

This post is part of a larger post where I've implemented and benchmarked synchronous 
and asynchronous block LU deocomposition. That post can be found [here](URL). [This](https://software.intel.com/en-us/mkl-developer-reference-c-p-getrf) intel resource is also helpful for this purpose.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [Scalapack protips](#scalapack-protips)
    - [Errors](#errors)
    - [Linking and compiling](#linking-and-compiling)
- [Function usage protips](#function-usage-protips)
    - [Storage in the arrays](#storage-in-the-arrays)
- [Source code](#source-code)
- [Resources](#resources)

<!-- markdown-toc end -->

# Scalapack protips

There are certain terminologies that are pretty widely used in scalapack. They are as follows:
* Scalapack docs assume that a matrix of `K` rows or columns is distributed over a process grid of dimensions p x q.
* `LOCr` :: `LOCr(K)` denotes the number of elements of K that a process would receive if K were
distributed over the p processes of its process column.
* `LOCc` :: `LOCc(K)` denotes the number of elements of K that a process would receive if K were 
distributed over the q processes of its process row.
* The values of `LOCc` and `LOCr` can be determined using a call to the `numroc` function.
* **IMPORTANT** :: None of these functions have C interfaces the way there are for LAPACK via LAPACKE. 
Therefore, you must take care to pass all variables by address, not by value and store all your data 
in FORTRAN-style, i.e. column-major format not row-major.

## Getting process block size with numroc

The `numroc` function is useful in almost every scalapack function. It computes the number of rows 
and columns of a distributed matrix owned by the process (the return value). Here's an explanation 
alongwith the prototype:
``` cpp
int numroc_(
    const int *n, // (global) the number of rows/cols in dist matrix
    const int *nb, // (global) block size. size of blocks the distributed matrix is split into.
    const int *iproc, // (local input) coord of the process whose local array row is to be determined.
    const int *srcproc, // (global input) coord of the process that has the first row/col of distributed matrix.
    const int *nprocs // (global input) total no. of processes over which the matrix is distributed.
);
```

### Usage of numroc

Pass the row or column number of the current matrix block in order to obtain the total
number of rows/columns of the full matrix that will be contained in the process. For example,
say you have a matrix of size `16384` that you want to split into blocks of `512` and distribute
them over 9 processes. This will lead to an uneven splitting and will therefore require careful
calculation of the number of elements.

The correct way to obtain the total elements that exist on each process would be as follows:
``` cpp
int N = 16384, NB = 512;
int rsrc = 0, csrc = 0;
int nprow = 3, npcol = 3;

int np = numroc_(&N, &NB, &myrow, &rsrc, &nprow);
int nc = numroc_(&N, &NB, &mycol, &csrc, &npcol);

std::cout << "ipr: " << proc_id << " np: " << np << " nc: " << nc << std::endl;

// ipr: 6 np: 5120 nc: 5632
// ipr: 5 np: 5632 nc: 5120
// ipr: 3 np: 5632 nc: 5632
// ipr: 7 np: 5120 nc: 5632
// ipr: 2 np: 5632 nc: 5120
// ipr: 4 np: 5632 nc: 5632
// ipr: 8 np: 5120 nc: 5120
// ipr: 0 np: 5632 nc: 5632
// ipr: 1 np: 5632 nc: 5632
```

## Checking where an element exists with indxg2p

You can check which process a given global co-ordinate exists on using the `indxg2l_()` function.
This function returns the process number of the element. Usage example:
``` cpp
int l = 513, NB = 512, rsrc = 0;
int p = indxg2p_(&l, &NB, &myrow, &rsrc, &nprocs);
```
Docs: http://www.netlib.org/scalapack/explore-html/d6/d88/indxg2p_8f_source.html

## Obtain local co-oridnates using indxg2l

You can pass global co-ordinates along with process co-ordinates to the `indxg2l_()` function
in order to obtain the local co-ordinates of the data element. A sample usage is like so:

Docs: http://www.netlib.org/scalapack/explore-html/d9/de1/infog2l_8f_source.html

## Errors

Scalapack reports errors using the XERBLA error handler. Here's some resources for this:
* [Invalid arguments and XERBLA.](http://www.netlib.org/scalapack/slug/node151.html#SECTION04751000000000000000)
* [Common errors in calling ScaLAPACK routines.](http://www.netlib.org/scalapack/slug/node149.html#seccommonerrors)

## Linking and compiling

If you're using an intel MKL distribution, use their [linker options tool](https://software.intel.com/sites/products/mkl/mkl_link_line_advisor.htm) for knowing
exact link options.

Take care to link with the `_lp64` libraries since they treat integers as 32 bit and that's what you want for scalapack. This link [offers some explanation](https://software.intel.com/en-us/forums/intel-math-kernel-library/topic/283403).

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

In the above prototype, `m` signifies the number of rows of the submatrix, meaning
the matrix that is present in the current process. Similarly for `n` in case of cols.

A function `descinit_` can be used for initializing the descriptor array. Its prototype is as
follows:
``` cpp
void descinit_(int *desc, const int *m,  const int *n, const int *mb, 
    const int *nb, const int *irsrc, const int *icsrc, const int *ictxt, 
    const int *lld, int *info);
```
In the `descinit_`, the `MB` and `NB` parameters signify the size of the block into which the
matrix is divided. Not the size of the block that each process will receive. See the `sync_lu`
code for an [example](https://github.com/v0dro/scratch/tree/master/c_shizzle/parallel/sync_lu) of block cyclic LU decomposition.

The `ipiv` array is not a synchronized data struture - it will be different for each process.
According to the docs, `ipiv(i)` is the global row local row i was swapped with. This array 
is tied to the distributed matrix A.

## Storage in the arrays

Each local array of a process should store a part of the global matrix. The global matrix is stored
in a block cyclic manner and scalapack reads each local array expecting it in a particular format.
It is important to be aware of this.

See [this](http://netlib.org/scalapack/slug/node28.html) explanation on the scalapack site to get a complete understanding. [This](http://netlib.org/scalapack/slug/node35.html) link has resources
on data distribution in scalapack in general.

For example, say you have a `1024 x 1024` matrix which you want to distribute on a 3x3 grid of 9 processes.

# Resources

* [Intel Q and A on numroc](https://software.intel.com/en-us/forums/intel-math-kernel-library/topic/288028)
* [Numroc fortran docs](http://www.netlib.org/scalapack/explore-html/d4/d48/numroc_8f_source.html) 
* [Using PBLAS/ScaLAPACK in your C code by intel (MKL specific)](https://software.intel.com/en-us/articles/using-cluster-mkl-pblasscalapack-fortran-routine-in-your-c-program) 

