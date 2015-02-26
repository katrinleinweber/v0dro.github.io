---
layout: post
title: "Data Analysis in RUby: Part 2"
date: 2015-02-24 00:19:08 +0530
comments: true
categories: 
---

I've just released daru version 0.0.5, which brings in a lot of new features and consolidates existing ones. [NMatrix](https://github.com/SciRuby/nmatrix) is now well integrated into Daru and all of the operations that can be performed using Arrays as the underlying implementation can be performed using NMatrix as well (except some operations involving missing data).

The new features include extensive support for missing data, hierarchial sorting of data frames and vectors by preserving indexing, ability to group, split and aggregate data with group by, and quickly summarizing data by generating excel-style pivot tables. This release also includes new aritmetic and statistical functions on Data Frames and Vectors. Both DataFrame and Vector are now mostly compatible with [statsample](https://github.com/clbustos/statsample), allowing for a much larger scope of statistical analysis by leveraging the methods already provided in statsample.

The interface for interacting with nyaplot for plotting has also been revamped, allowing much greater control on the way graphs are handled by giving direct access to the graph object. A new class for hierarchial indexing of data (called MultiIndex) has also been added, which is immensely useful when grouping/splitting/aggregating data.

Lets look at all these features one by one:

## Data Types

You can now either use Ruby Arrays or NMatrix as the underlying implementation. Since NMatrix is fast and makes use of C storage, it is recommended to use nmatrix when dealing with large sets of data. Daru will store any data as Ruby Array unless explicitly specified.

Thus to specify the data type of a Vector use the option `:dtype` and either supply it with `:array` or `:nmatrix`, and if using the NMatrix dtype, you can also specify the C data type that NMatrix will use internall by using the option `:nm_dtype` and supplying it with one of the NMatrix data types (it currently supports ints, floats, rationals and complex numbers. Check the docs for further details).

As an example, consider creating a Vector which uses NMatrix underneath, and stores data using the `:float64` NMatrix data type, which stands for double precision floating point numbers.

``` ruby

v = Daru::Vector.new([1.44,55.54,33.2,5.6],dtype: :nmatrix, nm_dtype: :float64)
#        nil
#    0  1.44
#    1 55.54
#    2  33.2
#    3   5.6
v.dtype #=> :nmatrix
v.type  #=> :float64
```

Another distinction between types of data that daru offers is `:numeric` and `:object`. This is a generic feature for distinguishing numerical data from other types of data (like Strings or DateTime objects) that might be contained inside Vectors or DataFrames. These distinctions are important because statistical and arithmetic operations can only be applied on structures with type numeric.

To query the data structure for its type, use the `#type` method. If the underlying implemetation is an NMatrix, it will return the NMatrix data type, otherwise for Ruby Arrays, it will be either `:numeric` or `:object`.

``` ruby

v = Daru::Vector.new([1,2,3,4], dtype: :array)
v.type #=> :numeric
```

Thus Daru exposes three methods for querying the type of data: 
* `#type` - Get the generic type of data to know whether numeric computation can be performed on the object. Get the C data type used by nmatrix in case of dtype NMatrix.
* `#dtype` - Get the underlying data representation (either :array or :nmatrix).

## Working with Missing Data

Any data scientist knows how common missing data is in real-life data sets, and to address that need, daru provides a host of functions for this purpose.
This functionality is still in its infancy but should be up to speed soon.

The `#is_nil?` function will return a Vector object with `true` if a value is `nil` and `false` otherwise.

``` ruby

v = Daru::Vector.new([1,2,3,nil,nil,4], index: [:a, :b, :c, :d, :e, :f])
v.is_nil?
#=> 
##<Daru::Vector:93025420 @name = nil @size = 6 >
#        nil
#    a   nil
#    b   nil
#    c   nil
#    d  true
#    e  true
#    f   nil
```

The `#nil_positions` function returns an Array that contains the indexes of all the nils in the Vector.

``` ruby

v.nil_positions #=> [:d, :e]
```

The `#replace_nils` functions replaces nils with a supplied value.

``` ruby

v.replace_nils 69
#=> 
##<Daru::Vector:92796730 @name = nil @size = 6 >
#    nil
#  a   1
#  b   2
#  c   3
#  d  69
#  e  69
#  f   4
```

The statistics functions implemented on Vectors ensure that missing data is not considered during computation and are thus safe to call on missing data.

## Hierarchical sorting of DataFrame

It is now possible to use the `#sort` function on Daru::DataFrame such that sorting happens hierarchically according to the order of the specified vector names.

In case you want to sort according to a certain attribute of the data in a particular vector, for example sort a Vector of strings by length, then you can supply a code block to the `:by` option of the sort method.

Supply the `:ascending` option with an Array containing 'true' or 'false' depending on whether you want the corresponding vector sorted in ascending or descending order.

``` ruby

df = Daru::DataFrame.new({
  a: ['ff'  ,  'fwwq',  'efe',  'a',  'efef',  'zzzz',  'efgg',  'q',  'ggf'], 
  b: ['one'  ,  'one',  'one',  'two',  'two',  'one',  'one',  'two',  'two'],
  c: ['small','large','large','small','small','large','small','large','small'],
  d: [-1,2,-2,3,-3,4,-5,6,7],
  e: [2,4,4,6,6,8,10,12,14]
  })

df.sort([:a,:d], 
  by: {
    a: lambda { |a,b| a.length <=> b.length }, 
    b: lambda { |a,b| a.abs <=> b.abs } 
  }, 
  ascending: [false, true]
)
```

{%img center /images/daru2/sorted_df.png 'Hierarchically sorted DataFrame' %}

Vector objects also have a similar sorting method implemented. Check the docs for more details. Indexing is preserved while sorting of both DataFrame and Vector.

## DSL for plotting with [Nyaplot](https://github.com/domitry/nyaplot)

Previously plotting with daru required a lot of arguments to be supplied by the user. The interface did not take advatage of Ruby's blocks, nor did it expose many functionalities of nyaplot. All that changes with this new version, that brings in a new DSL for easy plotting (recommended usage with [iruby notebook](https://github.com/minad/iruby)).

Thus to plot a line graph with data present in a DataFrame:

``` ruby

df = Daru::DataFrame.new({a: [1,2,3,4,5], b: [10,14,15,17,44]})
df.plot legends: [:a, :b], type: :line do |p,d|
  p.yrange [0,100]
  p.legend true
  d.color "green"
end
```
{%img center /images/daru2/line_graph.png 'Line Graph From DataFrame'%}

As you can see, the `#plot` function exposes the `Nyaplot::Plot` and `Nyaplot::Diagram` objects to user after populating them with the relevant data. So the new interface lets experienced users utilize the full power of nyaplot but keeps basic plotting very simple to use for new users or for quick and dirty visualization needs. Unfortunately for now, until a viable solution to interfacing with nyaplot is found, you will need to use the nyaplot API directly.

## Statistics and arithmetic on DataFrames.

Daru includes a host of methods for simple statistical analysis on numeric data. You can call `mean`, `std`, `sum`, `product`, etc. directly on the DataFrame. The corresponding computation is performed on numeric Vectors within the DataFrame, and missing data if any is excluded from the calculation by default.

So for this DataFrame:

``` ruby

df = Daru::DataFrame.new({
  a: ['foo'  ,  'foo',  'foo',  'foo',  'foo',  'bar',  'bar',  'bar',  'bar'], 
  b: ['one'  ,  'one',  'one',  'two',  'two',  'one',  'one',  'two',  'two'],
  c: ['small','large','large','small','small','large','small','large','small'],
  d: [1,2,2,3,3,4,5,6,7],
  e: [2,4,4,6,6,8,10,12,14],
  f: [10,20,20,30,30,40,50,60,70]
})
``` 

To calculate the mean of numeric vectors:

``` ruby

df.mean
```

{%img center /images/daru2/df_mean.png 'Calculate Mean of Numeric Vectors' %}

Apart from that you can use the `#describe` method to calculate many statistical features of numeric Vectors in one shot and see a summary of statistics for numerical vectors in the DataFrame that is returned. For example,

``` ruby

df.describe
```

{%img center /images/daru2/df_describe.png 'Describe Multiple Statistics in One Shot'%}

The covariance and correlation coeffiecients between the numeric vectors can also be found with `#cov` and `#corr`

``` ruby

df.cov
# => 
# #<Daru::DataFrame:91700830 @name = f5ae5d7e-9fcb-46c8-90ac-a6420c9dc27f @size # = 3>
#                     d          e          f 
#          d          4          8         40 
#          e          8         16         80 
#          f         40         80        400 
```

## Hierarchial indexing

A new way of hierarchially indexing data has been introduced in version 0.0.5. This is done with the new `Daru::MultiIndex` class. Hierarchial indexing allows grouping sets of similar data by index and lets you select sub sets of data by specifying an index name in the upper hierarchy.

A MultiIndex can be created by passing a bunch of tuples into the Daru::MultiIndex class. A DataFrame or Vector can be created by passing it a MultiIndex object into the `index` option. A MultiIndex can be used for determining the order of Vectors in a DataFrame too.

``` ruby

tuples = [
  [:a,:one,:bar],
  [:a,:one,:baz],
  [:a,:two,:bar],
  [:a,:two,:baz],
  [:b,:one,:bar],
  [:b,:two,:bar],
  [:b,:two,:baz],
  [:b,:one,:foo],
  [:c,:one,:bar],
  [:c,:one,:baz],
  [:c,:two,:foo],
  [:c,:two,:bar]
]

multi_index = Daru::MultiIndex.new(tuples)

vector_arry1 = [11,12,13,14,11,12,13,14,11,12,13,14]
vector_arry2 = [1,2,3,4,1,2,3,4,1,2,3,4]

order_mi = Daru::MultiIndex.new([
    [:a,:one,:bar],
    [:a,:two,:baz],
    [:b,:two,:foo],
    [:b,:one,:foo]])

df_mi = Daru::DataFrame.new([
    vector_arry1, 
    vector_arry2, 
    vector_arry1, 
    vector_arry2], order: order_mi, index: multi_index)
```

{%img center /images/daru2/multi_index_table.png 'DataFrame with hierarchical indexing' %}

Selecting a top level index from the hierarchy will select all the rows under that name, and return a new DataFrame with just that much data and indexes.

``` ruby

df_mi.row[:a]
```

{%img center /images/daru2/multi_index_partial.png 'Partial Selection Of Multi Indexed DataFrame'%}

Alternatively passing the entire tuple will return just that row as a `Daru::Vector`, indexed according to the column index.

``` ruby

df_mi.row[:a, :one,:bar]
```
{%img center /images/daru2/multi_index_exact.png 'Selecting A Single Row From A Multi Indexed DataFrame' %}

Hierachical indexing is especially useful when aggregating or splitting data, or generating data summaries as we'll see in the following examples.

## Splitting and aggregation of data

When dealing with large sets of scattered data, it is often useful to 'see' the data grouped according to similar values in a Vector instead of it being scattered all over the place.

The `#group_by` function does exactly that. For those familiar SQL, `#group_by` works exactly like the GROUP BY clause, but is much easier since its all Ruby.

The `#group_by` function will accept one or more Vector names and will scan those vectors for common elements that can be grouped together. In case multiple names are specified it will check for common attributes accross rows.

So for example consider this DataFrame:

``` ruby

df = Daru::DataFrame.new({
  a: %w{foo bar foo bar   foo bar foo foo},
  b: %w{one one two three two two one three},
  c:   [1  ,2  ,3  ,1    ,3  ,6  ,3  ,8],
  d:   [11 ,22 ,33 ,44   ,55 ,66 ,77 ,88]
})
#<Daru::DataFrame:88462950 @name = 0dbc2869-9a82-4044-b72d-a4ef963401fc @size = 8>
#            a          b          c          d 
# 0        foo        one          1         11 
# 1        bar        one          2         22 
# 2        foo        two          3         33 
# 3        bar      three          1         44 
# 4        foo        two          3         55 
# 5        bar        two          6         66 
# 6        foo        one          3         77 
# 7        foo      three          8         88 
```

To group this DataFrame by the columns `:a` and `:b`, pass them as arguments to the `#group_by` function, which returns a `Daru::Core::GroupBy` object.

Calling `#groups` on the returned `GroupBy` object returns a `Hash` with the grouped rows.

``` ruby

grouped = df.group_by([:a, :b])
grouped.groups
# => {
#  ["bar", "one"]=>[1],
#  ["bar", "three"]=>[3],
#  ["bar", "two"]=>[5],
#  ["foo", "one"]=>[0, 6],
#  ["foo", "three"]=>[7],
#  ["foo", "two"]=>[2, 4]}
```

To see the first group of each group from this collection, call `#first` on the `grouped` variable. Calling `#last` will return the last member of each group.

``` ruby

grouped.first

#=>           a          b          c          d 
#  1        bar        one          2         22 
#  3        bar      three          1         44 
#  5        bar        two          6         66 
#  0        foo        one          1         11 
#  7        foo      three          8         88 
#  2        foo        two          3         33 
```

On a similar note `#head(n)` will return the first `n` groups and `#tail(n)` the last `n` groups.

The `#get_group` function will select only the rows that a particular group belongs to and return a DataFrame with those rows. The original indexing is ofcourse preserved.

``` ruby

grouped.get_group(["foo", "one"])
# => 
# #<Daru::DataFrame:90777050 @name = cdd0afa8-252d-4d07-ad0f-76c7581a492a @size # = 2>
#                     a          b          c          d 
#          0        foo        one          1         11 
#          6        foo        one          3         77 
```

The `Daru::Core::GroupBy` object contains a bunch of methods for creating summaries of the grouped data. These currently include `#mean`, `#std`, `#product`, `#sum`, etc. and many more to be added in the future. Calling any of the aggregation methods will create a new DataFrame which will have the index as the group and the aggregated data of the non-group vectors as the corresponding value. Of course this aggregation will apply only to `:numeric` type Vectors and missing data will not be considered while aggregation.

``` ruby

grouped.mean
```
{%img center /images/daru2/group_by_mean.png 'Aggregating by Mean After Grouping' %}

A hierarchichally indexed DataFrame is returned. Check the `GroupBy` docs for more aggregation methods.

## Generating Excel-style Pivot Tables

You can generate an excel-style pivot table with the `#pivot_table` function. The levels of the pivot table are stored in MultiIndex objects.

To demonstrate with an example, consider [this CSV file on sales data](https://github.com/v0dro/daru/blob/master/spec/fixtures/sales-funnel.csv).

{%img center /images/daru2/pivot_table_data.png 'Data For Pivot Table Demo' %}

To look at the data from the point of view of the manager and rep:

``` ruby

sales.pivot_table index: [:manager, :rep]
```

{%img center /images/daru2/pivot_table_index.png 'Data Pivoted on Index Only.' %}

You can see that the pivot table has summarized the data and grouped it according to the manager and representative.

To see the sales broken down by the products:

``` ruby

sales.pivot_table(index: [:manager,:rep], values: :price, vectors: [:product], agg: :sum)
```

{%img center /images/daru2/pivoted_data.png 'Data Pivoted to Reflect Sales' %}

## Compatibility with statsample

Daru is now mostly compatible with [statsample](https://github.com/clbustos/statsample) and you can now mostly perform most of the functions by just passing it a Daru::DataFrame or Daru::Vector to perform most of the useful statistical functions provided by statsample.

Heres an example to demonstrate:

``` ruby

df = Daru::DataFrame.new({a: [1,2,3,4,5,6,7], b: [11,22,33,44,55,66,77]})

Statsample::Analysis.store(Statsample::Test::T) do
  t_2 = Statsample::Test.t_two_samples_independent(df[:a], df[:b])
  summary t_2
end

Statsample::Analysis.run_batch

# Analysis 2015-02-25 13:34:32 +0530
# = Statsample::Test::T
#   == Two Sample T Test
#     Mean and standard deviation
# +----------+---------+---------+---+
# | Variable |  mean   |   sd    | n |
# +----------+---------+---------+---+
# | a        | 4.0000  | 2.1602  | 7 |
# | b        | 44.0000 | 23.7627 | 7 |
# +----------+---------+---------+---+
# 
#     Levene test for equality of variances : F(1, 12) = 13.6192 , p = 0.0031
#     T statistics
# +--------------------+---------+--------+----------------+
# |        Type        |    t    |   df   | p (both tails) |
# +--------------------+---------+--------+----------------+
# | Equal variance     | -4.4353 | 12     | 0.0008         |
# | Non equal variance | -4.4353 | 6.0992 | 0.0042         |
# +--------------------+---------+--------+----------------+
# 
#     Effect size
# +-------+----------+
# | x1-x2 | -40.0000 |
# | d     | -12.0007 |
# +-------+----------+

```


##### References

* Pivot Tables example taken from [here](http://pbpython.com/pandas-pivot-table-explained.html). 
