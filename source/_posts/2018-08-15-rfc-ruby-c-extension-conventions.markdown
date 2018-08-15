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

### Ruby classes

The `VALUE` variable containing Ruby classes should be prefixed with a `c`. So if
you're defining a Ruby class `NMatrix`, it would look like so:
```
VALUE cNMatrix = rb_define_class("NMatrix", rb_cObject);
```

### Ruby modules



## C-specific things
