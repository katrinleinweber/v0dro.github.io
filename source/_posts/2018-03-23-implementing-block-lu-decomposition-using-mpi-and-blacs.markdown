---
title: Implementing block LU decomposition using MPI and BLACS
date: 2018-03-23T18:42:53+09:00
---

Recently I was tasked with implemented a block LU decomposition in parallel using a block cyclic process distribution using BLACS and MPI.

In this post I would like to document my learnings about desinging the parallel algorithm and installing the various libraries that are required for this purpose. Hopefully, the reader will find something useful in this post too.

The blog post is divided into the following parts:

# Installing libraries

For this computation, we use MPICH and [BLACS](). While MPICH is easily installable on most GNU/Linux distributions, the same cannot be said for BLACS.

I first tried downloading [BLACS sources]() and compiling the library, however it gave too many compilation errors and was taking a long time to debug. Therefore, I resorted to using the [ScaLAPACK installer](), which is a Python script that downloads the sources of BLACS, LAPACK and ScaLAPACK, compiles all these libraries on your system and produces a single shared object file `libscalapack.a` which you can use for linking with your program. Since BLACS is included in the ScaLAPACK distribution, you can use the scalapack binary directly for linking.

Just download the ScaLAPACK installer from the website and follow the instructions in the README for quick and easy installation.

# Designing the algorithm

## Asynchronous block LU

One problem that I faced when designing the algorithm is that when writing a CBLACS program, you are basically writing the same code that is being run on multiple processes, however the data that is stored in variables is not the same for each process.

So it becomes important to write the program in such a way that maximum data is shared between the processes but there is minimmum communication of things like the block that is currently under process.

If it is a diagonal block, it simply factorizes the block into L & U parts and broadcasts it to rows and columns.

If it is a row or column block, it listens for the broadcast from the diagonal block and mutliplies the contents that it receives with the data it posseses. It then broadcasts the multiplied matrix block accross the lower right block so that the block can be reduced.

It can be expressed with this line of code:
``` cpp
p2p_recv(recv_block, blocksize, rows[index] % N, rows[index] % N);
```

The source row and source col arguments (last two) are computed by keeping in mind that we can compute the diagonal block of a particular block if we know the absolute row number of the block. 

If is a block in the right lower block of the matrix (the A^ block), it waits for the broadcast from the row and column elements, multiplies the received data with the stored data and over writes the stored data.

The computation and communication is mostly asynchronous. This means that there needs to be some kind of a trigger to launch the computation or communication tasks in a given process. 

A major problem is synchronization of successive diagonal matrix blocks. The computation must proceed from the top left corner of the matrix until the lower right corner. For this to work properly it is important that the diagonal blocks do not compute and send their data unless the diagonal block to the upper left of the block has finished computing.

## Synchronous block LU

## Resources

