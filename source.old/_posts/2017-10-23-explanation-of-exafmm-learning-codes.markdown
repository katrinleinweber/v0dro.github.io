---
layout: post
title: "Explanation of ExaFMM learning codes."
date: 2017-10-23 21:33:24 +0900
comments: true
categories: 
---

# ExaFMM learning tutorials

In this file I will write descriptions of the exafmm 'learning' codes and my understanding of them. I have been tasked with understanding the code and porting it to Ruby, my favorite language.
We shall start from the first tutorial, i.e. [0_tree](). You can find the full Ruby code here.

# 0_tree

## step1.cxx

This program simply populates some bodies with random numbers, creates a hypothetical X and Y axes and figures out the quadrant of each of the bodies.

Each of the nodes of the tree have a maximum of [4 immediate children](). We first initialize 100 `struct Body` objects, and then set the X and Y co-ordinates of each of them to a random number between 0 and 1.

In order to actually build the tree we follow the following steps:

  * First [get the bounds]() between which the random numbers lie. That is, we figure out the min and max random number that is present in the bodies.
  * We then get a ['center' and a 'radius'](). This is useful for creating 'quadrants' and partitioning points into different quandrants in later steps. The center is calculated by adding the min and max numbers (which we treat as the diameter) and dividing by 2. This step is necessary since there is no 'square' space that can be partitioned into multiple spaces like there was in the lecture series. The way of calculating the radius `r0` is a little peculiar. It does not use the distance formula, its main purpose is....
  * And then simply count the bodies in each quadrant and display them.

Ruby code:
The body is represented as the Ruby class `Body`:
``` ruby
class Body
  attr_reader :x

  def initialize
    @x = [0.0, 0.0]
  end
end
```

There is an interesting way of knowing the quadrant in this code. It goes like this:
``` ruby
a = body.x[0] > x0[0] ? 1 : 0
b = body.x[1] > x0[1] ? 1 : 0
quadrant = a + (b << 1)
```
Above code basically plays with 0 and 1 and returns a number between 0 and 3 as the correct quadrant number.

## step2.cxx

This code basically takes the bodies created in the previous step, counts the number of bodies in each quadrant and sorts them by quadrant.

The new steps introduced in this program can be summarized as follows:
  * Count the bodies in each quadrant and store the count in an array. The `size` array in case of the Ruby implementation.
  * In the next step we successively add the number of elements in each quadrant so that it gives us the offset value at which elements from a new quadrant will start in the `bodies` Array (of course, after it is sorted).
  * We then sort the bodies according to the quadrant that they belong to. Something peculiar that I notice about this part is that counter[quadrant] also gets incremented after each iteration for sorting. Why is this the case even though the counters have been set to the correct offsets previously?
  
## step3.cxx

This program introduces a new method called `buildTree`, inside of which we will actually build the tree. It removes some of the sorting logic from `main` and puts it inside `buildTree`. The `buildTree` function performs the following functions:
  * Most of the functions relating to sorting etc are same. Only difference is that there is in-place sorting of the `bodies` array and the `buffer` array does not store elements anymore.
  * A new function introduced is that we re-calculate the center and the radius based on sorted co-ordinates. This is done because we want new center and radii for the children.
  * The `buildTree` function is called recursively such that the quadrants are divided until a point is reached where the inner most quadrant in the hierarchy does not contain more than 4 elements.
  
Implementation:

There is an interesting piece of code in the part for calculating new center and radius:
``` ruby
center[d] = 
  x0[d] +
  radius *
  (((i & 1 << d) >> d) * 2 - 1) # i is quadrant number
```

In the above code, there is some bit shifting and interleaving taking place whose prime purpose is to split the quadrant number into X and Y dimension and then using this to calculate the center of the child cell.

Another piece of code is this:
``` ruby
counter = Array.new 4, start
1.upto(3) do |i|
  counter[i] = size[i-1] + counter[i-1]
end

# sort bodies and store them in buffer
buffer = bodies.dup
start.upto(finish-1) do |n|
  quadrant = quadrant_of x0, buffer[n]
  bodies[counter[quadrant]] = buffer[n]
  counter[quadrant] += 1
end
```

