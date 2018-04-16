---
title: Notes on learning scala for distributed algorithms
date: 2018-04-12T16:28:16+09:00
---

I'm currently taking a college course on [distributed algorithms](http://www.coord.c.titech.ac.jp/c/distribalgo/), that uses scala for
teaching. I'm not familiar with distributed algorithms or scala, so in this blog I will
document my learnings and provide some protips on a simple scala setup.

# Scala setup

We advised by the instructor so use scala using the intelliJ IDE, but since I'm
not a big fan of IDEs and prefer using my editor (emacs). I thought I get away
with simply installing scala from the command line (`apt-get install scala`)
and invoking my programs from the command line using the `scalac` or `scala`
programs.

The course requires using a dependency called [scalaneko](URL), which of course
needs to specified before building your program. I tried to compile this with
a simple Makefile that looked like this:
```
run:
	scala -cp scalaneko_2.12-0.19.0-SNAPSHOT.jar hello_world.scala
```

Above Makefile simply tries to specify the classpath using the `-cp` flag and runs
the scala file. However, this approach fails with errors that probably are hinting
towards the dependency being compiled using a different version of scala.

Therefore, I decided to use SBT for this purpose. SBT is more complex tool for my
simple usage but I think the time saved in the long run would be worth it.

For installation, followed the setup guide [here](). I read the [getting started guide](https://www.scala-sbt.org/1.x/docs/Getting-Started.html) to see how to make it work.
Here's a brief description (make sure sbt is installed first):
First cd into the folder you want to setup your first project. Then execute:
```
sbt new sbt/scala-seed.g8
```
Type a project name (say `hello`) when prompted for it. You then cd into the `hello`
directory and execute `sbt`. Once inside the prompt, type `run`. This whole process
takes a while to complete since it downloads and compiles many sources.

# Scala syntax protips

## Values and variables

Scala supports values and variables. Values cannot be changed and are technically
constants (immutable). Values are declared with `val` and variables with `var`.

Since scala supports type inference you don't need to explicitly declare the type
of your values or variables.

## For loop

For loops have the following syntax:
``` scala
var count = 0
for (i <- 0 to 10) count = count + i
count
```

## Functions

Since scala is an object-oriented _functional_ programming language, functions are
basically objects that you create with the keyword `def`. For example:
``` scala
def sum(a: Int, b: Int): Int = a + b
sum(900,100)
```
The `Int` after the colon is the return type. You can leave out specifying the
return type in most cases since scala can infer that by itself. Just like any
functional language, functions can be stored and passed around like objects.

If you don't want your function to return a value (like `void`) in C, use `Unit`
as the return value:
``` scala
def print(a: Int): Unit = println(a)
print(3)
```

Like Ruby, the last statement in the body of a function is its return value.

### Higher-order functions

Scala allows defining functios that take other functions as its arguments.
This can be done by specifying the argument types and return type of the function
as the data type of the variable that accepts this. For example:
``` scala
def apply(f: Int => String, v: Int) = f(v)
```
In the above code the `apply` function will accept a function `f` as an arguement
which accepts one `Int` and returns a `String`.

### Functions as variables

Functions can be assigned to a `val` by specifying the prototype of the function:
``` scala
val sum: (Int, Int) => Int = (a: Int, b: Int) => a + b
sum(3,6)
```

Or even by a simple assignment using the `new` keyword:
``` scala
val verboseSum = new Function2[Int, Int, Int] {
    def apply(a: Int, b: Int): Int = a + b
}

verboseSum(3,6)
```

In the assingnment we've used with `new Function2[-T1,-T2,+R]` constructor. This is a
[special scala trait](http://www.scala-lang.org/api/2.9.1/scala/Function2.html) that can be used for
defining anonymous functions. `Function2` specifies that the this function will accept
parameters of type `T1` and `T2` and will return a type `R`.

## Classes

Classes are defined using the `class` keyword. Using a default constructor, the class
can be defined like so:
``` scala
class User

val user1 = new User
```

A constructor can be used by directly specifying the expected argument with the classname:
```
class Point(x: Int, y: Int) {
    def move(dx: Int, dy: Int) {
        dx = x + 1
        dy = y + 1
    }
}

new point1 = Point(2,3)
point1.x
```

### Singleton classes

Singleton classes in scala are created using the `object` keyword. This is something
like a module in Ruby. You cannot instantiate objects of such classes. You can simply
access the functions by name instead of creating objects. The `main` function of a
program must be defined inside a singleton class by the name of the package.

### Inheritance

Inheritance is done using the `extends` keyword and the `with` keyword. You can use
`extends` only once when defining a class and `with` multiple times after that. `with`
is used for multiple inheritance.

#### Instantiating base class with certain values

## Pattern matching

## Eccentric things

### In-code TODO statements

Scala allows you to throw NotImplementedError using a simpler syntax where you can define
a value `???` to throw an exception:
``` scala
def ???: Nothing = throw new NotImplementedError

def answerToLifeAndEverything() = ???
```

# Course work assignments

## Assignment 1: parallel traversal using scalaneko

Professor Xavier's lab has written a library called [scalaneko]() that is useful
for prototyping and implementing distributed systems using scala. This assingnment
asks us write an algorithm that does a parallel traversal of a connected graph
of processes using scala.

# Resources

* [Scala crash course.](http://uclmr.github.io/stat-nlp-book-scala/05_tutorial/01_intro_to_scala_part1.html)
* [Higher-order functions.](http://docs.scala-lang.org/tutorials/tour/higher-order-functions.html.html)
* [Scala Function2.](http://www.scala-lang.org/api/2.9.1/scala/Function2.html)
* [Objects and classes in scala.](https://www.safaribooksonline.com/library/view/learning-scala/9781449368814/ch09.html)
* [Extends vs with.](https://stackoverflow.com/questions/41031166/scala-extends-vs-with)
* [Classes and objects in scala official docs.](http://scala-lang.org/files/archive/spec/2.12/05-classes-and-objects.html)
* [Declare constructor parameters of extended scala class.](https://alvinalexander.com/scala/how-to-declare-constructor-parameters-extending-scala-class)
