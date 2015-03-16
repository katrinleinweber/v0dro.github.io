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

To create these benchmarks, [I made a couple of simple ruby gems](https://github.com/v0dro/scratch/tree/master/ruby_c_exp) which linked against the binaries of these libraries. All these gems [define a module](https://github.com/v0dro/scratch/blob/master/ruby_c_exp/nm_lapacke/lib/nm_lapacke.rb) which contains a method `solve_gesv`, which calls the C extension that interfaces with the C library. Each library was made in its own little ruby gem so as to nullify any unknown side effects and also to provide more clarity.

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
      # The `NMatrix::CLAPACK` is replaced with NMatrix::LAPACKE 
      # or NMatrix::LAPACKE_ATLAS as per the underlying binding. Read the
      # source code for more details.
    end
  end
end
```

Here I will list the libraries that I used, the functions I interfaced with, the pros and cons of using each of these libraries, and of course the reported benchmarks:

### CLAPACK (LAPACK) with openBLAS (BLAS)

[CLAPACK](http://www.netlib.org/clapack/) is an F2C'd version of the original LAPACK written in FORTRAN. The creators have made some changes by hand because f2c spews out unnecessary code at times, but otherwise its pretty much as fast as the original LAPACK.

To interface with a BLAS implementation, CLAPACK uses a blas wrapper (blaswrap) to generate wrappers to the relevant CBLAS functions exposed by any BLAS implementation. The blaswrap source files and F2C source files are provided with the CLAPACK library.

The BLAS implementation that we'll be using is [openBLAS](http://www.openblas.net/), which is a very stable and tested BLAS exposing a C interface. It is extremely simple to use and install, and configures itself automatically according to the computer it is being installed upon. It claims to achieve [performance comparable to intel MKL](http://en.wikipedia.org/wiki/GotoBLAS), which is phenomenal.

To compile CLAPACK with openBLAS, do the following:

* `cd` to your openBLAS directory and run `make NO_LAPACK=1`. This will create an openBLAS binary with the object files only for BLAS and CBLAS. LAPACK will not be compiled even though the source is present. This will generate a `.a` file which has a name that is similar to the processor that your computer uses. Mine was `libopenblas_sandybridgep-r0.2.13.a`.
* Now rename the openBLAS binary file to `libopenblas.a` so its easier to type and you lessen your chances of mistakes, and copy to your CLAPACK directory.
* `cd` to your CLAPACK directory and open the `make.inc` file in your editor. In it, you should find a `BLASDIR` variable that points to the BLAS files to link against. Change the value of this variable to `../../libopenblas.a`.
* Now run `make f2clib` to make F2C library. This is needed for interconversion between C and FORTRAN data types.
* Then run `make lapacklib` from the CLAPACK root directory to compile CLAPACK against your specified implementation of CBLAS (openBLAS in this case).
* At the end of this process, you should end up with the CLAPACK, F2C and openBLAS binaries in your directory.

Since the automation of this compilation process would take time, I copied these binaries to the gem and [wrote the extconf.rb]() such that they link with these libraries.

On testing this with a ruby wrapper, the benchmarking code listed above yielded the following results:

```

    user     system      total        real
    0.190000   0.000000   0.190000 (  0.186355)
```

### LAPACKE (LAPACK) compiled with openBLAS (BLAS)

[LAPACKE](http://www.netlib.org/lapack/lapacke.html) is the 'official' C interface to the FORTRAN-written LAPACK. It consists of two levels; a high level C interface for use with C programs and a low level one that talks to the original FORTRAN LAPACK code. This is not just an f2c'd version of LAPACK, and hence the design of this library is such that it is easy to create a bridge between C and FORTRAN. 

For example, C has arrays stored in row-major format while FORTRAN had them column-major. To perform any computation, a matrix needs to be transposed to column-major form first and then be re-transposed to row-major form so as to yield correct results. This needs to be done by the programmer when using CLAPACK, but LAPACKE's higher level interface accepts arguments ([LAPACKE_ROW_MAJOR or LAPACKE_COL_MAJOR](http://www.netlib.org/lapack/lapacke.html#_array_arguments)) which specify whether the matrices passed to it are in row major or column major format. Thus extra (often unoptimized code) on part of the programmer for performing the tranposes is avoided.

To build binaries of LAPACKE compiled with openBLAS, just `cd` to your openBLAS source code directory and run `make`. This will generate a `.a` file with the binaries for LAPACKE and CBLAS interface of openBLAS.

LAPACKE benchmarks turn out to be faster mainly due to the absence of [manual transposing by high-level code written in Ruby](https://github.com/v0dro/scratch/blob/master/ruby_c_exp/nm_clapack/lib/nm_clapack.rb#L7)  (the [NMatrix#transpose](https://github.com/SciRuby/nmatrix/blob/master/lib/nmatrix/nmatrix.rb#L535) function in this case). I think performing the tranposing using openBLAS functions should remedy this problem.

The benchmarks for LAPACKE are:

```

    user     system      total        real
    0.150000   0.000000   0.150000 (  0.147790)
```

As you can see these are quite faster than CLAPACK with openBLAS, listed above.

### CLAPACK(LAPACK) with ATLAS(BLAS)

This is the combination that is currently in use with nmatrix. It involves installing the `libatlas-base-dev` package from the Debian repositories. This pacakage will load all the relevant clapack, atlas, blas and cblas binaries into your computer.

The benchmarks turned out to be:

```

    user     system      total        real
    0.130000   0.000000   0.130000 (  0.130056)
```

This is fast. But a big limitation on using this approach is that the CLAPACK library exposed by the `libatlas-base-dev` is outdated and no longer maintained. To top it all, it does not have all the functions that a LAPACK library is supposed to have.

### LAPACKE(LAPACK) with ATLAS(BLAS)

For this test case I compiled [LAPACKE (downloaded from netlib)](http://www.netlib.org/lapack/lapacke) with an ATLAS implementation from the Debian repositories. I then included the generated static libraries in the sample ruby gem and compiled the gem against those.

To do this on your machine:
* Install the package `libatlas-base-dev` with your package manager. This will install the ATLAS and CBLAS shared objects onto your system.
* `cd` to the lapack library and in the `make.inc` file change the `BLASLIB = -lblas -lcblas -latlas`. Then run `make`. This will compile LAPACK with ATLAS installed on your system.
* Then `cd` to the lacpack/lapacke folder and run `make`.

Again the function chosen was `LAPACKE_?gesv`. This test should tell us a great deal about the speed differences between openBLAS and ATLAS, since tranposing overheads are handled by LAPACKE and no Ruby code is interfering with the benchmarks.

The benchmarks turned out to be:

```

    user     system      total        real
    0.140000   0.000000   0.140000 (  0.140540)
```

## Conclusion

As you can see from the benchmarks above, the approach followed by nmatrix currently (CLAPACK with ATLAS) is the fastest, but this approach has certain limitations:

* Requires installation of tedious to install dependencies.
* Many pacakages offer the same binaries, causing confusion.
* CLAPACK library is outdated and not maintained any longer.
* ATLAS-CLAPACK does not expose all the functions present in LAPACK.

The LAPACKE-openBLAS and the LAPACKE-ATLAS, though a little slower(~10-20 ms), offer a HUGE advantage over CLAPACK-ATLAS, viz. :

* LAPACKE is the 'standard' C interface to the LAPACK libraries and is actively maintained, with regular release cycles.
* LAPACKE is compatible with intel's MKL, in case a future need arises.
* LAPACKE bridges the differences between C and FORTRAN with a well thought out interface.
* LAPACKE exposes the entire LAPACK interface.
* openBLAS is trivial to install.
* ATLAS is a little non-trivial to install but is fast.

For a further explanation of the differences between these CBLAS, CLAPACK and LAPACKE, read [this](http://nicolas.limare.net/pro/notes/2014/10/31_cblas_clapack_lapacke/) blog post.
