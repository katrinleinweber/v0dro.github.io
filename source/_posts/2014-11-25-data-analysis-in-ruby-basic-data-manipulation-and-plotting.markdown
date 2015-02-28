---
layout: post
title: "Data Analysis in RUby: Basic data manipulation and plotting"
date: 2014-11-25 13:55:13 +0530
comments: true
categories: 
---

daru (Data Analysis in RUby) is a ruby gem for performing various data analysis and manipulation tasks in Ruby. It draws inspiration from pandas (python) and aims to be completely cross-compatible between all ruby implementations (MRI/JRuby etc.) yet leverage the individual benefits that each interpreter offers (for example the speed of C in MRI), while offering a simple and powerful API for data analysis, manipulation and visualization.

In this first article on daru, I will show you some aspects of how daru handles data and some operations that can be performed on a real-life data set.

## Getting Started

daru consists of two major data structures:

* **Vector** - A named one-dimensional array-like structure.
* **DataFrame** - A named spreadsheet-like two-dimensional frame of data.

A _Vector_ can either be represented by a Ruby Array, NMatrix(MRI) or MDArray(JRuby) internally. This allows for fast data manipulation in native code. Users can change the underlying implementation at will (demonstrated in the [next](/blog/2015/02/24/data-analysis-in-ruby-part-2/) blog post).

Both of these can be indexed by the `Daru::Index` or `Daru::MultiIndex` class, which allows us to reference and operate on data by name instead of the traditional numeric indexing, and also perform index-based manipulation, equality and plotting operations.

#### Vector

The easiest way to create a vector is to simply pass the elements to a `Daru::Vector` constructor:

``` ruby

v = Daru::Vector.new [23,44,66,22,11]

# This will create a Vector object v

# => 
##<Daru::Vector:78168790 @name = nil @size = 5 >
#   ni
# 0 23
# 1 44
# 2 66
# 3 22
# 4 11
```

Since no name has been specified, the vector is named `nil`, and since no index has been specified either, a numeric index from 0..4 has been generated for the vector (leftmost column).

A better way to create vectors would be to specify the name and the indexes:

``` ruby

sherlock = Daru::Vector.new [3,2,1,1,2], name: :sherlock, index: [:pipe, :hat, :violin, :cloak, :shoes]

#=> 
#<Daru::Vector:78061610 @name = sherlock @size = 5 >
#         sherlock
#    pipe       3
#     hat       2
#  violin       1
#   cloak       1
#   shoes       2
```

This way we can clearly see the quantity of each item possesed by Sherlock.

Data can be retrieved with the `[]` operator:

``` ruby

sherlock[:pipe] #=> 3
```

#### DataFrame

A basic DataFrame can be constructed by simply specifying the names of columns and their corresponding values in a hash:

``` ruby

df = Daru::DataFrame.new({a: [1,2,3,4,5], b: [10,20,30,40,50]}, name: :normal)

# => 
##<Daru::DataFrame:77782370 @name = normal @size = 5>
#            a      b 
#     0      1     10 
#     1      2     20 
#     2      3     30 
#     3      4     40 
#     4      5     50 
```

You can also specify an index for the DataFrame alongwith the data and also specify the order in which the vectors should appear. Every vector in the DataFrame will carry the same index as the DataFrame once it has been created.

``` ruby
plus_one = Daru::DataFrame.new({a: [1,2,3,4,5], b: [10,20,30,40,50], c: [11,22,33,44,55]}, name: :plus_one, index: [:a, :e, :i, :o, :u], order: [:c, :a, :b])

# => 
##<Daru::DataFrame:77605450 @name = plus_one @size = 5>
#                c        a        b 
#       a       11        1       10 
#       e       22        2       20 
#       i       33        3       30 
#       o       44        4       40 
#       u       55        5       50
```

daru will also add `nil` values to vectors that fall short of elements.

``` ruby

missing =  Daru::DataFrame.new({a: [1,2,3], b: [1]}, name: :missing)
#=> 
#<Daru::DataFrame:76043900 @name = missing @size = 3>
#                    a          b 
#         0          1          1 
#         1          2        nil 
#         2          3        nil 
```

Creating a DataFrame by specifying `Vector` objects in place of the values in the hash will correctly align the values according to the index of each vector. If a vector is missing an index present in another vector, that index will be added to the vector with the corresponding value set to `nil`.

``` ruby

a = Daru::Vector.new [1,2,3,4,5], index: [:a, :e, :i, :o, :u]
b = Daru::Vector.new [43,22,13], index: [:i, :a, :queen]
on_steroids = Daru::DataFrame.new({a: a, b: b}, name: :on_steroids)
#=> 
#<Daru::DataFrame:75841450 @name = on_steroids @size = 6>
#                    a          b 
#         a          1         22 
#         e          2        nil 
#         i          3         43 
#         o          4        nil 
#     queen        nil         13 
#         u          5        nil 

```

