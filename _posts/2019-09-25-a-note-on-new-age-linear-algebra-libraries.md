---
layout: post
title: A note on new age linear algebra libraries
date: 2019-09-25 17:27 +0900
---

Old and stable linear algebra libraries like LAPACK and BLAS are showing their age
with demand for computing solutions to much larger problems that before, and need
of modern, scalable and human-friendly interfaces. As an answer to this need, various
labs around the world have come up with their implementations of these libraries,
with the desire to be become the de facto linear algebra package for replacing LAPACK
and BLAS. Some of these libraries are PLASMA, CHAMELEON, SLATE, ELEMENTAL, etc.
Navigating this complex maze can be tough if you're just starting out.

In this blog post I will post some brief reviews of all these libraries and what sets
them apart from each other, and also their similarities and differences. I have also
included some of the older parallel implementations for the sake of comparison.

Note: only dense linear algebra libraries are covered in this post.

# CHAMELEON

CHAMELEON is a C library from the STORM team at INRIA, France.
CHAMELEON tries to address the problem of providing a simple interface for writing
performant code when using machines with heterogeneous architectures, i.e. machines
having multiple CPUs and GPUs (or any other accelerator) as processing units.

Since CPUs and accelerators have vastly different characterestics and computational
performance

# PLASMA

PLASMA is a C library from the Innovative Computing Lab at Univerity of Tennessee.

# SLATE

# ELEMENTAL

# SCALAPACK

# PLAPACK

# PBLAS

