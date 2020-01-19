---
title: Notes on learning emacslisp
date: 2018-03-26T11:33:21+09:00
---

Recently, I started development of an emacs language mode called [rubex-mode](https://github.com/v0dro/rubex-mode-emacs) for supporting Rubex syntax highlighting in emacs. This took me to the [ModeTutorial](https://www.emacswiki.org/emacs/ModeTutorial) on the emacs wiki, which is a very detailed tutorial for learning how to write new emacs language modes. Before starting the tutorial I had no knowledge of Emacslisp or writing emacs language modes.

In this post I will share some of the important things that I learned about Emacslisp and some things that I think are important about writing language modes for Emacs.

# Learning resources

* [Learn emacs lisp in 15 minutes](https://emacs-doctor.com/learn-emacs-lisp-in-15-minutes.html )
* [Programming in Emacs Lisp](https://www.gnu.org/software/emacs/manual/html_node/eintr/)
* [How to know whether to use single quote in elisp.](https://emacs.stackexchange.com/questions/715/how-to-know-when-or-when-not-to-use-the-single-quote-before-variable-names)
* [Quote in elisp](https://www.gnu.org/software/emacs/manual/html_node/elisp/Quoting.html)

# Emacs lisp basics

## Lisp evaluation

If you enable 'lisp-interaction-mode' in emacs you can evaluate lisp using the `C-j` 
shortcut. That will insert the result of the evaluation in the buffer. `C-x C-e` 
displays the same result in the minibuffer.

## Sexps

Programs are made of symbolic expressions (pre-fix notation), like `(+ 2 2)`, 
this means '2 + 2'.

Expressions are made of atomic expressions or more symbolic expressions. In `(+ 2 (+ 1 1))`, 
1 and 2 are atoms, (+ 2 (+ 1 1)) and (+ 1 1) are symbolic expressions.

## Getting and setting variables

`setq` stores a value into a variable:
``` elisp
(setq my-name "sameer")
```

Variables can also be initialized using `defvar`. The emacswiki page is [here](https://www.gnu.org/software/emacs/manual/html_node/eintr/defvar.html). 
`defvar` is similar to `setq`, but the difference is that `defvar` will not set the variable 
if it already has a value.

## Setting global constants

The `defconst` keyword is used for setting global constants. It informs a person reading your code that 
symbol has a standard global value, established here, that should not be changed by the user or by other
programs. Note that symbol is not evaluated; the symbol to be defined must appear explicitly in the defconst.

For example:
```
(defconst pi 3.141592653589793 "The value of Pi.")
```
Above code initializes the variable `pi` to a value and sets a docstring.

## Functions

Functions can be defined using the `defun` keyword. For example, to defined a function `hello` that accepts 
an argument `name` and inserts the variable with a string on the buffer:
```
(defun hello (name) (insert "Hello " name))
```

Fun fact: when evaluating elisp in a buffer, place the cursor at the bottom of the file otherwise emacs will 
only evaluate code until the cursor and throw unexpected output.

## Combining expressions

You can use the `progn` form for evaluating a set of expressions one by one and returning the value of the last one. 
The preceding expressions are only evaluated for their side effects and their values are discarded. 

All emacs commands are basically just elisp function calls. So you can call something like this:
```
(progn
  (switch-to-buffer-other-window "*scratch*")
  (hello "you"))
```
And it will switch the active window to the `*scratch*` buffer and print `Hello you` in the buffer.

A value can be bound to a local variable using `let`. This command can also be used for combining several sexps.
```
(let ((local-name "you"))
  (switch-to-buffer-other-window "*test*")
  (erase-buffer)
  (hello local-name))
```

## Quote

`quote` is a special form in elisp that returns its single argument, without 
evaluating it. This provides a way to include constants and lists, which are not 
self-evaluating objects, in a program. This [link](https://www.gnu.org/software/emacs/manual/html_node/elisp/Quoting.html) 
talks about it in detail.

Its used so often that a short form of using a single quote is often used instead (`'`). This 
[answer](https://emacs.stackexchange.com/questions/715/how-to-know-when-or-when-not-to-use-the-single-quote-before-variable-names) 
talks in detail about when to and when not to use it.

In general, if you are trying to use the variable itself, use the quoted form, 
otherwise directly use the variable name. For example, in the expression `(mapcar 'hello list-of-names)`, 
we use a quoted `hello` because don't actually want to call the function, we just want to pass a reference 
to it to the `mapcar` function which will then call `hello` at its own leisure.

## Lists

A list of names can be stored like so:
```
(setq list-of-names '("Sarah" "Chloe" "Mathilde"))
```

The above expression is quoted because we want to set the whole expression 
as a list to `list-of-names`.

Use the `car` function for getting the first element of the list and `cdr`
for getting all elements except the first element.

### Cons cells

Lists are composed of cons cells. Each cons cell is a tuple of two lisp objects,
the `car` and `cdr`. In the case of a list, the first slot of a cons cell holds 
the element of the list and the next part chains to the next element of the list. 
The cdr of the last cell of the list is `nil`. This helps in detecting the end 
of a list.

## Dotted pair notation

A dotted pair notation is a general syntax for creating cons cells that represents
the car and cdr explicitly.  In this syntax, `(a . b)` stands for a cons cell whose 
`car` is the object `a` and whose `cdr` is the object `b`. Dotted pair notation is 
more general than list syntax because the `cdr` does not have to be a list.

Dotted pairs can be chained together to form a list. For example, `(1 2 3)` is written 
as `(1 . (2 . (3 . nil)))`.

# Simple matrix multplication

# Writing an emacs major mode

## Basic mode setup

There are certain variables that all modes must define. Here's a list:
* `wpdl-mode-hook`: allows the user to run their own code when your mode is run.
* `wpdl-mode-map`: allows both you and your users to define their own keymaps.

In order to tell emacs that this mode must start when a particular file extension is detected, we add to a list called `auto-mode-alist` using the `add-to-list` function. For example:
```
(add-to-list 'auto-mode-alist '("\\.rubex\\'" . rubex-mode))
```

Protip: An `alist` is for historical reasons made of plain cons cells instead of full lists.

## Syntax highlighting


## Indentation