In the above code, the `counter` variable is first used to store offsets of the elements in different quadrants. In the next loop it is in fact a counter for that stores in the index of the body that is currently under consideration.

## step04.cxx

In this step we use the code written in the previous steps and actually build the tree.
The tree is built recursively by splitting into quadrants and then assigning them to cells
based on the quadrant. The 'tree' is actually stored in an array.

The cells are stored in a C++ vector called `cells`.

In the `Cell` struct, I wonder why the body is stored as a pointer and not a variable.

Implementation in the Ruby code, like saving the size of an Array during a recursive call 
is slightly different since Ruby does not support pointers, but the data structures and
overall code is more or less a direct port.

# 1_traversal

These codes are for traversal of the tree that was created in the previous step. The full code can be found in [1_traversal.rb]() file.

## step1.cxx

This step implements the P2M and M2M passes of the FMM.

One major difference between the C++ and Ruby implementation is that since Ruby does not have pointers, I
have used the array indices of the elements instead. For this purpose there are two attributes in the
`Cell` class called `first_child_index` that is responsible for holding the index in the `cells` array
about the location of the first child of this cell, and the second `first_body_index` which is responsible for holding the index of the body in the `bodies` array.

This step does this by introducing a method called `upwardPass` which iterates through nodes and thier children and computes the P2M and M2M kernels.

## step2.cxx

This step implements the rest of the kernels i.e. M2L, L2L, L2P and P2P. It also introduces two new methods `downward_pass` that calculates the local forces from other local forces and L2P interactions and `horizontal_pass` that calculates the inter-particle interactions and m2l.

No special code as such over here, its just the regular FMM stuff.

# 2_kernels

This code is quite different from the previous two. While the previous programs were mostly retricted to a single file, this program substantially increases complexity and spreads the implementation across several files. We start using 3 dimensional co-ordinates too.

In this code, we start to make a move towards spherical co-ordinate system to represent the particles in 3D. A few notable algorithms taken from some research papers have been implemented in this code.

Lets describe each file and see what implementation lies inside

## kernel.h

