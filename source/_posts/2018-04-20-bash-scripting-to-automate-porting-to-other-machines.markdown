---
title: Bash scripting to automate porting to other machines
date: 2018-04-20T13:00:51+09:00
---

I need to log into multiple machines every now and then and its really annoying to
set everything up from scratch. Here's some simple things I did with bash scripting
for automating most of my workflow.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Bash basics](#bash-basics)
    - [If statements](#if-statements)
- [Scripting protips](#scripting-protips)
    - [Checking env variables](#checking-env-variables)
    - [Checking for programs](#checking-for-programs)
- [Resources](#resources)

<!-- markdown-toc end -->

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

For example, cheking if `$SERVER_ENV` variable exists or not will look like this:
```
if [-n "$SERVER_ENV"]; then
    echo "SERVER_ENV exists"
fi
```
## Checking for programs

If you want to check whether a particular program exists or not, use `hash <command_name>`.

For example, to see if git exists and print an error if not:
```
if ! hash git 2>/dev/null; then
    echo "Please install git before proceeding."
    exit 1
fi
```

# Resources

* [Checking whether program exists.](https://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script) 
