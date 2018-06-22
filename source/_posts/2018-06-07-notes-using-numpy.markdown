---
title: Notes using numpy
date: 2018-06-07T15:10:07+09:00
---

In this post I will document certain things I've learned when working with numpy.
Might be interesting to some people.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [Axes in numpy](#axes-in-numpy)
- [Printoptions](#printoptions)
- [Debugging](#debugging)
- [Useful functions](#useful-functions)
    - [Setting diagonals](#setting-diagonals)
- [Resources](#resources)

<!-- markdown-toc end -->

# Axes in numpy

Axes in numpy are defined for arrays in more than one dim. A 2D array has the 0th axis running
vertically _downwards_ across rows and the 1st axis is running _horizontally_ running across
columns.

See https://docs.scipy.org/doc/numpy-1.10.0/glossary.html

# Printoptions

The `numpy.printoptions` function can be used for setting various global print options like
linewidth and precision during printing to console. Useful for debugging and viewing:
* `suppress` - Suppress printing in scientific notation.
* `precision` - Limit the precision of numbers printed.
* `linewidth` - Max width of printing.

# Debugging

The `pdb` module is useful for debugging python. Place `pdb.set_trace()` in some place
in the code where you want the code to break. It will then provide you with a python
REPL.

Here's a link to it: https://pythonconquerstheuniverse.wordpress.com/2009/09/10/debugging-in-python/

# Broadcasting

Numpy uses 'broadcastable' data structures. It describes how numpy treats arrays with
different shapes during arithmetic operations.

Link: 
* https://docs.scipy.org/doc/numpy/user/basics.broadcasting.html
* https://eli.thegreenplace.net/2015/broadcasting-arrays-in-numpy/

# Shape parameters

Sometimes, some operations return their shape at `(R,1)` and some as `(R,)`. This design
decision is taken because numpy arrays are indexed by two numbers in the former case and
a single number in the latter case. This allows single number indexing and storage in
flat-indexed arrays.

Link: https://stackoverflow.com/questions/22053050/difference-between-numpy-array-shape-r-1-and-r/22074424

# Useful functions

## Setting diagonals

Use `numpy.fill_diagonal()` for filling the diagonal of an array with some number.
Take note that this is an in-place modification function and that it does not return
any value.

Link: https://docs.scipy.org/doc/numpy/reference/generated/numpy.fill_diagonal.html

## Matrix lower triangle

Use `numpy.tril()` and pass the object.

## Inverse of a matrix

Compute multiplicative inverse of a matrix using `numpy.linalg.inv()`.

Link: https://docs.scipy.org/doc/numpy-1.14.0/reference/generated/numpy.linalg.inv.html

## Multiplication

`*` is element-wise multiplication between two arrays. For matrix multiplication use
`numpy.matmul`.

# Resources