Some resources that I found during this phase are as follows:
* [Designing and building parallel programs.](http://www.mcs.anl.gov/~itf/dbpp/)
* [Introduction to Parallel Computing.](http://www-users.cs.umn.edu/~karypis/parbook/)
* [Designing parallel programs course.](https://computing.llnl.gov/tutorials/parallel_comp/#Designing)
* [Lecture on parallel Gaussian from Berkeley](http://people.eecs.berkeley.edu/~demmel/cs267/lecture12/lecture12.html).
* [Parallelizing LU factorization.](https://cseweb.ucsd.edu/classes/sp07/cse262/Projects/260_fa06/Ricketts_SR.pdf) 

# Implementation with MPI

Each process should hold only the part of the matrix that it is working upon.

## Reading block cyclic matrices with MPI IO

[This](https://stackoverflow.com/questions/10341860/mpi-io-reading-and-writing-block-cyclic-matrix#_=_) answer on stack overflow is pretty detailed for this purpose. Since the answer is in FORTRAN, I'll explain with some C code and how I went about this.

A very cumbersome way of reading a row-major matrix from a file into an MPI process is to read individual chunks one by one in a block cyclic manner in a loop. A better way is to use the [MPI darray type](https://www.mpich.org/static/docs/v3.1/www3/MPI_Type_create_darray.html) that is useful for reading chunks of the file directly without writing too much code. MPI lets you define a 'view' of a file and each process can just read its part of the view. It lets you define "distributed array" data types which you can use for directly reading a matrix stored in a file into memory in a block cyclic manner accoridng to the co-ordinates of the processor. We use the `MPI_Type_create_darray` [function](http://mpi.deino.net/mpi_functions/MPI_Type_create_darray.html) for this purpose.

Here's a sample usage of this function for initializing a `darray`:
``` c
MPI_Status status;
MPI_Datatype MPI_darray;
int N = 8, nb = 4;
int dims[2] = {N, N};
int distribs[2] = {MPI_DISTRIBUTE_CYCLIC, MPI_DISTRIBUTE_CYCLIC};
int dargs[2] = {nb, nb};

MPI_Type_create_darray(
    num_procs, 
    proc_id, 
    2, 
    dims, 
    distribs, 
    dargs,
    proc_dims, 
    MPI_ORDER_C, 
    MPI_INT, 
    &MPI_darray
);
MPI_Type_commit(&MPI_darray);
MPI_Type_size(MPI_darray, &darray_size);
nelements = darray_size / 4;
MPI_Type_get_extent(MPI_darray, &lower_bound, &darray_extent);
```

For reading a file in MPI, you need to use the `MPI_File_*` functions. This involves opening the file like any other normal file, but that file is handled internally by MPI. You need to set a 'view' for the file for each MPI process, and then the process can 'seek' the appropriate location in the file and read the required data.

The following code in useful for this purpose:
``` c

```

Note on `MPI_File_set_view`: this function is used for setting a 'file view' for each process so that the process knows where to start the data reading from. 

A full program for performing a matrix multiplication using PBLAS and BLACS using a block cyclic data distribution can be found [here]().

# Implementation with BLACS

Documentation for BLACS and PBLAS is sparse, so I used the following resources:
* [Intel MKL BLACS resources](https://software.intel.com/en-us/mkl-developer-reference-c-blacs-routines).
* [Blog post detailing use of BLACS for scatter operations.](https://andyspiros.wordpress.com/2011/07/08/an-example-of-blacs-with-c/)
* [Netlib BLACS reference](http://www.netlib.org/blacs/BLACS/QRef.html#BS).
* [BLACS array-based communication](http://www.netlib.org/blacs/BLACS/Array.html).
* [BLACS user manual](http://www.netlib.org/lapack/lawnspdf/lawn94.pdf). 
* [BLACS communication topologies](http://www.netlib.org/blacs/BLACS/Top.html).
* [Using PBLAS for matrix multiplication.](https://scicomp.stackexchange.com/questions/1688/how-do-i-use-scalapack-pblas-for-matrix-vector-multiplication) 
* [PBLAS rountines overview from Intel.](https://software.intel.com/en-us/mkl-developer-reference-c-pblas-routines-overview)
* [ScaLAPACK pdgemm matrix multiplication example.](http://www.nersc.gov/users/software/programming-libraries/math-libraries/libsci/libsci-example/) 
* [Presentation about Scalapack/PBLAS/BLACS with good details on usage.](http://www.training.prace-ri.eu/uploads/tx_pracetmo/scalable_linear_algebra.pdf) 
* [Block cyclic data distribution (netlib).](http://www.netlib.org/utk/papers/scalapack/node8.html)

## Block cyclic data distribution

The block cyclic distribution is a central idea in the case of PBLAS and BLACS.

## BLACS protips

Similar to MPI, BLACS contains some routines for sending and receiving data in a point-to-point manner. They are as below:
* `gesd2d`: This routine is for point-to-point sending of data from one process to another. This routine is non-blocking by default (unlike `MPI_Send` which is blocking). It's prototype for the C interface is as follows:
``` cpp
void Cdgesd2d(
    int CBLACS_CONTEXT, // CBLACS context
    int M, // row size of matrix block
    int N, // col size of matrix block
    double* A, // pointer to matrix block
    int LDA, // leading dim of A (col size for C programs)
    int RDEST, // row number of destination process
    int CDEST // col number of destination process
);
```
* `trsd2d`: This routine is used for point-to-point sending of trapezoidal matrices.
* `gerv2d`: This routine is used for point-to-point receiving of general rectangular matrices. This routine will block until the message is received. Its prototype looks like so:
``` cpp
void Cdgerv2d(
    int CBLACS_CONTEXT, // CBLACS context
    int M, // row size of matrix block
    int N, // col size of matrix block
    double *A, // pointer to matrix data.
    int LDA, // leading dim of A (col size for C)
    int RSRC, // process row co-ordinate of the sending process.
    int CSRC // process col co-ordinate of the sending process.
);
```

For broadcast receive, there is the `gebr2d` routine. This routine is particularly useful since it can broadcast over all processes, or a specific row or column. This can be helpful over using MPI directly since it allows us to easily broadcast over rows or columns without having to define separate communicators.

The prototype of this routine is as follows:
``` cpp
// Cd stands for 'C double'
// ge is 'general rectangular matrix'
// br is 'broadcast receive'
Cdgebr2d(
    int CBLACS_CONTEXT, // CBLACS context
    char* SCOPE, // scope of the broadcast. Can be "Row", "Column" or "All"
    char* TOP, // indicates communication pattern to use for broadcast.
    int M, // number of rows of matrix.
    int N, // number of columns of matrix.
    double* A, // pointer to matrix data.
    int LDA, // leading dim of matrix (col size for C)
    int RSRC, // process row co-ordinate of the process who called broadcast/send.
    int CSRC // process column co-ordinate of the process who called broadcast/send.
);
```

For broadcast send, there is the `gebs2d` routine. This is helpful for receiving broadcasts. The prototype of this function is as follows:
``` cpp
Cdgebs2d(
    int CBLACS_CONTEXT, // CBLACS context.
    char* SCOPE, // scope of broadcast. can be "All", "Row" or "Column".
    char* TOP, // network topology to be used.
    int M, // num of rows of the matrix.
    int N, // num of cols of the matrix.
    double *A, // pointer to the matrix data.
    int LDA // leading dimension of A.
);
```

## PBLAS protips

PBLAS (or Parallel BLAS) is a parallel version of BLAS that use BLACS internally for parallel computing. It expects the matrix to be already distributed among processors before it starts computing. You first create the data in each process and then provide PBLAS with information that will help it determine how exactly the matrix is distributed. Each process can access only its local data. You also need to define an 'array descriptor' for the matrix that you are working on. The array descriptor is an integer array of length 9 that contains the following data:
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
    const char *transa , // (g) form of sub(A)
    const char *transb , // (g) form of sub(B)
    const int *m , // (g) number of rows of sub(A) and sub(C)
    const int *n , // (g) number of cols of sub(B) and sub(C)
    const int *k , // (g) Number of cols of sub(A) and rows of sub(A)
    const double *alpha , //(g) scalar alpha
    // array that contains local pieces of distributed matrix sub(A). size lld_a by kla.
    //   kla is LOCq(ja+m-1) for C code (transposed).
    const double *a , // (l)
    const int *ia , // (g) row index in the distributed matrix A indicating first row of sub(A)
    const int *ja , // (g) col index in the distributed matrix A indicating first col of sub(A)
    const int *desca , // (g & l)array of dim 9. Array descriptor of A.
    // array that contains local pieces of dist matrix sub(B). size lld_b by klb.
    //   klb is LOCq(jb+k-1) for C code (transposed).
    const double *b , // (l)
    const int *ib ,  // (g) row index of dist matrix B indicating first row of sub(B)
    const int *jb ,  // (g) col index of dist matrix B indicating first col of sub(B)
    const int *descb , // (g & l) array desc of matrix B (dim 9).
    const double *beta , // (g) scalar beta
    double *c , // (l) Array of size (lld_a, LOCq(jc+n-1)). contains sub(C) pieces.
    const int *ic , // (g) row index of dist matrix C indicating first row of sub(C)
    const int *jc , // (g) col index of dist matrix C indicating first col of sub(C)
    const int *descc // (g & l) array of dim 9. Array desc of C.
)
```

The above function looks very similar to non-parallel `dgemm` from BLAS, with additions for making it easy to find elements in a parallel scenario. Some particular elements of the function deserve special mention:
* 

A function called `numroc` from ScaLAPACK is useful for determining how many rows or cols of the global matrix are present in a particular process. The prototype looks as follows:
``` cpp
int numroc_(
    const int *n, // (g) number of rows/cols in dist matrix (global matrix).
    const int *nb, // (g input) block size. (must be square blocks)
    const int *iproc, // (l input) co-ordinate of process whole local array row/col is to be determined.
    const int *srcproc, // (g input) co-ordinate of the process that contains the frist row or col of the dist matrix.
    const int *nprocs // (g input) total number of processes.
)
```

A simple implementation of matrix multiplication using BLACS and PBLAS can be found [here](URL). 

## Asynchronous block LU

## Synchronous block LU

In the asynchronous LU, it is assumed that the block size is equal to the processor size, i.e each block of the matrix is limited to only a single processor.

For synchronous LU decomposition, we take blocks which are spread out over multiple processors. To illustrate, see the below figure:

Four of the above colors represent a single block and each color represents a process.
