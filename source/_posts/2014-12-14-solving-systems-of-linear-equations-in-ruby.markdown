---
layout: post
title: "Solving systems of linear equations in Ruby"
date: 2014-12-14 11:57:34 +0530
comments: true
categories: 
---

I recently took up a project to implement an algorithm for [NMatrix](https://github.com/SciRuby/nmatrix) to solve sets of linear equations involving _n_ equations and _n_ unknowns. This involved solving a system of linear equations using forward substution followed by back substution using the LU factorization of the matrix of co-efficients.

The reduction techniques were quite baffling at first, because I had always solved equations in the traditional way and this was something completely new. I eventually figured it out and also [implemented it in NMatrix](https://github.com/SciRuby/nmatrix/commit/4241d241ca7744ca2ca5e090782588581160d42b). Here I will document how I did that, and we will also solve a simple set of linear equations in Ruby, using NMatrix. Hopefully, this will be useful to others like me!

I'm assuming that you are familiar with the LU decomposed form of a square matrix. If not, read [this](http://en.wikipedia.org/wiki/LU_decomposition) resource first.

Throughout this post, I will refer to _A_ as the square matrix of co-efficients, _x_ as the column matrix of unknowns and _b_ as column matrix of right hand sides.

Lets say that the equation you want to solve is represented by:

$$ A.x = b .. (1)$$


The basic idea behind an LU decomposition is that a square matrix A can be represented as the product of two matrices _L_ and _U_, where _L_ is a lower [triangular matrix](http://en.wikipedia.org/wiki/Triangular_matrix) and _U_ is an upper triangular matrix.

$$ L.U = A $$

Given this, equation (1) can be represented as:

$$ L.(U.x) = b $$

Which we can use for solving the vector _y_ such that:

$$ L.y = b .. (2) $$

and then solving:

$$ U.x = y ..(3) $$

The LU decomposed matrix is typically carried in a single matrix to reduce storage overhead, and thus the diagonal elements of _L_ are assumed to have a value _1_. The diagonal elements of _U_ can have any value.

The reason for breaking down _A_ and first solving for an upper triangular matrix is that the solution of an upper triangular matrix is quite trivial and thus the solution to (2) is found using the technique of _forward substitution_. 

Forward substitution is a technique that involves scanning an upper triangular matrix from top to bottom, computing a value for the top most variable and substituting that value into subsequent variables below it. This was quite daunting at first, because according to Numerical Recipes, the whole process of forward substitution can be represented by the following equation:

$$
\begin{align}
 put equation here .. (4)
\end{align}
$$

Figuring out what exactly is going on was quite a daunting task, but I did figure it out eventually and here is how I went about it:

Let _L_ in equation (2) to be the lower part of a 3x3 matrix A (as per (1)). So equation (2) can be represented in matrix form as:

$$
\begin{align}
    \begin{pmatrix}
      L_{00} & 0 & 0 \\
      L_{10} & L_{11} & 0 \\
      L_{20} & L_{21} & L_{22}
    \end{pmatrix}
    \begin{pmatrix}
      y_{0} \\
      y_{1} \\
      y_{2}
    \end{pmatrix}
    =
    \begin{pmatrix}
      b_{0} \\
      b_{1} \\
      b_{2}
    \end{pmatrix}
\end{align}
$$

Our task now is calculate the column matrix containing the _y_ unknowns.
Thus by equation (4), each of them can be calculated with the following sets of equations (if you find them confusing just correlate each value with that present in the matrices above and it should be clear):

$$
\begin{align}
  y_{0} = \dfrac{b_{0}}{L_{00}}
\end{align}
$$

$$
\begin{align}
  y_{1} = \dfrac{1}{L_{11}}[b_{1} - L_{00} \times y_{0}]
\end{align}
$$

$$
\begin{align}
  y_{2} = \dfrac{1}{L_{22}}[b_{2} - (L_{20} \times y_{0} + L_{21} \times y_{1})]
\end{align}
$$

Its now quite obvious that forward substitution is called so because we start from the topmost row of the matrix and use the value of the variable calculated in that row to calculate the _y_ for the following rows.

Now that we have the solution to equation (2), we can use the values generated in the _y_ column vector to compute _x_ in equation (3). Recall that the matrix _U_ is the upper triangular decomposed part of _A_ (equation (1)). This matrix  