---
layout: post
title: "Solving systems of linear equations in Ruby"
date: 2014-12-14 11:57:34 +0530
comments: true
categories: 
---

Solving systems of linear equations is a very important part of scientific computing (some would say most important), and in this post I will show you how a system of linear equations involving _n_ equations and _n_ unknowns can be solved in Ruby using the [NMatrix](https://github.com/SciRuby/nmatrix) gem and the methodology that I used for simplyfying the algorithms involved.

This involved solving a system of linear equations using forward substution followed by back substution using the LU factorization of the matrix of co-efficients.

The reduction techniques were quite baffling at first, because I had always solved equations in the traditional way and this was something completely new. I eventually figured it out and also [implemented it in NMatrix](https://github.com/SciRuby/nmatrix/commit/4241d241ca7744ca2ca5e090782588581160d42b). Here I will document how I did that. Hopefully, this will be useful to others like me!

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

Forward substitution is a technique that involves scanning an upper triangular matrix from top to bottom, computing a value for the top most variable and substituting that value into subsequent variables below it. This proved to be quite intimidating, because according to [Numerical Recipes](http://www.nr.com/), the whole process of forward substitution can be represented by the following equation:

$$
\begin{align}
  y_{0} = \dfrac{b_{0}}{L_{00}}
\end{align}
$$

$$
\begin{align}
  y_{i} = \dfrac{1}{L_{ii}}[b_{i} - \sum_{j=0}^{i-1}L_{ii} \times y_{j}] \quad i = 1,2,\dotsc,N-1 \quad (4)
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
  y_{1} = \dfrac{1}{L_{11}} \times [b_{1} - L_{00} \times y_{0}]
\end{align}
$$

$$
\begin{align}
  y_{2} = \dfrac{1}{L_{22}} \times [b_{2} - (L_{20} \times y_{0} + L_{21} \times y_{1})]
\end{align}
$$

Its now quite obvious that forward substitution is called so because we start from the topmost row of the matrix and use the value of the variable calculated in that row to calculate the _y_ for the following rows.

Now that we have the solution to equation (2), we can use the values generated in the _y_ column vector to compute _x_ in equation (3). Recall that the matrix _U_ is the upper triangular decomposed part of _A_ (equation (1)). This matrix can be solved using a technique called _backward substitution_. It is the exact reverse of the _forward substitution_ that we just saw, i.e. the values of the bottom-most variables are calculated first and then substituted into the rows above to calculate subsquent variables above.

The equation describing backward substitution is described in Numerical Recipes as:

$$
\begin{align}
  x_{N-1} = \dfrac{y_{N-1}}{U_{N-1,N-1}}
\end{align}
$$

$$
\begin{align}
  x_{i} = \dfrac{1}{U_{ii}}[y_{i} - \sum_{j=i+1}^{N-1}U_{ij} \times x_{j}] \quad i = N-2, N-3,\dotsc,0 \quad (5)
\end{align}
$$

Lets try to understand this equation by extending the example we used above to understand forward substitution. To gain a better understanding of this concept, consider the equation (3) written in matrix form (keeping the same 3x3 matrix _A_):

$$
\begin{align}
    \begin{pmatrix}
      U_{00} & U_{01} & U_{02} \\
      0 & U_{11} & U_{12} \\
      0 & 0 & U_{22}
    \end{pmatrix}
    \begin{pmatrix}
      x_{0} \\
      x_{1} \\
      x_{2}
    \end{pmatrix}
    =
    \begin{pmatrix}
      y_{0} \\
      y_{1} \\
      y_{2}
    \end{pmatrix}
\end{align}
$$

Using the matrix representation above as reference, equation (5) can be expanded in terms of a 3x3 matrix as:

$$
\begin{align}
  x_{2} = \dfrac{y_{2}}{U_{22}}
\end{align}
$$

$$
\begin{align}
  x_{1} = \dfrac{1}{U_{11}} \times [y_{1} - U_{12} \times x_{2}]
\end{align}
$$

$$
\begin{align}
  x_{0} = \dfrac{1}{U_{00}} \times [y_{0} - (U_{01} \times x_{1} + U_{02} \times x_{2})]
\end{align}
$$

Looking at the above equations its easy to see how backward substitution can be used to solve for unknown quantities when given a upper triangular matrix of co-efficients, by starting at the lowermost variable and gradually moving upward.

Now that the methodology behind solving sets of linear equations is clear, lets consider a set of 3 linear equations and 3 unknowns and compute the values of the unknown quantities using the nmatrix #solve method.

The #solve method can be called on any nxn square matrix of a floating point data type, and expects its sole argument to be a column matrix containing the right hand sides. It returns a column nmatrix object containing the computed co-efficients.

For this example, consider these 3 equations:

$$ x + y − z = 4 $$

$$ x − 2y + 3z = −6 $$
 
$$ 2x + 3y + z = 7 $$

These can be translated to Ruby code by creating an NMatrix only for the co-efficients and another one only for right hand sides:

``` ruby

require 'nmatrix'
coeffs = NMatrix.new([3,3],
  [1, 1,-1,
   1,-2, 3,
   2, 3, 1], dtype: :float32)

rhs = NMatrix.new([3,1],
  [4,
  -6,
   7], dtype: :float32)

solution = coeffs.solve(rhs)
#=> [1.0, 2.0, -1.0]
```