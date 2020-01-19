---
title: Writing snippets for yasnippet in emacs
date: 2018-04-18T13:40:37+09:00
---

In order to make typing things easier I've been yasnippet with some custom snippets
of mine. The yasnippet devs have been kind enough to offer plenty of detailed tutorials
on how to write your own snippets. In this post I will highlight the steps that I took
to write some simple ones. For more detailed information you should of course read the
actual yasnippet docs.

# Getting started

Just invoke `M-x yas-new-snippet` to invoke a new buffer that opens in a major mode
called `snippet-mode`. This mode is created specifically for creating yasnippets and
is very useful for this purpose. The buffer that it opens will have a template for
writing a snippet. There are some lines at the beginning that start with `#`, these
lines are comments and are also used for specifying 'properties' of the snippet.

For example, here's a header for a snippet that I wrote for expanding `@param` listing
in YARD documentation:
``` snippet
# -*- mode: snippet -*-
# name: Write @params attribute of YARD docs.
# key: param
# group: yard_docs
# contributor: Sameer Deshmukh (@v0dro)
# --
```

In the above header, the `name:` attribute is a string describing the purpose of this
snippet. `key:` is an important attribute that describes the key that yasnippet will
lookout for when expanding a snippet. `group` specifies which group a snippet would
belong to when it is listed in the `yas-describe-tables` table (it has no other
purpose than grouping). The `contributor:` field is just used for writing the name
of the contributor.

# Snippet syntax

Some tutorials say that the snippet syntax is similar to that of TextMate, but I've
never used TextMate so I have no idea. I'll now describe in as much detail as is required
the yasnippet snippet syntax in this section.

The basic work-flow is that you write some text in the file along with some markup for specifying
places where you want the user to type things when they jump across the snippet (the thing
that happens when you keep pressing TAB after typing something after expanding the snippet).

Following is the text to specify an expansion for @param attribute in the [YARD syntax]():
```
# @param $1 [$2] $3
$0
```
In the above text, `# @param` is the text that specifies that this is a Ruby comment and the
`@param` is a YARD directive that specifies that this is a param being defined. The `$` followed
by the number are the TAB stop fields. These will specify the first, second and third place in
the text that the cursor will go to after the user presses TAB. The `$0` has a special significance.
It is the 'TAB stop field'. This will be the exit point of the snippet once the user is done
pressing TAB for the final time.

The above snippet can be further improved to provide default values for the TAB stop fields by
replacing it with the following syntax:
```
# @param ${1: arg name} [${2: data type}] ${3: description.}
$0
```
The `${N:description}` syntax can be used for providing default values.

# Organizing snippets

Snippets are organized by sub-directories by the major-mode in which they belong.
For example:
```
|-- c-mode
|   `-- printf
|-- java-mode
|   `-- println
`-- text-mode
    |-- email
    `-- time
```
By default, your personal snippets collection lives inside `~/.emacs.d/snippets`.

In order to save the snippet file, press `C-c C-c`. It will prompt your for entering the
folder where the snippet is to be saved. Keep the folder name as the major mode and the
file name as the key of the snippet.

# Resources

* [Detailed tutorial on writing snippets.](https://joaotavora.github.io/yasnippet/snippet-development.html) 
* [Organizing snippets.](https://joaotavora.github.io/yasnippet/snippet-organization.html) 


