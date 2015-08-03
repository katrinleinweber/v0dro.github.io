---
layout: post
title: "finding and combining data in daru"
date: 2015-08-03 00:22:19 +0530
comments: true
categories: 
---

## Arel-like query syntax

[Arel](https://github.com/rails/arel) is a very popular ruby gem that is one of the major components of the most popular ruby framework, [Rails](https://github.com/rails/rails). It is an ORM-helper of sorts that exposes a beatiful and intuitive syntax for creating SQL strings by chaining Ruby methods.

Daru successfully adopts this syntax and the result is a very intuitive and readable syntax for obtaining any sort of data from a DataFrame or Vector.

As a quick demonstration, lets create a DataFrame which looks like this:

``` ruby

require 'daru'

df = Daru::DataFrame.new({
  a: [1,2,3,4,5,6]*100,
  b: ['a','b','c','d','e','f']*100,
  c: [11,22,33,44,55,66]*100
}, index: (1..600).to_a.shuffle)
df.head(5)

#=> 
##<Daru::DataFrame:80543480 @name = 3fc642f2-bd9a-4f6f-b4a8-0779253720f5 @size = 5>
#                    a          b          c 
#       109          1          a         11 
#       381          2          b         22 
#       598          3          c         33 
#       390          4          d         44 
#       344          5          e         55
```
  
To select all rows where `df[:a]` equals 2 or `df[:c]` equals 55, just write this:

``` ruby

selected = df.where(df[:a].eq(2) | df[:c].eq(55))
selected.head(5)

# => 
##<Daru::DataFrame:79941980 @name = 74175f76-9dce-4b5d-b85b-bdfbb650953e @size = 5>
#                    a          b          c 
#       381          2          b         22 
#       344          5          e         55 
#       135          2          b         22 
#       524          5          e         55 
#       266          2          b         22 
```

As is easily seen above, the Daru::Vector class has special comparators defined on it, which allow it to check each value of the Vector and return an object that can be evaluated by the `DataFrame#where` method.

**Notice that to club the two comparators above, we have used the union OR (`|`) operator.**

Daru::Vector has a bunch of comparator methods defined on it, which can be used with `#where` for obtaining the desired results. All of these return an object of type `Daru::Core::Query::BoolArray`, which is read by `#where`. `BoolArray` uses the methods `|` (also aliased as `#or`) and `&` (also aliased as `#and`) for piecewise logical operations on other `BoolArray` objects.

BoolArray consists of an internal Array that contains `true` for every entry in the Vector that returns `true` for an operation between the comparable operand and a Vector entry.

For example,

``` ruby

require 'daru'

vector = Daru::Vector.new([1,2,3,4,5,6,7,8,2,3])
vector.eq(3)
#=>(Daru::Core::Query::BoolArray:82379030 bool_arry=[false, false, true, false, false, false, false, false, false, true])
```

The `#&` (or `#and`) and `#|` (or  `#or`) methods on BoolArray apply a logical `and` and a logical `or` respectively between each element of the BoolArray and return another BoolArray that contains the results. For example:

``` ruby

require 'daru'

vector = Daru::Vector.new([1,2,3,4,5,6,7,7,8,9,9,9,7,5,4,3,4])
vector.eq(4).or(vector.mt(8))
#=> (Daru::Core::Query::BoolArray:82294620 bool_arry=[false, false, false, true, false, false, false, false, false, true, true, true, false, false, true, false, true]) 
```

The following comparators can be used with a `Daru::Vector`:

|Comparator Method|Description|
|:-:|:-|
|---
|`eq`| Uses `==` and returns `true` for each **equal** entry |
|`not_eq`| Uses `!=` and returns `true` for each **unequal** entry|
|`lt`| Uses `<` and returns `true` for each entry **less than** the supplied object|
|`lteq`| Uses `<=` and returns `true` for each entry **less than or equal to** the supplied object |
|`mt`| Uses `>` and returns `true` for each entry **more than** the supplied object |
|`mteq`| Uses `>=` and returns `true` for each entry **more than or equal to** the supplied object |
|`in`| Uses `==` for each element in the collection (Array, Daru::Vector, etc.) passed and returns `true` for a match|

A major advantage of using the `#where` clause over `DataFrame#filter` or `Vector#keep_if`, apart from better readability and usability, is that it is much faster. [These benchmarks](https://github.com/v0dro/daru/blob/master/benchmarks/where_vs_filter.rb) prove my point.

I'll conclude this chapter with a little more complex example of using the arel-like query syntax with a `Daru::Vector` object:

``` ruby

require 'daru'

vec = Daru::Vector.new([1,2,3,4,5,6,3,336,3,6,2,6,2,35,346,7,3,45,23,26,7,345,2525,22,66,2])
vec.where((vec.eq(4) | vec.eq(1) | vec.mt(300)) & vec.lt(2000))
# => 
# #<Daru::Vector:70585830 @name = nil @size = 5 >
#     nil
#   0   1
#   3   4
#   7 336
#  14 346
#  21 345
```

For more examples on using the arel-like query syntax, see [this notebook]().
## Joins

Daru::DataFrame offers the `#join` method for performing SQL style joins between two DataFrames. Currently #join supports inner, left outer, right outer and full outer joins between DataFrames.

In order to demonstrate joins, lets consider a single example of an inner on two DataFrames:

``` ruby

require 'daru'

left = Daru::DataFrame.new({
  :id   => [1,2,3,4],
  :name => ['Pirate', 'Monkey', 'Ninja', 'Spaghetti']
})
right = Daru::DataFrame.new({
  :id => [1,2,3,4],
  :name => ['Rutabaga', 'Pirate', 'Darth Vader', 'Ninja']
})
left.join(right, on: [:name], how: :inner)

#=> 
##<Daru::DataFrame:73134350 @name = 7cc250a9-108c-4ea3-99ab-dcb828ff2b88 @size = 2>
#                 id_1       name       id_2 
#         0          1     Pirate          2 
#         1          3      Ninja          4 
```

For more examples please refer [this notebook]().
