---
layout: post
title: Distributed LU factorization using Chameleon
date: 2019-09-17 08:45 +0900
---
In this post I will write the detail the steps I took to reproduce distributed
LU factorization using the Chameleon library. It is a linear algebra library
based on the starPU runtime system.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [Installing chameleon](#installing-chameleon)
- [Compiling and linking your programs](#compiling-and-linking-your-programs)
- [Distributed LU factorization implmentation](#distributed-lu-factorization-implmentation)

<!-- markdown-toc end -->

# Installing chameleon

Clone the sources from gitlab:
```
git clone --recursive https://gitlab.inria.fr/solverstack/chameleon.git
```

Configure with the following for a non-CUDA, MPI-enabled build:
```
cd chameleon
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug \
         -DCMAKE_INSTALL_PREFIX=$HOME/gitrepos/hicma/profiling/chameleon/chameleon/build \
         -DCHAMELEON_USE_CUDA=OFF \
         -DCHAMELEON_USE_MPI=ON \
         -DFXT_DIR=/home/1/17M38101/software/fxt-0.3.8 \
         -DSTARPU_DIR=/home/1/17M38101/software/starpu-1.3.2-test \
         -DSTARPU_FIND_COMPONENTS=ON \
         -DCHAMELEON_ENABLE_TRACING=ON
make install
```
Make sure that you're using openmpi. For some reason chameleon refuses to work with a starpu
that has been compiled with intel-mpi.

# Compiling and linking your programs

Make sure you have starpu and starpumpi configured in your pkg-config path. You can then
get the compiler flags with `pkg-config --cflags chameleon` and linker flags with
`pkg-config --libs --static chameleon`.

# Distributed LU factorization implementations

The `chameleon_pzgetrf_nopiv(CHAM_desc_t*, RUNTIME_sequence_t *, RUNTIME_request_t *)`
function is used for a distributed LU factorization using Chameleon and starpu underneath. It
implements a right-looking variant of the LU factorization, which is a very common algorithm
made popular by SCALAPACK.

The `chameleon_pzgetrf_incpiv()` function is a used for a distributed LU using a newer
LU algorithm presented in [this paper](). It claims to have superior performance compared
to right-looking LU since communication and computation can be overlapped better.