The `kernel.h` header file implemenets all the FMM kernels. It also implements two special functions called `evalMultipole` and `evalLocal` that evaluate the multipoles and local expansion for spherical co-ordinates using the actual algorithm that is actually used in exafmm. An implementation of this algorithm can be found on page 16 of the paper ["Treecode and fast multipole method for N-body simulation with CUDA"](https://arxiv.org/pdf/1010.1482.pdf%20) by Yokota sensei. A preliminary implementation of this algorithm can be found in ["A Fast Adaptive Multipole Algorithm in Three Dimensions"](http://www.sciencedirect.com/science/article/pii/S0021999199963556) by Cheng.

The Ruby implementation of this file is in `kernel.rb`.

I will now describe this algorithm here best I can:

### Preliminaries

#### Ynm vector

This is a vector that defines the [spherical harmonics](https://en.wikipedia.org/wiki/Spherical_harmonics) of degree _n_ and order _m_. A primitive version for computing this exists in the paper by Cheng and a newer, faster version in the paper by Yokota.

Spherical harmonics allow us to define series of a function in 3D rather in 1D that is usually the case for things like the expansion of _sin(x)_. They are representations of functions on the surface of a sphere instead of on a circle, which is usually the case with other 2D expansion functions. They are like the Fourier series of the sphere. This [article](http://mathworld.wolfram.com/SphericalHarmonic.html) explains the notations used nicely.

The order (_n_) and degree (_m_) correspond to the order and degree of the [Legendre polynomial](http://mathworld.wolfram.com/LegendrePolynomial.html) that is used for obtaining the spherical harmonic. _n_ is an integer and _m_ goes from _0..n_.

For causes of optimization, the values stored inside `ynm` are not the ones that correspond to the spherical harmonic, but are values that yield optimized results when the actual computation happens.

### Functions

### cart2sph

This function converts cartesian co-ordinates in (X,Y,Z) to spherical co-ordinates involving `radius`, `theta` and `phi`. `radius` is simply the square root of the norm of the co-ordinates (norm is defined as the sum of squares of the co-ordinates in `vec.h`).

### evalMultipole

This algorithm calculates the multipole of a cell. It uses spherical harmonics so that net force of the forces inside a sphere and can be estimated on the surface of the sphere, which can then be treated as a single body for estimating forces.

The optimizations that are presented in the `kernel.h` version of this file are quite complex to understand since they look quite different from the original equation. I will explain the code written in the file, however, we will use unoptmized Ruby code that actually resembles the equation for purposes of understanding.

For code that is still sane and easier to read, head over to the [laplace.h](https://github.com/exafmm/exafmm-alpha/blob/develop/kernels/laplace.h#L48) file in exafmm-alpha. The explanations that follow for now are from this file. We will see how the same functions in `kernel.h` have been modified to make computation faster and less dependent on large number divisions which reduce the accuracy of the system.

The `evalMultipole` function basically tries to populate the `Ynm` array with data that is computed with the following equation:
$$
\begin
\rho^{n}Y_{n}^{m}=\sum_{m=0}^{P-1}\sum_{n=m+1}^{P-1}\rho^{n}P_{n}^{m}(x)\sqrt{\frac{(n-m)!}{(n+m)!}}e^{im\beta}
\end
$$

It starts with evaluating terms that need not be computed for every iteration of `n`, and computes those terms in the outer loop itself. The terms in the outer loop corespond to the condition `m=n`. The first of these is the exponential term $$ e^im\beta $$. 

After this is a curious case of computation of some indexes called `npn` and `nmn`. These are computed as follows:
``` ruby
npn = m * m + 2 * m # case Y n  n
nmn = m * m         # case Y n -n
```

The corresponding index calculation for the inner loop is like this:
``` ruby
npm = n * n + n + m # case Y n  m
nmm = n * n + n - m # case Y n -m
```

This indexes the `Ynm` array. This is done because we are visualizing the Ynm array as a pyramid whose base spans from `-m` to `m` and who height is `n`. A rough visualization of this pyramid would be like so:
```
   -m ---------- m
n  10 11 12 13  14
|    6  7  8  9
|     3  4   5  
|      1   2
V        0
```

The above formulas will give the indexes for each half of the pyramid. Since the values of one half of the pyramid are conjugates of the other half, we can only iterate from `m=0` to `m<P` and use this indexing method for gaining the index of the other half of the pyramid.

Now let us talk about the evaluation of the [Associated Legendre Polynomial](http://mathworld.wolfram.com/AssociatedLegendrePolynomial.html) $$ P^m_{n}(cos(\theta)) $$, where _m_ is the order of the differential equation and _n_ is the degree. The Associated Legendre Polynomial is the solution to the [Associated Legendre Equation](http://mathworld.wolfram.com/AssociatedLegendreDifferentialEquation.html). The Legendre polynomial can be expressed in terms of the [Rodrigues form](https://en.wikipedia.org/wiki/Associated_Legendre_polynomials#Definition_for_non-negative_integer_parameters_.E2.84.93_and_m) for computation without dependence on the simple Legendre Polynomial $$ P_{n} $$. However, due to the factorials and rather large divisions that need to be performed to compute the Associated Legendre polynomial in this form, computing this equation for large values of _m_ and _n_ quickly becomes unstable. Therefore, we use a recurrence relation of the Polynomial in order to compute different values.

The recurrence relation looks like so:
$$
\begin{equation}
  (n-m+1)P^m_{n+1}(x)=x(2n+1)P^m_n(x)-(n+m)P^m_{n-1}(x)
\end{equation}
$$

The Ruby implementation is [here]().

## vector.h

This file defines a new custom type for storing 1D vectors called `vec` as a  C++ class. It also defines various functions that can be used on vectors like `norm`, `exp` and other simple arithmetic.

The Ruby implementation of this file is in `vector.rb`.

## exafmm.h

## exafmm2d.h

## step1.cxx

## step2.cxx

