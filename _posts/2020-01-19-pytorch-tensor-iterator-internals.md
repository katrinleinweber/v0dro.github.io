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
- [Performing iterations](#performing-iterations)
    - [Iteration details](#iteration-details)
        - [Setting tensor iteration dimensions](#setting-tensor-iteration-dimensions)
- [Conclusion](#conclusion)

<!-- markdown-toc end -->

# Introduction

Pytorch is a massive
codebase (approx. 12 GB after taking into account the build and generated files), and having
a method for iterating over tensors in a very efficient manner that is independent of
data type, dimension, striding and hardware is a critical feature that can lead to a very
massive simplification of the codebase and make distributed development much faster and
smoother. The [`TensorIterator`](https://github.com/pytorch/pytorch/blob/master/aten/src/ATen/native/TensorIterator.cpp) C++ class within pytorch is a complex yet useful class that
is used for iterating over the elements of a tensor over any dimension and implicitly
parallelizing various operations in a device independent manner.

It does this through
a C++ API that is independent of type and device of the tensor, freeing the programmer
of having to worry about the datatype or device when writing iteration logic for pytorch
tensors. For those coming from the numpy universe, `NpyIter` is a close cousin of `TensorIterator`.

This post is deep dive into the working of `TensorIterator` and how it works, and is
an essential part of learning to contribute to the pytorch codebase since iterations
over tensors in the C++ codebase are extremly commonplace. This post is aimed at someone
who wants to contribute to pytorch, and you should be atleast familiar with some of the
basic terminologies of the pytorch codebase that can be found in Edward Yang's 
[blog post](http://blog.ezyang.com/2019/05/pytorch-internals/**.

# History of TensorIterator

## TH iterators

`TensorIterator` was incorporated into the `ATen` implementation of pytorch tensors when the
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

The above loop works by following a particular convention for the naming of the
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

These limitations led to the creation of `TensorIterator`, which is used by the
`ATen` tensor implementation for overcoming some of the shortcomings of the previous `TH`
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

## Iteration details

The simplest iteration operation can be performed using the 
[`for_each`](https://github.com/pytorch/pytorch/blob/master/aten/src/ATen/native/TensorIterator.cpp#L525) 
function. This function has two overloads - one which accepts a loop of type `loop_t`
and another which accepts a `loop2d_t` (find them [here](https://github.com/pytorch/pytorch/blob/master/aten/src/ATen/native/TensorIterator.h#L166)). The former can iterate over a loop
of a single dimension whereas the latter can do so over two dimensions. The simplest
way of using `loop_t` is to pass it as a lambda using to `for_each`. A code snippet
using it this way would look like so:

``` cpp
auto iter = TensorIterator();
iter.add_output(out);
iter.add_input(a);
iter.build();

auto loop = [&](char **data, const int64_t* strides, int64_t n) {
    auto * out_data_bytes = data[0];
    auto * in_data_bytes = data[1];
    
    // do something with input and output.
    
    out_data_bytes += strides[0];
    in_data_bytes += strides[1];
}

iter.for_each(loop);
```
In the above example, the `char** data` gives a pointer to the data within the
tensor in the same order that you specify when you build the iterator. Note
that in order to make the implementation agnostic of any particular data type, you
will always receive the data typecast to `char` (think of it as a bunch of bytes).

The second argument is `int64_t* strides` which is an array containing the strides of
the dimension that you're iterating over. We can add this stride to the pointer received
in order to reach the next element in the tensor. The last argument is `int64_t n` which
is the size of the dimension being iterated over. 

The `for_each` loop will implicitly parallelize each iteration of `loop` if the size
of each iteration is more than the value of `internal::GRAIN_SIZE`, which is a value
that is determined as the 'right amount' of data to iterate over in order to gain a significant
speedup using multi-threaded execution.

### Setting tensor iteration dimensions

The value of the strides will determine which dimension of the tensor you will iterate over.
`TensorIterator` performs multiple optimizations internally to try to make sure that atleast
most of the iterations happen on contiguos data to take advantage of hierarchical cache-based
memory architectures.

Now a multi-dimensional tensor will have multiple stride values depending on the dimension
you want to iterate over, so `TensorIterator` will directly compute the strides that
get passed into the loop by
by itself within the `build()` function. How exactly it computes the dimension
to iterate over is something that should be properly understood in order to use `TensorIterator`
effectively.

If you're performing a reduction operation (see the sum code in [ReduceOps.cpp](https://github.com/pytorch/pytorch/blob/master/aten/src/ATen/native/ReduceOps.cpp#L384)),
`TensorIterator` will figure out the dimensions that will be reduced depending
on the shape of the input and output tensor, which determines how the input will be broadcast
over the output. If you're
performing a simple pointwise operation between two tensors (like a `addcmul` from 
[PointwiseOps.cpp](https://github.com/pytorch/pytorch/blob/master/aten/src/ATen/native/PointwiseOps.cpp#L31))
the iteration will happen over the entire tensor, without providing a choice of the dimension.
This will allow TensorIterator to randomly parallelize the computation, without guarantees of
the order of execution (since it does not matter anyway).

For something like a cumulative sum operation, where you want be able to choose the dimension
to reduce but iterate over multiple non-reduced dimesions (possibly in parallel), you
must first restride the tensors, and then use these tensors 
for creating a `TensorIterator`. In order to understand how this bit works, lets go over
the code for the [kernel](https://github.com/pytorch/pytorch/blob/master/aten/src/ATen/native/cpu/ReduceOpsKernel.cpp#L21) that executes the [cumsum](https://github.com/pytorch/pytorch/blob/master/aten/src/ATen/native/cpu/ReduceOpsKernel.cpp#L71) function.

The important bits of this function are like so:

``` cpp
auto self_sizes = ensure_nonempty_vec(self.sizes().vec());
self_sizes[dim] = 1;

auto result_restrided = restride_dim(result, dim, self_sizes);
auto self_restrided = restride_dim(self, dim, self_sizes);

auto iter = TensorIterator();
iter.dont_compute_common_dtype();
iter.dont_resize_outputs();
iter.add_output(result_restrided);
iter.add_input(self_restrided);
iter.build();
```
You can see that we first change the size of the tensors to `1` on the
reduction dimension so that the dimension collapsing logic inside
`TensorIterator#build` will know which dimension to broadcast the result
over. We then restride the tensors using `restride_dim` and then use the
restrided tensors for building the `TensorIterator`.

# Conclusion

This post was a very short introduction to what `TensorIterator` is actually
capable of. If you're still more interested in how it works and what goes into
things like collapsing the tensor size for optimizing memory access, a good
place to start would be the `build()` function in 
[TensorIterator.cpp](https://github.com/pytorch/pytorch/blob/master/aten/src/ATen/native/TensorIterator.cpp#L1030).