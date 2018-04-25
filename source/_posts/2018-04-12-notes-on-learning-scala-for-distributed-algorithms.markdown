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

### Passing blocks to method calls

Passing blocks to functions (similar to Ruby `do..end` blocks) is done by specifying curly
braces with the method call. Example:
```
Receive {
  // do something...
}
```

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

### Case classes

Case classes are useful for modelling immutable data.

#### Defining case classes

Defined using the `case class` keyword. These classes do not require the `new` keyword
for instantiation because they have an implicit `apply` method defined internally. You
can use these classes like so:
``` scala
case class Book(isbn: String)

val frankenstein = Book("978-0486282114")
```
All attributes of case classes are public and are immutable.

## Pattern matching

Pattern matching is a powerful tool in Scala for matching an input vs. a set of possible
outcomes. It similar in nature to other FP languages like OCaml.

### List pattern matching



### Pattern matching anonymous functions

Scala provides a way of pattern matching anonymous functions. These are basically blocks
containing the usual `case` statements but without the `match`.

## Operators

This warrants a new section because scala uses a lot of fancy operators for doing all sorts
of 'magic' things that can be confusing at first.

## Eccentric things

### In-code TODO statements

Scala allows you to throw NotImplementedError using a simpler syntax where you can define
a value `???` to throw an exception:
``` scala
def ???: Nothing = throw new NotImplementedError

def answerToLifeAndEverything() = ???
```

### Option types



# Distributed algorithms in scala

Professor Xavier's lab has written a library called [scalaneko](http://www.coord.c.titech.ac.jp/projects/scalaneko/api/neko/) that is useful
for prototyping and implementing distributed systems using scala. This assingnment
asks us write an algorithm that does a parallel traversal of a connected graph
of processes using scala.

## Scalaneko protips

The basic unit of concurrency is a processs. Each process can contain many protocols. Protocols
implement the actual algorithms of the system. Protocols and processes exchange information
through events. There are two types of events: signals and messages. Signals allows protocols
within the same process to notify each other. Messages are for protocol instances to communicate
across different processes. Therefore, only messages are transmitted through the network.

Working with scalaneko basically involves the following steps:

### Initialize scalaneko environment

Create a main object that provides the basic parameters for the execution, such as total
number of processes to create and their initializer. For example:
``` scala
object HelloNeko
  extends Main(topology.Clique(2))(
    ProcessInitializer { p => 
      new Hello(p) 
    }
  )
```
In the above code we initialize scalaneko with 2 processes and then state that each process
should be an instance of the `Hello` class.

### Create and use protocols

You need to create protocols for the communication logic. This is done by extending a process class
like `Hello` in the above code using the `ActiveProtocol` class provided by scalaneko. Inside
the class you must define a method called `run` which will be called by ActiveProtocol inside
its own thread for running the protocol.

Messages are sent using the `ActiveProtocol.SEND` method and received via blocking calls to
`ActiveProtocol.RECEIVE` method. You should call `listenTo` to register messages of a
particular type before you can receive them.

You can also override the `ActiveProtocol.onReceive` method to process messages reactively.
Those that are not caught by `onReceive` are sent into a receive queue and must be handled using
`Receive`.

### Process initialization

Process initialization is done using the `ProcessInitializer` class, whose sole role is
to create protocols of a process and combine them. For example:
```
ProcessInitializer { p =>
    val app  = new PingPong(p)
    val fifo = new FIFOChannel(p)
    app --> fifo
}
```

In the above example, each process is initialized by executing the above code. The
code creates two protocols while registering them into the object p given as argument
(which represents the process being initialized). Then, the two protocols are connected
such that all SEND operations of protocol `app` are handed to protocol `fifo`. The send
operations of protocol fifo use the default target which is the network interface of
the process.

### Messages and signals

Signals happen inside a process, and can go from one protocol to another, but never crosses
process boundaries. Represented by class `neko.Signal`. A message is an event that crosses
process boundaries, but is typically interpreted by the same protocol in the target process.
Represented by a subclass of `neko.Message`.

Messages can be multicast (`neko.MulticastMessage`), unicast (`neko.UnicastMessage`) or
a wrapper (`neko.Wrapper`) that wraps an existing message.

# Resources

* [Scala crash course.](http://uclmr.github.io/stat-nlp-book-scala/05_tutorial/01_intro_to_scala_part1.html)
* [Higher-order functions.](http://docs.scala-lang.org/tutorials/tour/higher-order-functions.html.html)
* [Scala Function2.](http://www.scala-lang.org/api/2.9.1/scala/Function2.html)
* [Objects and classes in scala.](https://www.safaribooksonline.com/library/view/learning-scala/9781449368814/ch09.html)
* [Extends vs with.](https://stackoverflow.com/questions/41031166/scala-extends-vs-with)
* [Classes and objects in scala official docs.](http://scala-lang.org/files/archive/spec/2.12/05-classes-and-objects.html)
* [Declare constructor parameters of extended scala class.](https://alvinalexander.com/scala/how-to-declare-constructor-parameters-extending-scala-class)
* [Scala case classes](https://docs.scala-lang.org/tour/case-classes.html) 
* [Pattern matching anonymous functions.](http://danielwestheide.com/blog/2012/12/12/the-neophytes-guide-to-scala-part-4-pattern-matching-anonymous-functions.html) 
* [Magic in scala methods and operators.](https://github.com/ghik/opinionated-scala/wiki/Methods-and-operators)
* [ScalaNeko API docs.](http://www.coord.c.titech.ac.jp/projects/scalaneko/api/neko/)
* [Chang-Roberts algorithm.](https://en.wikipedia.org/wiki/Chang_and_Roberts_algorithm)
* [Scala Option type.](http://danielwestheide.com/blog/2012/12/19/the-neophytes-guide-to-scala-part-5-the-option-type.html)
