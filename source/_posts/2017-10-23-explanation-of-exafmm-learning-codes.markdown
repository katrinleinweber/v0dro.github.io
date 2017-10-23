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

These codes are for traversal of the tree that was created in the previous step.

## step1.cxx

This step implements the P2M and M2M passes of the FMM.

One major difference between the C++ and Ruby implementation is that since Ruby does not have pointers, I
have used the array indices of the elements instead. For this purpose there are two attributes in the
`Cell` class called `first_child_index` that is responsible for holding the index in the `cells` array
about the location of the first child of this cell, and the second `first_body_index` which is responsible for holding the index of the body in the `bodies` array.
