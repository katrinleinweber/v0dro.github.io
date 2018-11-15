---
title: RFC: Ruby C extension conventions
date: 2018-08-15T19:59:37+09:00
---

# Purpose

An accepted convention for writing Ruby C extensions.

# Reason

Too many C extensions with absoltely no correlation in terms of conventions.

# Proposal

## Ruby-specific things

### Ruby methods

All Ruby methods should have the name format `<class name>_<ruby method name>`. So the
`initialize` method of a class `NDTypes` would like so:
```
rb_define_method(cNDTypes, "initialize", NDTypes_initialize, 1);
```

### Ruby singleton methods

Singleton method names should be prefixed by a `s` before the method name. For example,
if you want to define a singleton `foo` inside a class `Bar`:
```
rb_define_singleton_method(cBar, "foo", Bar_s_foo, 1);
```

### Ruby classes

The `VALUE` variable containing Ruby classes should be prefixed with a `c`. So if
you're defining a Ruby class `NMatrix`, it would look like so:
```
VALUE cNMatrix = rb_define_class("NMatrix", rb_cObject);
```

### Ruby nested classes

If you have nested classes, the nested class name should come after the parent class,
separted by an underscore. For example, to define a class `Foo` nested inside `Bar`:
```
VALUE cBar = rb_define_class("Bar", rb_cObject);
VALUE cBar_Foo = rb_define_class_under(cBar, "Foo", rb_cObject);
```

### Ruby modules

### Parsing keyword arguments to Ruby methods

Since there is no direct way for accessing kwargs via C extensions we advocate usage
of

However, you should be mindful of this [bug](https://bugs.ruby-lang.org/issues/11339) and avoid arg
scanning in C for performance reasons.

## C-specific things

### General C function conventions

All functions should be defined as `static`.

### bang and boolean methods

Ruby supports method names ending in bang (`String#chomp!`) and boolean methods
ending in question mark (`Array#empty?`). The corresponding function in C will
end with `_bang` and `_qmark` respectively.

### Struct definitions

Struct definitions should always be done with a `typedef`. Nowhere in the code should you
use the `struct` keyword for specifying a type. Example:
```
typedef struct {
  int x;
  float y;
} foo_t;
```

### Default values for structs

Structs should be initialized to defaults with C99's compound literal syntax. For example:
``` c
typedef struct {
  int x;
  float y;
} foo_t;

foo_t var = { .x = 44, .y = 55.0 };
```

### Struct mark/free/size functions

Various functions required for GC marking, freeing and getting the size of structs should be
written using the convention `<struct name>_d<task name>`. So for example, the `mark` function
of type `foo_t` would be `foo_t_dmark`, `foo_t_dsize` and `foo_t_dfree`.

### Defining structs for telling Ruby how to handle C structs

The latest Ruby requires you to set the parameters of a C struct of type `rb_data_type_t` that
tells Ruby how to handle a particular C struct when it is encapsulated inside a Ruby object.

This must be declared as `static const`. The name of the struct must be postfix'd with `_type`
in order to name the type. Here's an example for a struct `foo`:
```
static const rb_data_type_t foo_type = {
  .wrap_struct_name = "foo",
  .function = {
    .dmark = foo_dmark,
    .dfree = foo_dfree,
    .dsize = foo_dsize,
  },
  .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};
```

Links:

* https://github.com/ruby/ruby/blob/trunk/doc/extension.rdoc#c-struct-to-ruby-object

### Macros

Macros should be `ALL_CAPITAL_WITH_SNAKE_CASE`.

## C APIs

Some important features of C APIs that will be exposed to other extensions of other
Ruby gems:

* API functions or any indirect functions that they call should never raise Ruby errors.
* Error conditions should be indicated by a numerical value. Ideally

## Internal Ruby objects for C extensions

It is common to create some internal Ruby objects that only visible via C extensions
for things like saving state between multiple Ruby objects. If you want to use these
objects as a means of sharing data between multiple Ruby objects, you need take some 
precautions when working with the Ruby GC.

## General organization of C files

Since C does not have namespaces, it becomes a little hard to keep track of data and the
functions that act on the data. Therefore, it is advisable to keep structs and the important
functions that act on the structs (like allocation, deallocation, marking, etc.) together
for fast reference and reading of code.
