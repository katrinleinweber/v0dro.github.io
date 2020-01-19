---
title: "Presentations with org-mode and beamer."
date: 2018-11-15T14:28:00+09:00
---

Combining org-mode and the Latex beamer package allows us to write high quality
presentations using the power of both emacs org-mode and beamer.

Here's my customizations:

# Getting started

In beamer terminology, a 'frame' is defined as a slide. Each frame in org-beamer-mode
can be specified using a heading (starting with `*` or `**` depending on the indentation
level that you have set).

# Init file

# Latex header modifications for beamer

# Presentation tips and tricks

## Beamer blocks

## Adding code to slides

It is important to set a frame to `fragile` when you add code (or anything `verbatim`) to 
your slides. It can be done using the `BEAMER_OPT` property. For example:
```
:PROPERTIES:
:BEAMER_OPT: fragile
:END:
```

## Splitting into two columns

Use `beamer blocks` using the `C-c C-b` commands for generating beamer blocks
via org. For the simplest use case where a beamer block is a column, a heading
needs to specified as a `B_block` and a `BMCOL`. Beamer will then take the heading
of each column as the heading of the block. A minimal example would look like so:
```
** Heading left                                             :BMCOL:B_block:
    :PROPERTIES:
    :BEAMER_col: 0.5
    :BEAMER_env: block
    :END:

    some text.
    
** Heading right                                              :BMCOL:B_block:
    :PROPERTIES:
    :BEAMER_col: 0.5
    :BEAMER_env: block
    :END:

    some other text.

```
org-beamer will simply keep adding columns until the `BEAMER_col` property
is present. The value supplied to that property is the percentage width that
the column occupies.

# Useful links

- Org Beamer reference card: https://github.com/fniessen/refcard-org-beamer
- Org dependencies: https://orgmode.org/worg/org-dependencies.html
