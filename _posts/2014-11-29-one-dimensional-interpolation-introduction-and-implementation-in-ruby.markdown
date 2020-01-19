---
layout: post
title: "One Dimensional Interpolation: Introduction And Implementation In Ruby"
date: 2014-11-29 00:23:04 +0530
comments: true
categories: 
---

Interpolation involves predicting the co-ordinates of a point given the co-ordinates of points around it. Interpolation can be done in one or more dimensions. In this article I will give you a brief introduction of one-dimensional interpolation and execute it on a sample data set using the [interpolation](https://github.com/v0dro/interpolation) gem.

One dimensional interpolation involves considering consecutive points along the X-axis with known Y co-ordinates and predicting the Y co-ordinate for a given X co-ordinate.

There are several types of interpolation depending on the number of known points used for predicting the unknown point, and several methods to compute them, each with their own varying accuracy. Methods for interpolation include the classic Polynomial interpolation with Lagrange's formula or spline interpolation using the concept of spline equations between points.

The spline method is found to be more accurate and hence that is what is used in the interpolation gem.

## Common Interpolation Routines

Install the `interpolation` gem with `gem install interpolation`. Now lets see a few common interpolation routines and their implementation in Ruby:

#### Linear Interpolation

This is the simplest kind of interpolation. It involves simply considering two points such that _x[j]_ < _num_ < _x[j+1]_, where _num_ is the unknown point, and considering the slope of the straight line between _(x[j], y[j] )_ and _(x[j+1], y[j+1])_, predicts the Y co-ordinate using a simple linear polynomial.

Linear interpolation uses this equation:

$$
\begin{align}
    y = (y[j] + \frac{(interpolant - x[j])}{(x[j + 1] - x[j])} \times (y[j + 1] - y[j])
\end{align}
$$

Here _interpolant_ is the value of the X co-orinate whose corresponding Y-value needs to found.

Ruby code:

``` ruby

require 'interpolation'

x = (0..100).step(3).to_a
y = x.map { |a| Math.sin(a) }

int = Interpolation::OneDimensional.new x, y, type: :linear
int.interpolate 35
# => -0.328
```

#### Cubic Spline Interpolation

Cubic Spline interpolation defines a cubic spline equation for each set of points between the _1st_ and _nth_ points. Each equation is smooth in its first derivative and continuos in its second derivative.

So for example, if the points on a curve are labelled _i_, where _i = 1..n_, the equations representing any two points _i_ and _i-1_ will look like this:

$$
\begin{align}
    a_{i}x^3_{i} + b_{i}x^2_{i} + c_{i}x_{i} + d_{i} = y_{i}
\end{align}
$$


$$
\begin{align}
    a_{i-1}x^3_{i-1} + b_{i-1}x^2_{i-1} + c_{i-1}x_{i-1} + d_{i-1} = y_{i-1}
\end{align}
$$

Cubic spline interpolation involves finding the second derivative of all points $$ y_{i} $$, which can then be used for evaluating the cubic spline polynomial, which is a function of _x_, _y_ and the second derivatives of _y_.

For more information read [this](http://mathworld.wolfram.com/CubicSpline.html) resource.

``` ruby

require 'interpolation'

x = (0..9).step(1).to_a
y = x.map { |e| Math.exp(e) }

f = Interpolation::OneDimensional.new(@x, @y, type: :cubic, sorted: true)
f.interpolate(2.5)
# => 12.287
```