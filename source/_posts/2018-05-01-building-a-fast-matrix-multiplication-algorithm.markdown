---
title: Building a FAST matrix multiplication algorithm.
date: 2018-05-01T16:02:40+09:00
---

I've received an assignment for writing a very fast matrix multiplication code using
multithreading, BLISLAB, SIMD, etc. In this post I will document my approach to writing
this code. I've made the best effort to optimize the multiplication to the hilt, but if
readers find anything amiss please leave a comment and I'll have a look at it ASAP.

I've written various benchmarks and machines that the codes were tested on.

# Testing machine

A Xeon server with the following specs was used for this assignment:

Final output of `cat /proc/cpuinfo`
```
processor	: 255
vendor_id	: GenuineIntel
cpu family	: 6
model		: 87
model name	: Intel(R) Xeon Phi(TM) CPU 7210 @ 1.30GHz
stepping	: 1
microcode	: 0x130
cpu MHz		: 999.993
cache size	: 1024 KB
physical id	: 0
siblings	: 256
core id		: 71
cpu cores	: 64
apicid		: 287
initial apicid	: 287
fpu		: yes
fpu_exception	: yes
cpuid level	: 13
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc ring3mwait aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 fma cx16 xtpr pdcm sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch epb tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms avx512f rdseed adx avx512pf avx512er avx512cd xsaveopt dtherm ida arat pln pts
bugs		:
bogomips	: 2599.91
clflush size	: 64
cache_alignment	: 64
address sizes	: 46 bits physical, 48 bits virtual
power management:
```

Top output of `cat /proc/meminfo`:
```
MemTotal:       32779100 kB
MemFree:        19654852 kB
MemAvailable:   30516552 kB
Buffers:          633352 kB
Cached:          9975356 kB
SwapCached:            0 kB
```

# Matrix parameters

For this experiment, I'm using a 1000x1000 matrix of doubles, each matrix generated 
using a simple function `i*j + N`.

# The initial code

I started off with a basic O(N^3) multiplication algorithm that looks like this:
``` cpp
for (int i=0; i<N; i++) {
  for (int j=0; j<N; j++) {
    for (int k=0; k<N; k++) {
      C[i*N + j] += A[i*N + k] * B[k*N + j];
    }
  }
}
```

This produced the following results:
```
N = 1000. time: 57.6367 s. Gflops: 0.0347001
```
Very slow indeed. Lets begin some optimization.

# BLAS benchmarks

Using the BLAS `dgemm` function for the same matrix produces the following:
```
N = 1000. time: 4.3823 s. Gflops: 0.456381
```
That's much faster than the original, but there's still much more scope for improvment.

# Loop interchange

It so happens that when we write a simple 3-level loop for matmul where the result is obtained
one element at a time, we need to access the elements in a manner that does not produce the
same stride and is not therefore easily vectorizable. If the loops are interchanged they
will all become stride-1.

The new loop structure would look like this:
```
for i = 0:N
  for k = 0:N
    for j = 0:N
      C(i,j) = A(i,k)*B(k,j)
```
This simple optimization gives somewhat faster results:
```
N = 1000. time: 51.6079 s. Gflops: 0.0387538
```

This mainly happens because now most elements are accessed in order of memory and there are
less cache misses. The cache loading/unloading is done by the OS and compiler until this
step and we have not intervened with these things at all.

# Multithreading optimization

Using the `for` loop openmp threading directive led to a pretty massive speedup. Here's the
results with a `#pragma openmp parallel for` for the above stride-oriented code:
```
N = 1000. time: 0.815704 s. Gflops: 2.45187
```
This is faster than gemm! Wonder what does dgemm do internally that causes it to not
fully exploit the resources of the CPU.

How exactly does the omp for loop parallelization work?

# Blocking

In general, it is helpful to compute the matrix in blocks rather than individually so that
we can take advantage of various vector operations and cache blocking.

# Using pointers

When you call something like `C[i*N + j]` for getting the value in memory of an element in C,
you are wasting time in calculating the address of the element in C where it resides. Instead,
you directly use pointers to advance the pointer value in memory rather than such explicit
calculation.

For example, to set the value of all elements of an array C to 0:
```
double *cp;
for ( j = 0; j < n; j ++ ) { 
  cp = &C[ j * ldc ];
  for ( i = 0; i < m; i ++ ) { 
    *cp++ = 0.0;
  }
}
```

Using pointers with the above implementation produces the following result:

# Loop unrolling

Slight modifications to the loops which involves unrolling some part of the loop and advancing
at a faster pace than one increment per loop iteration can reduce the overhead of updating the
variables associated with looping. Also, there is a special advantage to advancing the loop
counter by a factor of 4 (for double numbers). The data is brought into the cache line 64 bytes
at a time. This means that accessing data in chunks of 64 bytes reduces the cost of memory
movement between the memory layers.

# BLISlab

BLISlab provides a framework for efficiently implementing your own version of BLAS. This is
particularly handy for people who want to implement a BLAS of their own on any machine.



# Results on TSUBAME

# Papers

* BLISlab paper: sandbox for optimizing BLAS.
* Anatomy of high performance matrix multiplication.
* Anatomy of high-performance many-threaded matrix multiplication.

## Brief paper summaries

### Anatomy of high performance matrix multiplication

This paper describes what is currently accepted as the most effective approach,
to implementation, also known as the GotoBLAS approach.

# Resources

* http://jguillaumes.dyndns.org/doc_intel/f_ug/vect_int.htm
* [sgemm does not multithread sometimes.](https://stackoverflow.com/questions/25475186/sgemm-does-not-multithread-when-dgemm-does-intel-mkl) 
* [Structure packing in C.](http://www.catb.org/esr/structure-packing/) 
