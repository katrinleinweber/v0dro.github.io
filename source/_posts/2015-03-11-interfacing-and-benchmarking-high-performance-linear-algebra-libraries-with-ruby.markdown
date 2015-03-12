---
layout: post
title: "Interfacing and benchmarking high performance linear algebra libraries with Ruby"
date: 2015-03-11 13:35:45 +0530
comments: true
categories: 
---

For my GSOC project, I'm trying to build an extension to NMatrix which will interface with a high performance C library for fast linear algebra calculations. Since one of the major problems affecting the usability and portability of NMatrix is the effort taken for installation (adding/removing dependencies etc.), it is imperative to ship the source of this high performance C library alongwith the ruby gem.

This leaves us with quite a few choices about the library that can be used. The most common and obvious interfaces for performing fast linear algebra calculations are LAPACK and BLAS. Thus the library bundled with the nmatrix extension must expose an interface similar to LAPACK and BLAS. Since ruby running on MRI can only interface with libraries having a C interface, the contenders in this regard are CLAPACK or LAPACKE for a LAPACK in C, and openBLAS or ATLAS for a BLAS interface.

I need to choose an appropriate BLAS and LAPACK interface based on its speed and usability, and to do so, I decided to build some quick ruby interfaces to these libraries and benchmark the [`?gesv` function](https://software.intel.com/en-us/node/520973)  (used for solving _n_ linear equations in _n_ unknowns) present in all LAPACK interfaces, so as to get an idea of what would be the fastest. This would also test the speed of the BLAS implemetation since LAPACK primarily depends on BLAS for actual computations.

To create these benchmarks, [I made a couple of simple ruby gems](<link>) which linked against the binaries of these libraries. Both these gems [define a module](<link>) which contains a method `solve_gesv`, which [calls the C extension that interfaces with the C library](<link>). Each library was made in its own little ruby gem so as to nullify any unknown side effects and also to provide more clarity.

To test these libraries against each other, I used the following test code:

``` ruby

    require 'benchmark'

    Benchmark.bm do |x|
      x.report do
        10000.times do
          a = NMatrix.new([3,3], [76, 25, 11,
                                  27, 89, 51,
                                  18, 60, 32], dtype: :float64)
          b = NMatrix.new([3,1], [10,
                                   7,
                                  43], dtype: :float64)
          NMatrix::CLAPACK.solve_gesv(a,b)
          # The `NMatrix::CLAPACK` is replaced with NMatrix::LAPACKE when using the LAPACKE interface instead of CLAPACK.
        end
      end
    end
```

Here I will list the libraries that I used, the functions I interfaced with, the pros and cons of using each of these libraries, and of course the reported benchmarks:

### LAPACK interface CLAPACK (netlib) compiled against CBLAS from openBLAS

[CLAPACK](http://www.netlib.org/clapack/) is an F2C'd version of the original LAPACK written in FORTRAN. The creators have made some changes by hand because f2c spews out unnecessary code at times, but otherwise its pretty much as fast as the original LAPACK.

To interface with a BLAS implementation, CLAPACK uses a blas wrapper (blaswrap) to generate wrappers to the relevant CBLAS functions exposed by any BLAS implementation. The blaswrap source files and F2C source files are provided with the CLAPACK library.

The BLAS implementation that we'll be using is [openBLAS](http://www.openblas.net/), which is a very stable and tested BLAS exposing a C interface. It is extremely simple to use and install, and configures itself automatically according to the computer it is being installed upon. It claims to achieve [performance comparable to intel MKL](http://en.wikipedia.org/wiki/GotoBLAS), which is phenomenal.

To compile CLAPACK with openBLAS, do the following:
* `cd` to your openBLAS directory and run `make NO_LAPACK=1`. This will create an openBLAS binary with the object files only for CBLAS. LAPACK will not be compiled even though the source is present. This will generate a `.a` file which has a name that is similar to the processor that your computer uses. Mine was `libopenblas_sandybridgep-r0.2.13.a`.
* Now rename the openBLAS binary file to `libopenblas.a` so its easier to type and you lessen your chances of mistakes, and copy to your CLAPACK directory.
* `cd` to your CLAPACK directory and open the `make.inc` file in your editor. In it, you should find a `BLASDIR` variable that points to the BLAS files to link against. Change the value of this variable to `../../libopenblas.a`.
* Now run `make f2clib` to make F2C library. This is needed for interconversion between C and FORTRAN data types.
* Then run `make lapacklib` to compile CLAPACK against your specified implementation of CBLAS (openBLAS in this case).
* At the end of this process, you should end up with the CLAPACK, F2C and openBLAS binaries in your directory.

Since the automation of this compilation process would take time, I copied these binaries to the gem and [wrote the extconf.rb]() such that they link with these libraries.

On testing this with a ruby wrapper, the benchmarking code listed above yielded the following results:

```

    user     system      total        real
    0.190000   0.000000   0.190000 (  0.186355)

```
### LAPACK interface LAPACKE compiled against CBLAS from openBLAS

[LAPACKE](http://www.netlib.org/lapack/lapacke.html) is the 'official' C interface to the FORTRAN-written LAPACK. It consists of two levels; a high level C interface for use with C programs and a low level one that talks to the original FORTRAN LAPACK code. This is not just an f2c'd version of LAPACK, and hence the design of this library is such that it is easy to create a bridge between C and FORTRAN. 

For example, C has arrays stored in row-major format while FORTRAN had them column-major. To perform any computation, a matrix needs to be transposed to column-major form first and then be re-transposed to row-major form so as to yield correct results. This needs to be done by the programmer when using CLAPACK, but LAPACKE's higher level interface accepts arguments ([LAPACKE_ROW_MAJOR or LAPACKE_COL_MAJOR](http://www.netlib.org/lapack/lapacke.html#_array_arguments)) which specify whether the matrices passed to it are in row major or column major format. Thus extra (often unoptimized code) on part of the programmer for performing the tranposes is avoided.

To build binaries of LAPACKE compiled with openBLAS, just `cd` to your openBLAS source code directory and run `make`. This will generate a `.a` file with the binaries for LAPACKE and CBLAS interface of openBLAS.

LAPACKE benchmarks turn out to be faster mainly due to the absence of [manual transposing by high-level code written in Ruby](<link>)  (the [NMatrix#tranpose](https://github.com/SciRuby/nmatrix/blob/master/lib/nmatrix/nmatrix.rb#L535) function in this case). I think performing the tranposing using openBLAS functions should remedy this problem.

The benchmarks for LAPACKE are:

```

    user     system      total        real
    0.150000   0.000000   0.150000 (  0.147790)

```

As you can see these are quite faster than CLAPACK with openBLAS, listed above.