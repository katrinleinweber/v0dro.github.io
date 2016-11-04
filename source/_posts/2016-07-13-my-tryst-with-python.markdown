---
layout: post
title: "My tryst with Python"
date: 2016-07-13 16:24:23 +0530
comments: true
published: false
categories: 
---

A particular course in college called Computational Problem Solving required me to learn Python and use it as a demo language for all sorts of computer science problems involving sorting, searching, types of algorithms and different types of data structures. I'm a Rubyist at heart and not at all a fan of Python and will not use the language unless I have to. This rather lengthy blog post is for documenting whatever I did with Python for this particular course.

# Sorting

I have implemented quite a few sorting algorithms in Python. I will document each of them and my interpretation of these and also post sample code.

#### Bubble sort

#### Insertion sort

Insertion basically maintains two lists within a single unsorted list: the partially sorted list and the unsorted the list. When sorting in ascending order the sorted list is to the left side.

This algorithm will start with the first element and keep it unchanged. It will then look at the second element, and if it is smaller than the first element it will shift the first element to second position and insert the second element in the position where the first element previously was. It proceeds in a similar fashion for the entire list. First see the element immediately to the right of the sorted list, if it is greater than the last element of the sorted list (i.e the element right before it) then let it be the way it is, otherwise scan the sorted list, see where the element can fit in, make space for that element and shift the list forward at that position such that space is made for that element and it can be inserted there.

In pseudo code:
```
while all_elements_have_not_been_checked
  if element_preceding_current_element > current_element
    pick_up_current_element
    scan_sorted_list_for_number_smaller_than_current_element
    shift_sorted_list_forward_by_one_position
    insert_number_in_now_vacant_position
```

This GIF from [Wikipedia](https://en.wikipedia.org/wiki/Insertion_sort) explains it pretty well:
{%img center /images/tryst_with_python/insertion_sort.gif 'Insertion sort' %}

Here's my python script. Python experts are welcome to suggest edits to make it faster/smaller.
``` python
# Insertion sort in Python

import random

arr = []
for x in xrange(0,1000):
  arr.append(random.randint(1,1000))

def scan_arr_for_correct_position(i, arr):
  current = arr[i]
  for x in xrange(0,i):
    if current < arr[x]:
      return x

i = 1
while i < len(arr):
  if arr[i-1] > arr[i]:
    current = arr[i]
    pos = scan_arr_for_correct_position(i, arr)
    for x in reversed(xrange(pos,i+1)):
      arr[x] = arr[x-1]

    arr[pos] = current

  i += 1

print(arr)
```

Worst case time complexity of this algorithm is O(n^2). The best case performance is O(n). This algorithm is better than selection sort since it is adapative and does not necessarily need to swap elements if they are already in sorted order.


#### Selection Sort

Worst case time complexity of this algorithm is O(n^2). It differs from insertion sort in a way that insertion sort picks up the first element after the sorted sublist (in the unsorted sublist) and finds a place for it in the sorted sublist, while selection sort selects the smallest element in the unsorted sublist and adds it to the end of the sorted sublist.

#### Quick sort

This has worst case time complexity of O(n^2) if swapping needs to be done for every element, but this behaviour is rare. Average case time complexity is O(nlog(n)).

#### Heap sort

This is similar to insertion sort, but the difference is that a heap data structure is used for getting the largest element from the unsorted list. For this reason, it has a worst case complexity of O(nlog(n)). Best case time complexity is O(n) or O(nlog(n)).