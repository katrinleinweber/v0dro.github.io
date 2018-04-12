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

# Course work assignments
