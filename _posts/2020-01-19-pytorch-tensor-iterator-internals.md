---
layout: post
title: PyTorch TensorIterator Internals
date: 2020-01-19 16:00 +0900
---

# Introduction

The `TensorIterator` C++ class within pytorch is a complex yet useful class that
is useful for iterating over the elements of a tensor over any dimension and implicitly
parallelizing various operations in a device independent manner. It does this through
a C++ API that is that is independent of type and device of the tensor.

In this post, I will try to dive deeper into the working of this class and how it works.
The motivation for writing this post came from this [issue](https://github.com/pytorch/pytorch/issues/24669), which requires using TensorIterator for migrating `cumsum` from TH to ATen.

What makes this issue unique is that as of now there is no way of using the `TensorIterator`
to iterate over a tensor and perform dimension-wise reductions, which is an important operation
when one wants to pass the `cumsum` function a dimension to reduce and iterate over.

# Basics of TensorIterator
