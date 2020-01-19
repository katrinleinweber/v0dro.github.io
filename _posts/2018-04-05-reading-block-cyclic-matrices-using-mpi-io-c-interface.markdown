---
title: Reading block cyclic matrices using MPI-IO C interface.
date: 2018-04-05T13:44:15+09:00
---


[This](https://stackoverflow.com/questions/10341860/mpi-io-reading-and-writing-block-cyclic-matrix#_=_) answer on stack overflow is pretty detailed for this purpose. Since the answer is in FORTRAN, I'll explain with some C code and how I went about this.

A very cumbersome way of reading a row-major matrix from a file into an MPI process is to read individual chunks one by one in a block cyclic manner in a loop. A better way is to use the [MPI darray type](https://www.mpich.org/static/docs/v3.1/www3/MPI_Type_create_darray.html) that is useful for reading chunks of the file directly without writing too much code. MPI lets you define a 'view' of a file and each process can just read its part of the view. It lets you define "distributed array" data types which you can use for directly reading a matrix stored in a file into memory in a block cyclic manner accoridng to the co-ordinates of the processor. We use the `MPI_Type_create_darray` [function](http://mpi.deino.net/mpi_functions/MPI_Type_create_darray.html) for this purpose.

Here's a sample usage of this function for initializing a `MPI_darray`:
``` c
MPI_Status status;
MPI_Datatype MPI_darray;
int N = 8, nb = 4;
int dims[2] = {N, N};
int distribs[2] = {MPI_DISTRIBUTE_CYCLIC, MPI_DISTRIBUTE_CYCLIC};
int dargs[2] = {nb, nb};
int proc_nrows = 2, proc_ncols = 2;
int proc_dims[2] = {proc_nrows, proc_ncols};

MPI_Type_create_darray(
    num_procs, // size of process group (positive integer)
    proc_id, // rank in process group (non-negative integer)
    2, // 	number of array dimensions as well as process grid dimensions (positive integer)
    dims, // number of elements of type oldtype in each dimension of global array (array of positive integers)
    distribs, // distribution of array in each dimension (array of state)
    dargs, // distribution argument in each dimension (array of positive integers)
    proc_dims, // size of process grid in each dimension (array of positive integers)
    MPI_ORDER_C, // array storage order flag (state)
    MPI_INT, // old datatype (handle)
    &MPI_darray // new datatype (handle)
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

Sometimes reading from files can give divide-by-zero errors, 

Note on `MPI_File_set_view`: this function is used for setting a 'file view' for each process so that the process knows where to start the data reading from. In case you're using `MPI_File_read_all` you should know that the file pointer is set implicitly and you don't need to explicitly supply an offset value. The file pointer for the current view is set based on what the process previous to this process accessed.

A full program for performing a matrix multiplication using PBLAS and BLACS using a block cyclic data distribution can be found [here](). Some more docs are [here](http://mpi-forum.org/docs/mpi-2.2/mpi22-report/node73.htm).
