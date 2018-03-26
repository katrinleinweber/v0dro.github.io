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

# Implementation with MPI

Each process should hold only the part of the matrix that it is working upon.

# Implementation with BLACS
