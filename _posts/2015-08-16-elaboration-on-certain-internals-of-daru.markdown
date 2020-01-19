---
layout: post
title: "Elaboration on certain internals of daru"
date: 2015-08-16 13:36:34 +0530
comments: true
categories: 
---

In this blog post I will elaborate on how a few of the features in [daru](https://github.com/v0dro/daru) were implemeted. Notably I will stress on what spurred a need for that particular design of the code.

This post is primarily intended to serve as documentation for me and future contributors. If readers have any inputs on improving this post, I'd be happy to accept new contributions :)

## Index factory architecture

Daru currently supports three types of indexes, Index, MultiIndex and DateTimeIndex.

It became very tedious to write if statements in the Vector or DataFrame codebase whenever a new data structure was to be created, since there were 3 possible indexes that could be attached with every data set. This mainly depended on what kind of data was present in the index, i.e. tuples would create a MultiIndex, DateTime objects or date-like strings would create a DateTimeIndex, and everything else would create a Daru::Index.

This looked something like the perfect use case for the [factory pattern](https://en.wikipedia.org/wiki/Factory_method_pattern), the only hurdle being that the factory pattern in the pure sense of the term would be a superclass, something called `Daru::IndexFactory` that created an Index, DateTimeIndex or MultiIndex index using some methods and logic. The problem is that I did not want to call a separate class for creating Indexes. This would break existing code and possibly cause problems in libraries that were already using daru (viz. [statsample](https://github.com/SciRuby/statsample)), not to mention confusing users about which class they're actually supposed to be using.

The solution came after I read [this blog post](http://blog.sidu.in/2007/12/rubys-new-as-factory.html), which demonstrates that the `.new` method for any class can be overridden. Thus, instead of calling `initialize` for creating the instance of a class, it calls the overridden `new`, which can then call initialize for instantiating an instance of that class. It so happens that you can make `new` return any object you want, unlike initialize which must an instance of the class it is declared in. Thus, for the factory pattern implementation of Daru::Index, we over-ride the `.new` method of the Daru::Index and write logic such that it manufactures the appropriate kind of index based on the data that is passed to `Daru::Index.new(data)`. The pseudo code for doing this looks something like this:

``` ruby

class Daru::Index
  # some stuff...

  def self.new *args, &block
    source = args[0]

    if source_looks_like_a_multi_index
      create_multi_index_and_return
    elsif source_looks_like_date_time_index
      create_date_time_index_and_return
    else # Create the Daru::Index by calling initialize
      i = self.allocate
      i.send :initialize, *args, &block
      i
    end
  end

  # more stuff...
end
```

Also, since over-riding `.new` tampers with the subclasses of the class as well, [an `inherited` hook that replaces the over-ridden `.new`](https://github.com/v0dro/daru/blob/master/lib/daru/index.rb#L14) of the inherited class with the original one was added to `Daru::Index`.

## Working of the where clause

The where clause in daru lets users query data with a Array containing boolean variables. So whenever you call `where` on Daru::Vector or DataFrame, and pass in an Array containing true or false values, all the rows corresponding with `true` will be returned as a Vector or DataFrame respectively.

Since the where clause works in cojunction with the comparator methods of Daru::Vector (which return a Boolean Array), it was essential for these boolean arrays to be combined together such that piecewise AND and OR operations could be performed between multiple boolean arrays. Hence, the `Daru::Core::Query::BoolArray` class was created, which is specialized for handling boolean arrays and performing piecewise boolean operations.

The BoolArray defines the `#&` method for piecewise AND operations and it defines the `#|` method for piecewise OR operations. They work as follows:

``` ruby

require 'daru'

a = Daru::Core::Query::BoolArray.new([true,false,false,true,false,true])
#=> (Daru::Core::Query::BoolArray:84314110 bool_arry=[true, false, false, true, false, true])
b = Daru::Core::Query::BoolArray.new([false,true,false,true,false,true])
#=> (Daru::Core::Query::BoolArray:84143650 bool_arry=[false, true, false, true, false, true])
a & b
#=> (Daru::Core::Query::BoolArray:83917880 bool_arry=[false, false, false, true, false, true])
a | b
#=> (Daru::Core::Query::BoolArray:83871560 bool_arry=[true, true, false, true, false, true])
```
