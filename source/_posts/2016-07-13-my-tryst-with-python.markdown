---
layout: post
title: "My tryst with Python"
date: 2016-07-13 16:24:23 +0530
comments: true
published: false
categories: 
---

A particular course in college called Computational Problem Solving required me to learn Python and use it as a demo language for all sorts of computer science problems involving sorting, searching, types of algorithms and different types of data structures. I'm a Rubyist at heart and not at all a fan of Python and will not use the language unless I have to. This rather lengthy blog post is for documenting whatever I did with Python for this particular course.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [Sorting](#sorting)
    - [-](#-)
    - [Insertion sort](#insertion-sort)
    - [Selection Sort](#selection-sort)
    - [Quick sort](#quick-sort)
    - [Heap sort](#heap-sort)
- [Printing directory contents](#printing-directory-contents)
    - [Lessons learnt](#lessons-learnt)
- [Zipping in Python](#zipping-in-python)
- [Weird python keywords](#weird-python-keywords)
    - [in keyword](#in-keyword)
        - [Inside if statements](#inside-if-statements)
        - [Inside for statements](#inside-for-statements)

<!-- markdown-toc end -->


# Sorting

I have implemented quite a few sorting algorithms in Python. I will document each of them 
and my interpretation of these and also post sample code.

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

Worst case time complexity of this algorithm is O(n^2). The best case performance is O(n). 
This algorithm is better than selection sort since it is adapative and does not necessarily 
need to swap elements if they are already in sorted order.

#### Selection Sort

Worst case time complexity of this algorithm is O(n^2). It differs from insertion sort
in a way that insertion sort picks up the first element after the sorted sublist (in the 
unsorted sublist) and finds a place for it in the sorted sublist, while selection sort 
selects the smallest element in the unsorted sublist and adds it to the end of the sorted sublist.

#### Quick sort

This has worst case time complexity of O(n^2) if swapping needs to be done for every element, 
but this behaviour is rare. Average case time complexity is O(nlog(n)).

#### Heap sort

This is similar to insertion sort, but the difference is that a heap data structure is used for getting the largest element from the unsorted list. For this reason, it has a worst case complexity of O(nlog(n)). Best case time complexity is O(n) or O(nlog(n)).

# Printing directory contents

A sample problem given is this:
``` python
def print_directory_contents(sPath):
    """
    This function takes the name of a directory 
    and prints out the paths files within that 
    directory as well as any files contained in 
    contained directories. 

    This function is similar to os.walk. Please don't
    use os.walk in your answer. We are interested in your 
    ability to work with nested structures. 
    """
   pass
```

I wrote the following function to demonstrate my usage of nested structures in Python.
```
import os
from os import listdir

def really_get_contents(s, indent, path):
    contents = listdir(path)
    
    for content in contents:
        s += "-"*indent + str(content) + "\n"
        if os.path.isdir(path + content):
            s = really_get_contents(s, indent+2, path + content + "/")
            
    return s

"""
Print the directory contents recursively of every directory specified in path.
"""
def print_directory_contents(path):
    s = ""
    indent = 0
    return really_get_contents(s, indent, path)

s = print_directory_contents("/home/1/17M38101/gitrepos/hpc_lecture/")
print(s)
```

## Lessons learnt

* Python strings are immutable.
* Use `os.path.join` for joining two strings that represent paths. This makes it cross-platform.

# Zipping in Python

For zipping together two arrays in Ruby, one can simply call `[1,2,3].zip ["a", "b", "c"]` and
it will return an Array like `[[1, "a"], [2, "b"], [3, "c"]]`.

However in Python, the built-in `zip` function returns an iterable object using which you
can iterate over the zipped values. For example:
```
In [6]: zip([1,2,3], ["a", "b", "c"])
Out[6]: <zip at 0x7f582adc1888>
```
The iterator contains pairs of tuples. You can then create a list out of these tuples using
`list(zip([1,2,3], ["a", "b", "c"]))`, or even a `dict` if you use the `dict()` function.

# Weird python keywords

## in keyword

### Inside if statements

This keyword is usually used in `if` statements to check if some elements exists in a list:
``` python
a = [1,2,3]
if 1 in a:
    print("yes!")
```

However, when it is used with a dict like so:
``` python
a = {1 : "a", 2 : "b", 3 : "c"}
if "a" in a:
    print("yes!")
else:
    print("no!")
```
It checks whether a particular key is present in the dict or not.

Link: https://pycruft.wordpress.com/2010/06/10/pythons-in-keyword/

### Inside for statements

Used for iterating over the elements of a list or keys of a dict.

# Mutable (saved) function arguments

Consider the following code:
``` python
def f(x,l=[]):
    for i in range(x):
        l.append(i*i)
    print(l) 

f(2)
f(3,[3,2,1])
f(3)
```
The output of the third line is `[0, 1, 0, 1, 4]`(!!!!!).

This is because when the subsequent function call that uses the default argument is 
called, it uses the same memory block as the previous call. This is weird because
a function is supposed to a self-contained unit that is not affected by code outside
its scope.

List default arguments are better used by specifying `None` as the default and then
checking if the argument is actually `None` as assigning it to a `list` if yes.

Link: http://docs.python-guide.org/en/latest/writing/gotchas/

# Decorators

A decorator is a special kind of function that either takes a function and returns a
function, or takes a class and returns a class. The `@` behind it is just syntactic
sugar that allows you to decorate something in a way that's easy to read.

The idea is based on the fact that functions are first-class objects in Python (unlike
Ruby). Thus we can return functions or assign them variables like any other value. This
is the propery that allows defining functions inside other functions. Compared to Ruby,
this property is like passing a block to the method by defining a function and passing
the function instead of a closure.

A decorator allows you to create a function call that calls the decorated function with
the name that is specified in the decorator, so that you can call the function by its name
rather than passing it into a call to some other function. So for example:
``` python
@time_this
def func_a(stuff):
    do_important_thing()
```
...is exactly equal to:
``` python
def func_a(stuff):
    do_important_thing()
func_a = time_this(func_a)
```

It is also possible to pass arguments to decorators depending on what context you
want a particular function to be called. So you can define functions inside decorator
functions that get called based on some argument that you pass to the decorator when
defining it above a method/class. For example:
``` python
@requires_permission('administrator')
def delete_user(iUserId):
   """
   delete the user with the given Id. 
   This function is only accessible to users with administrator permissions
   """
```
An example of implementing such 'nested decorators' can be the following code:
``` python
def outer_decorator(*outer_args,**outer_kwargs):
    def decorator(fn):
        def decorated(*args,**kwargs):
            do_something(*outer_args,**outer_kwargs)
            return fn(*args,**kwargs)
        return decorated
    return decorator
    
@outer_decorator(1,2,3)
def foo(a,b,c):
    print a
    print b
    print c

foo()
```
You can imagine the `outer_decorator` as being 'created' during the `@` call and the
`decorator` being placed in its place with the arguments `1,2,3` saved in the function
call. So now you can call the `decorator` decorator with whatever arguments you want
placed above the function call.

My personal take on decorators is that they feel a little jugaadu (Hindi for hack-y) and
can lead to problems if you don't read the decorator above a function and it does something
unexpected after you call it.

Link: 
* https://www.codementor.io/sheena/advanced-use-python-decorators-class-function-du107nxsv
* https://www.codementor.io/sheena/introduction-to-decorators-du107vo5c

# The super method

Unlike Ruby, the `super` keyword in Python returns a proxy object to delegate method calls
to a class. Its not just a method that calls the method of the same name in the super class.
Also, since Python supports multiple inheritance (ability for a single class to inherit from
multiple classes), this functionality allows users to specify the class from which they want
to call a particular method.

Link: http://www.pythonforbeginners.com/super/working-python-super-function

# The Garbage Collector

The Python interpreter maintains a count of references to each object in memory.
If a reference count goes to zero then the associated object is no longer alive 
and the memory allocated to that object can be freed. This is a different mechanism
from the Ruby GC, which scans the stack space for unused objects.

CPython uses a generational garbage collector alongwith the reference counting. This
is due to the presence of reference cycles. If an object contains references to other
objects, then their reference count is decremented too. Thus other objects may be
deallocated in turn.

Variables, which are defined inside blocks (e.g., in a function or class) have a 
local scope (i.e., they are local to its block). If Python interpreter exits from 
the block, it destroys all references created inside the block. The reference counting 
algorithm has a lot of issues, such as circular references, thread locking and memory 
and performance overhead.

The generational GC classifies objects into three generations. Every new object starts 
in the first generation. If an object survives a garbage collection round, it moves 
to the older (higher) generation. Lower generations are collected more often than 
higher. Because most of the newly created objects die young, it improves GC performance
and reduces the GC pause time.

I think this mechanism is both good and bad for C extension writers. Good because
you can explicitly maintain control on which objects get freed and which don't (using
references). Bad because it increases the complexity of C extensions (but there's 
Cython for that).

Link: https://rushter.com/blog/python-garbage-collector/
