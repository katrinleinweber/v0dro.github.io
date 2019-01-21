---
title: "Making research posters using latex and emacs."
date: 2018-11-15T16:54:25+09:00
---

Using the a0poster package, you can use Latex for designing reserach posters.

# Helpful commands

## Various programming constructs

### Variables

Add variables or new commands using `\newcommand`. For example `\newcommand{\sidel}{6}`.

Link: https://stackoverflow.com/questions/1211888/is-there-any-way-i-can-define-a-variable-in-latex

## Adding a title to your poster

Simply use a separate set of `minipage` elements and put the title within those.

## Changing fonts of the section headings

Use the titlesec package for this [purpose](https://tex.stackexchange.com/questions/59726/change-size-of-section-subsection-subsubsection-paragraph-and-subparagraph-ti).

A typical configuration for titlesec looks like so:
```
\usepackage{titlesec}

\titleformat*{\section}{\LARGE\bfseries}
\titleformat*{\subsection}{\Large\bfseries}
\titleformat*{\subsubsection}{\large\bfseries}
\titleformat*{\paragraph}{\large\bfseries}
\titleformat*{\subparagraph}{\large\bfseries}
```

## Overlaying text on an image

Use the 'overpic' package for this. This this link for details:
https://tex.stackexchange.com/questions/20792/how-to-superimpose-latex-on-a-picture

Overpic full docs: http://mirrors.ibiblio.org/CTAN/macros/latex/contrib/overpic/overpic.pdf

## Drawing boxes filled with colors

Simpy define a command `crule` from the `rule` command. Definition and usage:
```
\newcommand\crule[3][black]{\textcolor{#1}{\rule{#2}{#3}}}

\crule{1cm}{1cm} \crule[blue]{1cm}{1cm} \crule[red!50!white!100]{1cm}{1cm}
```
Link:
https://tex.stackexchange.com/questions/106984/how-to-draw-a-square-of-1cm-in-latex-filled-with-color

## Splitting into multiple rows and columns

Using `minipage` for splitting a document into boxes is recommended. The first argument it
accepts decides how the alignment of the minipage will be. `t` is top-aligned and `b` is
bottom-aligned.

## Graphics with tikz

### LU decomposition diagram

Drawing two boxes with L & U:
https://tex.stackexchange.com/questions/317230/lu-factorization-of-a-matrix-with-plot?newreg=991a708140a2446882fdd9bd3c445af9

Drawing an arrow between tikzpicture objects:
https://tex.stackexchange.com/questions/260587/an-arrow-between-two-tikzpictures

### Dependency graphs

Inspiration can be taken from this state machine [tutorial](http://www.texample.net/tikz/examples/state-machine/) for drawing dependency graphs.
Basically put things inside a `tikzpicture` block. Use the `\node` command for defining
a node and the `\path` command for connecting these nodes.

### Drawing things on pictures

Using tikz one can annonate pictures with various things.

Link:
https://tex.stackexchange.com/questions/9559/drawing-on-an-image-with-tikz

# Useful links

+ Getting started PDF: https://www.tug.org/pracjourn/2008-3/morales/morales.pdf
+ Very good sample template poster: https://www.latextemplates.com/template/a0poster-portrait-poster
