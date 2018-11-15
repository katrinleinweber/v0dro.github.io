---
title: Internals of floating point numbers in Ruby.
date: 2018-09-01T08:51:03+09:00
---

# Basics of floating point numbers

Links:

* https://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html

## Endianess

Endianess is the sequential order in which bytes are arragned in a machine.

The macro `WORDS_BIGENDIAN` from gcc can be used for telling whether the machine you are
on is using big-endian or little-endian encoding.

Link:

* 

# Ruby floating point numbers

Most of the functionality for 32-bit and 64-bit floating point numbers (the
majority types found in scientific computing code) are handled by Ruby.

The RFloat struct contains the value for the floating point number. The definition
can be found in the `internal.h` file [here](https://github.com/ruby/ruby/blob/trunk/internal.h#L654).

This is what it looks like:
```
struct RFloat {
    struct RBasic basic;
    double float_value;
};
```
As can be seen, Ruby always stores numbers as `double` which is 64-bits long on most
machines. To access the `double` value of a `Float` Ruby object, one can use the
`RFLOAT_VALUE(VALUE v)` macro that ultimately calls the `rb_float_value_inline` function
present in `internal.h` file. There is no way to have 32-bit or 16-bit floating point numbers
in Ruby.

In Ruby, the [numeric.c](https://github.com/ruby/ruby/blob/trunk/numeric.c) file contains the code for working with floats.

Ruby uses a technique called 'FLONUM' for speeding up 64-bit floating point calculations.
The proposal for this can be found [here](https://bugs.ruby-lang.org/issues/6763). It basically
reduces the overhead of object creation by giving the same treatment to floats as is given
to 64-bit integers (treating the VALUE pointer as the value itself).

Links:

* http://patshaughnessy.net/2014/1/9/how-big-is-a-bignum
* https://www.slideshare.net/burkelibbey/ruby-internals
* http://gnu.huihoo.org/autoconf-2.13/html_node/autoconf_36.html

## The IEEE formats

Ruby uses the IEEE 754 format by default. If a machine does not contain the headers required
for this format, Ruby defines them [here]().


