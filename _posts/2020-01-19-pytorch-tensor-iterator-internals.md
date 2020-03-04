---
layout: post
title: PyTorch TensorIterator Internals
date: 2020-01-19 16:00 +0900
---

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [Introduction](#introduction)
- [History of TensorIterator](#history-of-tensoriterator)
    - [TH iterators](#th-iterators)
    - [Limitations of TH iterators](#limitations-of-th-iterators)
- [Basics of TensorIterator](#basics-of-tensoriterator)
    - [Creating a TensorIterator](#creating-a-tensoriterator)
    - [Choosing a dimension to iterate over](#choosing-a-dimension-to-iterate-over)
    - [Simple serial iterator](#simple-serial-iterator)
    - [Reduction operations](#reduction-operations)
    - [Parallelization](#parallelization)
    - [Using multiple types](#using-multiple-types)

<!-- markdown-toc end -->

# Introduction

The [`TensorIterator`](https://github.com/pytorch/pytorch/blob/master/aten/src/ATen/native/TensorIterator.cpp)
C++ class within pytorch is a complex yet useful class that
is useful for iterating over the elements of a tensor over any dimension and implicitly
parallelizing various operations in a device independent manner. It does this through
a C++ API that is that is independent of type and device of the tensor, freeing the programmer
of having to worry about the data or device when writing iteration logic for pytorch
tensors.

This post is deep dive into the working of `TensorIterator` and how it works, and is
an essential part of learning to contribute to the pytorch codebase since iterations
over tensors in the C++ codebase are extremly commonplace. This post is aimed at someone
who wants to contribute to pytorch, and you should be atleast familiar with some of the
basic terminologies of the pytorch codebase that can be found in Edward Yang's 
[blog post](http://blog.ezyang.com/2019/05/pytorch-internals/).

# History of TensorIterator

## TH iterators

This class was incorporated into the `ATen` implementation of pytorch tensors when the
pytorch team decided to change the C macro-based `TH` implementation and use a templated
C++ implementation instead. Previously in `TH`, C macros would be used for writing tensor
loops in a type indedependent manner. For example, consider this simple `TH` loop
for computing the product of all the numbers in a particular dimension (find the code 
[here](https://github.com/pytorch/pytorch/blob/master/aten/src/TH/generic/THTensorMoreMath.cpp#L350)):

``` C
TH_TENSOR_DIM_APPLY2(scalar_t, t, scalar_t, r_, dimension,
    accreal prod = 1;
    int64_t i;
    for(i = 0; i < t_size; i++)
        prod *= t_data[i*t_stride];
    *r__data = (scalar_t)prod;
);
```

The above loop works by basically following a particular convention for the naming of the
types and variables. You specify the input type and output type of your tensors in the first
and third arguments. `scalar_t` is a type that can generically be used for denoting a pytorch
scalar type such as `float`, `double`, `long` etc. The input tensor and output tensors are
specified in the second and fourth arguments (in this case `t` and `r_`), and the dimension that
we want to iterate over is specified as the fifth argument (`dimension`).

We then follow these arguments with the main body of the iterator (which is accepted as the sixth
argument into the macro), and denote the data, stride and size of the particular tensor dimension
by using variables that are suffixed by `_data`, `_stride` and `_size` respectively after the
variable name that represents the tensor inside the iterator body. For example, the size of the
input tensor is denoted as `t_size` in the above example and the pointer to the data of the output
tensor is denoted as `r__data`. The `accreal` in the second line is custom type that specifies
a real number that is an accumulator (in this case for accumulating the product).

Internally, the `TH_TENSOR_DIM_APPLY2` macro is expanded for generating various dispatch calls 
depending on the type of the tensor that needs to be iterated over. The implementation of 
`TH_TENSOR_DIM_APPLY2` can be found [here](https://github.com/pytorch/pytorch/blob/master/aten/src/TH/THTensorDimApply.h#L138).

## Limitations of TH iterators

Apart from the obvious complication that arises due to maintaining a codebase that is so dependent
on such insanely complex macro expansions, TH iterators have some fundamental shortcomings. For
one thing, they cannot be used for writing iterators in a device independent manner - you will
need separate iterators for CPU and CUDA. Also, parallelization does not happen implcitly
inside the iterator, you need to write the parallel looping logic yourself. Moreover, at a deeper
level `TH` iterators do not collapse the dimensions of the tensor (as we'll see later in this
post) therefore leading to looping that might not be as cache-optimized as possible.

These limitations led to the creation of `TensorIterator`, which is new C++ class used by the
new `ATen` tensor implementation for overcoming some of the shortcomings of the previous `TH`
iterators.

# Basics of TensorIterator

A `TensorIterator` can be created using the default constructor. You must then add the tensors
that you want as inputs or outputs. A good example can be found from the `TensorIterator::binary_op()`
[method](https://github.com/pytorch/pytorch/blob/master/aten/src/ATen/native/TensorIterator.cpp#L652) that
allows you to create `TensorIterator` objects for performing point-wise binary operations
between two tensors. The important parts look like so:

``` cpp
auto iter = TensorIterator();

iter.add_output(out);
iter.add_input(a);
iter.add_input(b);

iter.build();
```
As you can see, you add a tensor called `out` as the output tensors and `a` and `b` as the
input tensors. Calling `build` is then mandatory for creating the object and letting
the class perform other optimizations like collapsing dimesions and figuring out
data types.

# Performing iterations

Broadly, iterations using `TensorIterator` can be classified as point-wise iterations
or reduction iterations. This plays a fundamental role in how iterations using `TensorIterator`
are parallelized - point-wise iterations can be freely parallelized along any dimension
and grain size while reduction operations have to be either parallelized along dimensions
that you're not iterating over or by performing bisect and reduce operations along the
dimension being iterated. Parallelization can also happen using vectorized operations.

## Simple serial iterations

The simplest iteration operation can be performed using the 
[`for_each`](https://github.com/pytorch/pytorch/blob/master/aten/src/ATen/native/TensorIterator.cpp#L525) 
function. This function has two overloads - one which accepts a loop of type `loop_t`
and another which accepts a `loop2d_t` (find them [here](https://github.com/pytorch/pytorch/blob/master/aten/src/ATen/native/TensorIterator.h#L166)). The former can iterate over a loop
of a single dimension whereas the latter can do so over two dimensions. We will show
only how to work with `loop_t` but the same concepts can be extended to `loop2d_t`
as well.

## Reduction operations

## Parallelization

# Full TensorIterator example

# Internals
