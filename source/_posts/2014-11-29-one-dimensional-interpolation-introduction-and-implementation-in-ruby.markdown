---
layout: post
title: "One Dimensional Interpolation: Introduction And Implementation In Ruby"
date: 2014-11-29 00:23:04 +0530
comments: true
categories: 
published: false
---

Interpolation involves predicting the co-ordinates of a point given the co-ordinates of points around it. Interpolation can be either one, two or n-dimensional. In this article I will give you a brief introduction of one-dimensional introduction and its implementation in Ruby using the [interpolation](https://github.com/v0dro/interpolation) gem.

One dimensional interpolation involves considering consecutive points along the X-axis with known Y co-ordinates and predicting the Y co-ordinate for a point on the X-axis that is not known previously.

There are several types of interpolation depending on the number of known points that we use for preedicting the Y co-ordinate of the unknown point, and several methods to compute them. Methods for interpolation include the classic Polynomial interpolation with Lagrange's formula or spline interpolation using the concept of spline equations between points.

The spline method is found to be more accurate and hence that is what is used in the interpolation gem for interpolating with first, second and third degree polynomials.

## Common Interpolation Routines

Let's see a few common interpolation routines and their implementation in Ruby:

#### Linear Interpolation

This is the simplest kind of interpolation. It involves simply considering two points such that x[j] < num < x[j+1], where _num_ is the unknown point, and considering the slope of the straight line between _x[j]_ and _x[j+1]_, simply predicts the Y co-ordinate.


#### Cubic Spline Interpolation

This is a spline interpolation technique that uses a third degree poynomial to interpolate values.