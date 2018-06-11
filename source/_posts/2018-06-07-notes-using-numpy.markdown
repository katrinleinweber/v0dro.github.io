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
- [Resources](#resources)

<!-- markdown-toc end -->

# Axes in numpy

Axes in numpy are defined for arrays in more than one dim. A 2D array has the 0th axis running
vertically _downwards_ across rows and the 1st axis is running _horizontally_ running across
columns.

See https://docs.scipy.org/doc/numpy-1.10.0/glossary.html

# Printoptions

The `numpy.printoptions` function can be used for setting various global print options like
linewidth and precision during printing to console. Useful for debugging and viewing.

# Debugging

The `pdb` module is useful for debugging python. Place `pdb.set_trace()` in some place
in the code where you want the code to break. It will then provide you with a python
REPL.

Here's a link to it: https://pythonconquerstheuniverse.wordpress.com/2009/09/10/debugging-in-python/

# Resources