A DataFrame can be constructed from multiple sources:

* To construct by columns:
    * **Array of hashes** - Where the key of each hash is the name of the column to which the value belongs.
    * **Name-Array Hash** - Where the hash key is set as the name of the vector and the data the corresponding value.
    * **Name-Vector Hash** - This is the most advanced way of creating a DataFrame. Treats the hash key as the name of the vector. Also aligns the data correctly based on index.
    * **Array of Arrays** - Each sub array will be considered as a Vector in the DataFrame.
* To construct by rows using the `.rows` class method:
    * **Array of Arrays** - This will treat each sub-array as an independent row.
    * **Array of Vectors** - Uses each Vector in the Array as a row of the DataFrame. Sets vector names according to the index of the Vector. Aligns vector elements by index.

## Handling Data

Now that you have a basic idea about representing data in daru, lets see some more features of daru by loading some real-life data from a CSV file and performing some operations on it.

For this purpose, we will use [iruby](https://rubygems.org/gems/iruby) notebook, with which daru is compatible. iruby provides a great interface for visualizing and playing around with data. I highly recommend installing it for full utilization of this tutorial.

#### Loading Data From Files

Let us load some data about the music listening history of one user from this subset of the [Last.fm data set](https://github.com/v0dro/daru/blob/master/spec/fixtures/music_data.tsv):

``` ruby

require 'daru'

df = Daru::DataFrame.from_csv 'music_data.tsv', col_sep: "\t"

```

{%img center /images/daru1/create_music_df.png 'Create a DataFrame from a TSV file.'%}

As you can see the *timestamp* field is in a somewhat non-Ruby format which is pretty difficult for the default Time class to understand, so we destructively map time zone information (IST in this case) and then change every *timestamp* string field into a Ruby _Time_ object, so that operations on time can be easily performed.

Notice the syntax for referencing a particular vector. Use 'row' for referencing any row.

``` ruby

df.timestamp.map! { |ts| ts += "+5:30"}

```
{%img center /images/daru1/dmap_vector.png 'Destructively map a given vector.'%}

``` ruby

require 'date'
df = df.map_rows do |row|
  row[:timestamp] = DateTime.strptime(row[:timestamp], '%Y-%m-%dT%H:%M:%SZ%z').to_time
  row
end

```

{%img center /images/daru1/df_row_map.png center 'Map all rows of a DataFrame.'%}

#### Basic Querying

A bunch of rows can be selected by specifying a range:

`df.row[900..923]`

{%img center /images/daru1/range_row_access.png center 'Accessing rows with a range' %}

#### Data Analysis

Lets dive deeper by actually trying to extract something useful from the data that we have. Say we want to know the name of the artist heard the maximum number of times. So we create a Vector which consists of the names of the artists as the index and the number of times the name appears in the data as the corresponding values:

``` ruby

# Group by artist name and call 'size' to see the number of rows each artist populates.
artists = df.group_by(:artname).size
```

{%img center /images/daru1/get_max_artists.png 'Create a vector of artist names vs number of times they appear.'%}

To get the maximum value out of these, use `#max_index`. This will return a Vector which has the max:

`count.max_index`

{%img center /images/daru1/artists_max.png 'Obtain the most heard artist.' %}

#### Plotting

daru uses [Nyaplot](https://github.com/domitry/nyaplot) for plotting, which is an optional dependency. Install nyaplot with `gem install nyaplot` and proceed.

To demonstrate, lets find the top ten artists heard by this user and plot the number of times their songs have been heard against their names in a bar graph. For this, use the `#sort` function, which will preserve the indexing of the vector.

``` ruby

top_ten = artists.sort(ascending: false)[0..10]

top_ten.plot type: :bar do |plt| 
  plt.width 1120 
  plt.height 500
  plt.legend true
end
```

{%img center /images/daru1/plot_top_ten.png 'Top ten artists plotted.'%}

## Further Reading

* This was but a very small subset of the capabilities of daru. Go through the [documentation](https://rubygems.org/gems/daru) for more methods of analysing your data with daru.
* You can find all the above examples implemented in [this notebook](http://nbviewer.ipython.org/github/v0dro/daru/blob/master/notebooks/intro_with_music_data_.ipynb).
* Contribute to daru on [github](https://github.com/v0dro/daru). Any contributions will be greatly appreciated!
* Many thanks to [last.fm](http://www.last.fm/) for providing the data.
* Check out the [next blog post in this series](/blog/2015/02/24/data-analysis-in-ruby-part-2/), elaborating on the next release of daru.



