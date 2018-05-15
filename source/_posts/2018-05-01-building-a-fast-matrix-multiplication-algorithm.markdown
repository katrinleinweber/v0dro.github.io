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
processor	: 15
vendor_id	: GenuineIntel
cpu family	: 6
model		: 79
model name	: Intel(R) Xeon(R) CPU E5-2637 v4 @ 3.50GHz
stepping	: 1
microcode	: 0xb000021
cpu MHz		: 2807.360
cache size	: 15360 KB
physical id	: 1
siblings	: 8
core id		: 3
cpu cores	: 4
apicid		: 23
initial apicid	: 23
fpu		: yes
fpu_exception	: yes
cpuid level	: 20
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid dca sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer xsave avx f16c rdrand lahf_lm abm 3dnowprefetch ida arat epb invpcid_single pln pts dtherm intel_pt kaiser tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm cqm rdseed adx smap xsaveopt cqm_llc cqm_occup_llc
bugs		:
bogomips	: 7002.86
clflush size	: 64
cache_alignment	: 64
address sizes	: 46 bits physical, 48 bits virtual
power management:
```

Top output of `cat /proc/meminfo`:
```
MemTotal:       65598536 kB
MemFree:        44152804 kB
MemAvailable:   55485324 kB
Buffers:              80 kB
Cached:         15153880 kB
SwapCached:         4144 kB
```

The CPU details for this chip can be found here: https://en.wikichip.org/wiki/intel/xeon_e5/e5-2637_v4

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
N = 1000. time: 4.53809 s. Gflops: 0.440714
```
Very slow indeed. Lets begin some optimization.

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
N = 1000. time: 3.29635 s. Gflops: 0.606731
```

This mainly happens because now most elements are accessed in order of memory and there are
less cache misses. The cache loading/unloading is done by the OS and compiler until this
step and we have not intervened with these things at all.

Here's the loop in code with comments as to movement of the pointer:
``` cpp
// corresponds to rowwise movement of C (slowest). Indicates
// that one panel (horizontal) of C is populated at one time.
for (int i = 0; i < N; i += NR) {
  // corresponds to column of A. Moves with the rows of B.
  for (int k = 0; k < N; k += KC) {
    // corresponds to the row of B. Moves with the columns of A.
    for (int j = 0; j < N; j += MC) {
      C[i*N + j] += A[i*N + k] * B[k*N + j];
    }
  }
}
```

# Loop unrolling

Slight modifications to the loops which involves unrolling some part of the loop and advancing
at a faster pace than one increment per loop iteration can reduce the overhead of updating the
variables associated with looping. Also, there is a special advantage to advancing the loop
counter by a factor of 4 (for double numbers). The data is brought into the cache line 64 bytes
at a time. This means that accessing data in chunks of 64 bytes reduces the cost of memory
movement between the memory layers.

After using a loop advacement of 5, the result improves to this:
```
N = 1000. time: 2.04914 s. Gflops: 0.976018
```

The code for doing this looks like so:
```
for (int i = 0; i < N; i += NR) {
  for (int k = 0; k < N; k += KC) {
    for (int j = 0; j < N; j += MC) { // advance by block size
      //macro_kernel(A, B, C, i, j, k);
      A_ptr = A[i*N + k];
      B_ptr = &B[k*N + j];
      C_ptr = &C[i*N + j];
        
      *C_ptr += (*A_ptr)  * (*B_ptr);
      *(C_ptr+1) += (*A_ptr) * (*(B_ptr+1));
      *(C_ptr+2) += (*A_ptr) * (*(B_ptr+2));
      *(C_ptr+3) += (*A_ptr) * (*(B_ptr+3));
      *(C_ptr+4) += (*A_ptr) * (*(B_ptr+4));
    }
  }
}
```

# Use of registers

You can use the C++ `register` keyword when declaring a variable in order to suggest to the
compiler that the variable is supposed to stay in the register.

These variables are best used in cases where the variable needs to be used as an accumulator
for storing the repeating sum of some result.

For example, the macro kernel can be written this way:
```
register double a0 = A(0,k), a1 = A(1,k), a2 = A(2,k), a3 = A(3,k);
  for (int j = 0; j < N; j += 1) {
    C(0,j) += a0*B(k,j);
    C(1,j) += a1*B(k,j);
    C(2,j) += a2*B(k,j);
    C(3,j) += a3*B(k,j);
  }
