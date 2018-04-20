---
title: Bash scripting to automate porting to other machines
date: 2018-04-20T13:00:51+09:00
---

I need to log into multiple machines every now and then and its really annoying to
set everything up from scratch. Here's some simple things I did with bash scripting
for automating most of my workflow.

# Bash basics

A bash must have the line `#!/bin/bash` on the 1st line to let the OS know that this
is a bash script.

## If statements

You can check for existence of environment variables and execute specfic things. To
check whether a env variable exists, following syntax can be used:

If statements have the basic syntax:
```
if [ <some test> ]; then
  <commands>
elif [ <some test> ]; then
  <commands>
else
  <commands>
fi
```
The square brackets in the above `if` statement are actually a reference to the command
`test`. This means that all operators that `test` allows may be used here as well. See
`man test` to the see capabilities of the `test` command.

# Scripting protips

## Checking env variables

You can just check whether env variables exist or not with `if $VAR_NAME`. You need to
specify a call to `test` inside square brackets and specify `-z` if you want to check
whether the variables does not exist and `-n` if you want to check if the variable
exists.
