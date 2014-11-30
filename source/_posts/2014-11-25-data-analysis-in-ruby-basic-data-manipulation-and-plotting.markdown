---
layout: post
title: "Data Analysis in RUby: Basic data manipulation and plotting"
date: 2014-11-25 13:55:13 +0530
comments: true
categories: 
---

daru (Data Analysis in RUby) is a ruby gem for performing various data analysis and manipulation tasks in Ruby. It draws inspiration from pandas (python) and aims to be completely cross-compatible between all ruby implementations (MRI/YARV/JRuby etc.) yet leverage the individual benefits that each interpreter offers (for example the speed of C in MRI).

In this first article on daru, I will show you some aspects of how daru handles data and some operations that can be performed on a real-life data set. We shall concludes by briefly going over what daru aims to be in the future.

daru as of now consists of two major data structures:
* *Vector* - A named one-dimensional array-like structure.
* *DataFrame* - A named spreadsheet-like two-dimensional frame of data.

A _Vector_ can either be represented by a Ruby Array, NMatrix(MRI) or MDArray(JRuby) internally. This allows for fast data manipulation in native code. Users can change the representation at will. Same goes for DataFrame as well.

Both of these are indexed by the _Index_ structure, which allows us to reference and operate on their data by name instead of the traditional numeric indexing present in arrays, and also match data according to named index.

## Getting Started

#### Vector

The easiest way to create a vector is to simply pass the elements to a `Daru::Vector` constructor:

`v = Daru::Vector.new [23,44,66,22,11]`

This will create a Vector object `v`:
` => 
#<Daru::Vector:78168790 @name = nil @size = 5 >
   ni
 0 23
 1 44
 2 66
 3 22
 4 11
`
Since no name has been specified, the vector is named `nil`, and since no index has been specified either, a numeric index from 0..4 has been generated for the vector (leftmost column).

A better way to create vectors would be to specify the name and the indexes:

`sherlock = Daru::Vector.new [3,2,1,1,2], name: :sherlock, index: [:pipe, :hat, :violin, :cloak, :shoes]`
` => 
#<Daru::Vector:78061610 @name = sherlock @size = 5 >
         sherlock
    pipe       3
     hat       2
  violin       1
   cloak       1
   shoes       2
`

This way we can clearly see the number of each item possesed by Sherlock.

#### DataFrame

A basic DataFrame can be constructed by simply specifying the names of columns and their corresponding values in a hash:

`df = Daru::DataFrame.new({a: [1,2,3,4,5], b: [10,20,30,40,50]}, name: :normal)`

` => 
#<Daru::DataFrame:77782370 @name = normal @size = 5>
            a      b 
     0      1     10 
     1      2     20 
     2      3     30 
     3      4     40 
     4      5     50 
`
You can also specify an index for the DataFrame alongwith the data and also specify the order in which the vectors should appear. Every vector in the DataFrame will carry the same index as the DataFrame once it has been created.

`plus_one = Daru::DataFrame.new({a: [1,2,3,4,5], b: [10,20,30,40,50], c: [11,22,33,44,55]}, name: :plus_one, index: [:a, :e, :i, :o, :u], order: [:c, :a, :b])`

` => 
#<Daru::DataFrame:77605450 @name = plus_one @size = 5>
                c        a        b 
       a       11        1       10 
       e       22        2       20 
       i       33        3       30 
       o       44        4       40 
       u       55        5       50 
`

daru will also add `nil` values to vectors that fall short of elements.

`missing =  Daru::DataFrame.new({a: [1,2,3], b: [1]}, name: :missing)`
` => 
#<Daru::DataFrame:76043900 @name = missing @size = 3>
                    a          b 
         0          1          1 
         1          2        nil 
         2          3        nil 
`
Creating a DataFrame by specifying `Vector` objects in place of the values in the hash will correctly align the values according to the index of each vector. If a vector is missing an index present in another vector, that index will be added to the vector with the corresponding value set to `nil`.

`a = Daru::Vector.new [1,2,3,4,5], index: [:a, :e, :i, :o, :u]`
`b = Daru::Vector.new [43,22,13], index: [:i, :a, :queen]`
`on_steroids = Daru::DataFrame.new({a: a, b: b}, name: :on_steroids)`

` => 
#<Daru::DataFrame:75841450 @name = on_steroids @size = 6>
                    a          b 
         a          1         22 
         e          2        nil 
         i          3         43 
         o          4        nil 
     queen        nil         13 
         u          5        nil 
`
A DataFrame can be constructed from multiple sources:
* An array of hashes, where the key of each hash is the name of the column to which the value belongs.
* A hash of arrays, where the hash key is set as the name of the column and the values are the hash value.
* A hash of vectors. This is the most advanced way of creating a DataFrame. 

## Handling Data

Now that you have a basic idea about representing data in daru, lets see some more features of daru by loading some real-life data from a CSV file and performing some operations on it.

For this purpose, we will use the [iRuby](https://rubygems.org/gems/iruby) notebook, with which daru is compatible. IRuby provides a great interface for visualizing and playing around with your code. I highly recommend installing it for full utilization of this tutorial.

Let us load some data about the music listening history of one user from the [Last.fm data set](https://github.com/v0dro/daru/blob/master/spec/fixtures/music_data.tsv) from a TSV file:

{%img /images/daru1/create_music_df.png 'Create a DataFrame from a TSV file.'%}

As you can see the *timestamp* field is in a somewhat non-Ruby format which is pretty difficult for the default Time class to understand, so we destructively map time zone information (IST in this case) to the already present timestamp and then change every *timestamp* string field into a Ruby _Time_ object, so that operations on time can be easily performed.

Notice the syntax for referencing a particular vector. Use 'row' for referencing any row.

{%img /images/dmap_vector.png 'Destructively map a given vector.'%}

{%img /images/df_row_map.png 'Map all rows of a DataFrame.'%}

A bunch of rows can be selected by specifying a range:

{%img /images/range_row_access.png 'Accessing rows with a range'%}



