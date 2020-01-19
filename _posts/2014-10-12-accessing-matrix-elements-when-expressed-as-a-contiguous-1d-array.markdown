---
layout: post
title: "Accessing matrix elements when expressed as a contiguous 1D array"
date: 2014-10-12 18:52:10 +0530
comments: true
categories: 
---

This post will talk about methods to access different types of matrix elements (diagonals, columns, rows, etc.) when a matrix is expressed as a continguous 1D array.

Recently, I was working on implementing a matrix inversion routine using the Gauss-Jordan elimination technique in C++. This was part of the NMatrix ruby gem, and because of the limitations imposed by trying to interface a dynamic language like Ruby with C++, the elements of the NMatrix object had to expressed as a 1D contiguous C++ array for computation of the inverse.

The in-place Gauss-Jordan matrix inversion technique uses many matrix elements in every pass. Lets see some simple equations that can be used for accessing different types of elements in a matrix in a loop.

#### Diagonals

Lets say we have a square matrix A with shape _M_. If _k_ is iterator we are using for going over each diagonal element of the matrix, then the equation will be something like $$ k * (M + 1) $$.

A for loop using the equation should look like this:

```cpp

for (k = 0; k < M; ++k) {
    cout << A[k * (M + 1)];
}

// This will print all the diagonal elements of a square matrix.
```

#### Rows

To iterate over each element in a given row of a matrix, use $$ row*M + col $$. Here `row` is the fixed row and `col` goes from 0 to M-1.

#### Columns

To iterate over each element in a given column of a matrix, use $$ col*M + row $$. Here `col` is the fixed column and `row` goes from 0 to M-1.

#### General

In general the equation $$ row*NCOLS + col $$ will yield a matrix element with row index `row` and column index `col`.