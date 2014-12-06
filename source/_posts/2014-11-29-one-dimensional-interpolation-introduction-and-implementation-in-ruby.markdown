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

The spline method is found to be more accurate and hence that is what is used in the interpolation gem for interpolating with third degree polynomials.

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

This is a spline interpolation technique that uses a third degree poynomial to interpolate values. It works by determining an equation of the form $$ a_{n-1}x^2 + b_{n-1}x + c_{n-1} = d_{n-1} $$ for each pair of points _n-1_ and _n_. 