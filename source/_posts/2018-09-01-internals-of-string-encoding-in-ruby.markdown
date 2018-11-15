---
title: Internals of string encoding in Ruby.
date: 2018-09-01T13:53:20+09:00
---

# Introduction

String encoding is an important matter in Ruby, however most of the blog posts
that I came acoross (some of which are linked at the end of this post) tend to
look at a 'user-level' point of view of the subject and do not explore Ruby
internals with respect to string encoding. In this blog post I will try to 
shed some light on the topic and talk about the important APIs and terminologies
that one should be aware of when interfacing with Ruby strings internally.

## Code points and character sets

Character sets and code points are abstractions that sit between bytes and encodings. 
A character set defines a group of characters, their order, and it assigns each an 
identifier. The identifier is known as a “code point”. It allows for character 
interaction without having to understand the underlying byte structure of a character.

So basically code point is group of bytes that make a character. It can be thought of
as the 'visual' size of the string. The `size` method on a string actually returns
the number of code points in the string. 

## Unicode characters in regular Ruby strings

Using the `\u` escape sequence, we can specify the value of an 8-bit hexadecimal string
in Ruby.

## Usual string encodings

The default string encoding in Ruby is UTF-8.

## Byte strings

Byte strings can be said to be just a sequence of bytes. They are not necessarily
human-readable (in a way that makes sense). The closest brother of byte strings in Ruby
can be [Python byte strings](https://stackoverflow.com/questions/6224052/what-is-the-difference-between-a-string-and-a-byte-string).

These strings do not implicitly carry an encoding any must be 'coded' into a particular
encoding before being used. They're primary use case is for storing data to disk in
machine readable form. The size of a byte string is exactly the same as the number of
characters in the string.

Since UTF-8 is the default string encoding, you need to force Ruby to convert a string
into a byte string (a.k.a US-ASCII) string using the `force_encoding` method. For example:
``` ruby
2.4.1 :026 > a = "ありが"
# => "ありが" 
2.4.1 :027 > a.bytes
# => [227, 129, 130, 227, 130, 138, 227, 129, 140] 
2.4.1 :028 > a.force_encoding "US-ASCII"
# => "\xE3\x81\x82\xE3\x82\x8A\xE3\x81\x8C" 
2.4.1 :029 > a.bytes
# => [227, 129, 130, 227, 130, 138, 227, 129, 140] 
```

Unfortunately there is no direct way of specifying byte strings in Ruby like the `b''`
short-hand syntax in Python.

## Useful APIs

The `RSTRING_LEN()` macro returns the string data **in bytes** as variable of `size_t` type.

The encoding of strings is stored in the `rb_encoding` data type.

The `rb_str_new()` function that is used for creating strings from `char*` arrays returns
Ruby strings are encoded as `US-ASCII`.

`rb_enc_get_index(VALUE obj)` gives an integer value for the particular encoding. The file
[encindex.h](https://github.com/ruby/ruby/blob/trunk/encindex.h) defines several constants that
are associate a single `int` with the encoding of a string. These macros can be combined with
`rb_enc_get_index` to easily compare the encoding of a Ruby string. However, this file is not
accesssible for C extension writers since it is not present under the `include/ruby` directory.

Since I cannot yet find a fast and simple way of checking the encoding via C API calls,
I'm resorting to rather ugly and slow Ruby method calls. Here's the functions:

``` ruby
```

# Other posts and links

* Andre Arko's blogpost : https://andre.arko.net/2013/12/01/strings-in-ruby-are-utf-8-now/
* The string type is broken: https://mortoray.com/2013/11/27/the-string-type-is-broken/
* String encodings book : https://aaronlasseigne.com/books/mastering-ruby/strings-and-encodings/
* Ruby encoding wikibook: https://en.wikibooks.org/wiki/Ruby_Programming/Encoding
* Post with some internals of bytes: https://www.justinweiss.com/articles/3-steps-to-fix-encoding-problems-in-ruby/
* Helpful blog on some internals: https://blog.codeship.com/how-ruby-string-encoding-benefits-developers/
* Post from Yehuda Katz: https://yehudakatz.com/2010/05/17/encodings-unabridged/
* https://blog.daftcode.pl/fixing-unicode-for-ruby-developers-60d7f6377388
