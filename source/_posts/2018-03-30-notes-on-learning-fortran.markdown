---
title: Notes on learning FORTRAN
date: 2018-03-30T12:50:57+09:00
---

I've been trying to understand the distributed [block LU code written in ScaLAPACK](http://people.eecs.berkeley.edu/~demmel/cs267/lecture12/pdgetrf.f), which is written in FORTRAN. In order to understand the algorithms properly I took a 30 min crash course in FORTRAN. In this blog post I'll write some details about the language that are relevant to understanding the ScaLAPACK code.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Learning resources](#learning-resources)
- [Salient FORTRAN features](#salient-fortran-features)
- [FORTRAN w.r.t ScaLAPACK](#fortran-wrt-scalapack)
    - [Subroutines and functions](#subroutines-and-functions)
    - [Arrays](#arrays)
    - [Logical and comparison expressions](#logical-and-comparison-expressions)
    - [Loops](#loops)

<!-- markdown-toc end -->


# Learning resources

* [Fortran tutorial on tutorialspoint](https://www.tutorialspoint.com/fortran/index.htm).
* [Fortran tutorial website](https://www.fortrantutorial.com/).
* [Functions and subroutines](http://www.chem.ox.ac.uk/fortran/subprograms.html).
* [Presentation on F90 basics](http://pages.mtu.edu/~shene/COURSES/cs201/NOTES/F90-Basics.pdf).
* [Fortran Arrays](http://www.fortran.com/fortran_storenew/Html/Info/books/gd3_c04_1.html).
* [Logical and comparison expressions](http://www.pcc.qub.ac.uk/tec/courses/f90/stu-notes/F90_notesMIF_6.html).

# Salient FORTRAN features

Here's a simple addition program:
``` fortran
program addNumbers

! This simple program adds two numbers. This is a comment.
   implicit none
   
! Type declarations
   real :: a, b, result 
   
! Executable statements 
   a = 12.0
   b = 15.0
   result = a + b
   print *, 'The total is ', result
   
end program addNumbers 
```

Each program begins with keyword `program <prog_name>` and ends with `end program <prog_name>`.

A statement `implicit none` allows the compiler to check whether all variable types are declared correctly. This statement must be there to check if types have been declared correctly.

# FORTRAN w.r.t ScaLAPACK

## Subroutines and functions

I will now explain the `pdgetrf` routine from ScaLAPACK.

The `SUBROUTINE` keyword is used for defining subroutines. For example:
```
SUBROUTINE PDGETRF( M, N, A, IA, JA, DESCA, IPIV, INFO )
```
Types of arguments to subroutines are defined in the subroutine definition itself. For example, in scalapack:
``` fortran
*     .. Scalar Arguments ..
      INTEGER            IA, INFO, JA, M, N
*     ..
*     .. Array Arguments ..
      INTEGER            DESCA( * ), IPIV( * )
      DOUBLE PRECISION   A( * )
```

Unlike in C, the argument types are not declared alongwith the  name and argument list.

Functions and subroutines are different in FORTRAN. The main difference lies in the fact that functions can be used in an expression and can return only one value (exactly like functions in C or Java). A subroutine on the other hand, cannot be used in expressions, but has the advantage that it can be used for returning multiple values. In the respect of returning multiple values it is somewhat similar to MATLAB functions.

A subroutine ends with the `RETURN` and `END` statement. The arguements passed to a subroutine are similar to call by reference in the case of C. If you modify any value inside the subroutine, the value will be modified in the calling function too.

In order to tell the compiler the return value of a function, you must use the name of the function in an assignment statement that will tell the compiler the value to be returned. For example:
``` fortran
 REAL FUNCTION AVRAGE(X,Y,Z)
     REAL X,Y,Z,SUM
     SUM = X + Y + Z
     AVRAGE = SUM /3.0
 RETURN
 END
```

## Arrays

Arrays are used/declared in a similar manner to C. For example, to declare an array:
``` fortran
INTEGER            IDUM1( 1 ), IDUM2( 1 )
```
Array elements can be accessed using round brackets:
``` fortran
ICTXT = DESCA( 7 )
```

By default, arrays in fortran begin from index `1`.

## Logical and comparison expressions

Logical and comparison operators are written enclosed in dots. So `&&` in C is
`.AND.` in fortran. Similarly, `!=` is `.NE.`.

## Loops

Fortran has a curious way of writing loops, given that I'm coming from the C world. 
Loops are written using the `do-continue` syntax. Each loop statement in a program 
requires a statement label. Any label number can be used but the `do` and `continue`
of a single block must have the same label.

The variable that is defined in the line of the `do` block is the counter variable.
Its default step is `1` but you can change that as you want.

The general form is:
``` fortran
do label var =  expr1, expr2, expr3
  ! statements
label continue
```

In the above loop, `var` is the loop variable (this must be an integer). `expr1`
specifies the initial value of `var`, `expr2` is the terminating bound, and 
`expr3` is the increment (step).

Many Fortran 77 compilers allow `do`-loops to be closed by the `enddo` 
statement. The advantage of this is that the statement label can then be omitted
since it is assumed that an `enddo` closes the nearest previous do statement. 
The `enddo` construct is widely used, but it is not a part of ANSI Fortran 77.