```
This results in the following result:
```
N = 1000. time: 2.2037 s. Gflops: 0.907564
```

# Blocking

In general, it is helpful to compute the matrix in blocks rather than individually so that
we can take advantage of various vector operations and cache blocking. A simple blocking
technique would be to compute a block of 4x4 matrix at one time. For this purpose we can
use SSE instructions that allow computing multiplications of multiple numbers in parallel.

We first start off by trying to multiply the matrix in 4x4 blocks. This can be done by
modifying the loops 

## Aligned memory allocation

The `posix_memalign` function allocates memory along a given alignment. Upon successful
completion, it returns a pointer value that is a multiple of the alignment variable. It
is helpful in cases where you want to use SIMD operations with a chunk of memory.

Source: http://pubs.opengroup.org/onlinepubs/009695399/functions/posix_memalign.html

## Notes on blocking

Q: If the numbers are stored in row major order anyway, what difference does it
make whether we use the packing order or the default row major order?
A: When multiplying the block of A with the panel of B, we proceed from left to
right of the panel. Due to this, the numbers of B get accessed in a stride and not in
sequentially. Packing would ensure that they are sequential.

## SIMD instructions

Intel introduced SIMD instructions in the their processors a while ago. These are now 
accessible via the AVX or SSE data types.

The AVX data types allow the use of 16 YMM registers. These can hold 4 x 64-bit double
numbers or 8 x 32-bit floats.

On the intel Broadwell CPU, there is support for AVX2 and SSE3 instruction sets. According
to intel, AVX is a natural progression of SSE.

### Notes on SIMD

SIMD is mainly expressed using two kinds of instructions: SSE and AVX. AVX works with a
kind of register called `YMM` registers. AVX uses 16 such registers. Each YMM register
contains 4 64-bit double-precision floating point numbers.

In order to use these instructions, you need to include the `xmmintrin.h` header file into
your code. Data that is to be used using SIMD needs to be packed using the `__m256d` if
using the YMM registers useful for AVX instructions. 


# Packing data into caches

According to the GotoBLAS (and later BLIS) approach, it is necessary to pack the panels of 
A and B in such a way that the data within is sequentially accessible. This requires some
reconstruction of each mini-panel before performing the actual computation.

The BLISlab framework uses a novel approach for this purpose. It first stores the pointers
of all the elements that need to be copied into a new array using an array to pointers of 
doubles. It then simply dereferences these pointers and copies them into the packed array.

Here's some C code that makes this happen:

``` cpp
int p; 
double *b_pntr[ SIZE ]; // create array of pointers of doubles.

// ... code that copies pointers of packed array to b_pntr

// deference b_pntr and copy data one by one to packB
for (p = 0; p < SIZE; p++) {
  *packB++ = *b_pntr[ p ] ++;
}
```

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

After using pointers in the matrix multplication, it looks like this:
```
N = 1000. time: 1.71545 s. Gflops: 1.16587
```

# Multithreading optimization

Using the `for` loop openmp threading directive led to a pretty massive speedup. Here's the
results with a `#pragma openmp parallel for` for the above stride-oriented code:
```
N = 1000. time: 0.815704 s. Gflops: 2.45187
```
This is faster than gemm! Wonder what does dgemm do internally that causes it to not
fully exploit the resources of the CPU.

How exactly does the omp for loop parallelization work?

Using pointers with the above implementation produces the following result:

# BLISlab

BLISlab provides a framework for efficiently implementing your own version of BLAS. This is
particularly handy for people who want to implement a BLAS of their own on any machine.

## BLISlab notes

In original BLISlab framework it is important to remember that the A matrix is stored
in row-major and B in column-major.

# Results on TSUBAME

# Notes on computer architecture

## Cache access

When the processor requests a particular chunk of memory, it is first copied into the cache
from the main memory (assuming that the cache is 'empty' for now). The closer the data is
from the processor, the fewer clock cycles it needs to wait for performing instructions. Every
time during a memory access, the processor first checks the cache for the data, and in case
the data is not present it will fetch the data from the memory. This is called a cache miss.
Data is copied into cache from the memory every time a cache miss occurs. It is assumed that 
data that is adjacent to data that is being used has a high probability of being accessed. This
is called spatial locality. Cache misses are handled by hardware. 

The _miss rate_ is simply the component of cache accesses that result in a miss. When the
processor fetches data from the memory into the cache, it will fetch a fixed-size _block_
or _line run_ chunk of data that contains the requested data.

## Cache hierarchies

Caches are typically L1, L2 and L3. L1 being closest to the CPU (and least capacity) and L3
being farthest (most capacity).

## My processor config

I'm using the TSUBAME login node which has a [Intel(R) Xeon(R) CPU E5-2637 v4](https://en.wikichip.org/wiki/intel/xeon_e5/e5-2637_v4) processor.
The L1 and L2 caches are per-core whereas the L3 cache is shared.
The wikichip page says it has the following cache config:
*

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
* [Intel 7200 family memory management.](https://software.intel.com/en-us/articles/intel-xeon-phi-processor-7200-family-memory-management-optimizations) 
* [gemm optimization](https://github.com/flame/how-to-optimize-gemm/wiki)
* [Advanced Vector Instructions (AVX)](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions)
* [The significance of SSE and AVX.](https://www.polyhedron.com/web_images/intel/productbriefs/3a_SIMD.pdf) 
* [Crunching numbers with AVX2](https://www.codeproject.com/Articles/874396/Crunching-Numbers-with-AVX-and-AVX) 

