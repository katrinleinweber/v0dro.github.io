---
title: Setup emacs for LaTeX editing
date: 2018-04-14T17:23:09+09:00
---

I'm writing this blog as I'm learning latex and setting up emacs to use it. Previously
I mainly use LyX for writing research papers but the lack of text leads to lesser
customization options sometimes, which is why I'll be shifting to plain text LaTeX
henceforth.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Latex protips](#latex-protips)
- [Emacs latex setup](#emacs-latex-setup)
- [Resources](#resources)

<!-- markdown-toc end -->

# Latex protips

## Structure of documents

Docs consist of preamble and main document. The preamble contains commands for telling latex
which packages you will use and what kind of document you want to setup.

A sample preamble looks like so:
```
% Preamble
% ---
\documentclass{article}

% Packages
% ---
\usepackage{amsmath} % Advanced math typesetting
\usepackage[utf8]{inputenc} % Unicode support (Umlauts etc.)
\usepackage{hyperref} % Add a link to your document
\usepackage{graphicx} % Add pictures to your document
\usepackage{listings} % Source code formatting and highlighting
```

Only the `documentclass` command is mandatory. The rest are optional. `usepackage` cannot be
used inside the main document. When using the `article` documentclass, latex will add the page
numbers automatically to the bottom of each document.

The main document is contained inside the `document` environment like this:
```
\begin{document}
% ...
% ... Text goes here
% ...
\end{document}
```

## Environments

Latex comes with many pre-defined environments which you can use for setting up your
documents with minimal work. They come with some useful defaults too. For example, to
write a new Design Thinking assignment, I wrote the following preamble:
``` latex
\documentclass{article}
\title{Assignment 2: One hour observation}
\date{2018-4-22}
\author{Sameer Deshmukh}
```
Then using the `\maketitle` command inside the document body will directly create the
title page for us.

## Sections and paragraphs

Add sections using `\section{Section-name}` and sub-sections using `\subsection{sub-sec-name}`.
You can add as many `sub`'s to the subsection in order to specify multiple subsections. Using
the `\paragraph{Name goes here}` command will add a paragraph to the section.

## Adding images

You need the `graphicx` package to use images in your documents. Then use the 
`\graphicspath{ {folder-name/} }` command to tell latex the directory in which the images
are stored w.r.t the current directory. These should be declared in the preamble.

You can then use the `\includegraphics{graphic-name}` command to show images in your
document wherever you want.

You can specify various parameters to `includegraphics` for working with the image like
height, width and scaling inside square brackets. For example:"
```
\includegraphics[width=3cm, height=4cm]{image}
```
Just seeting width to `\textwidth` and leaving out height will keep the default height
and set the width to the width of the text in the document. Like this: 
```
\includegraphics[width=\textwidth]{image}
```
See the [refererence guide](https://www.sharelatex.com/learn/Inserting_Images#Reference_guide) for
a more detailed description of the lengths and units that can be specified.

## Useful commands

* New page - `\newpage`.
* Make a title page - `\maketitle`.

# Emacs latex setup

I mainly followed other blog posts to setup this one. First install texlive and auctex packages
from your package manager.

Then add the following to your emacs init file:
```
;; setup auctex
(require `tex-site)
(require `tex-style)
(add-hook `LaTeX-mode-hook `turn-on-reftex)

;; spellcheck in LaTex mode
(add-hook `latex-mode-hook `flyspell-mode)
(add-hook `tex-mode-hook `flyspell-mode)
(add-hook `bibtex-mode-hook `flyspell-mode)

;; Math mode for LaTex
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
```

## Auctex protips

Using auctex for your document editing provides some powerful features for editing and previewing
documents. Here's a list of what can be done:
* Preview a section right inside the buffer: `C-c C-p C-d`.
* Preview the entire buffer: `C-c C-p C-b`.
* Compile into a PDF: `C-c C-c`.

## Preview latex symbols within emacs

## View formatted PDF

The `docview-mode` can be used for previewing a PDF file from within emacs. This mode is bundled
with emacs 24. Put the line `(setq doc-view-continuous 1)` in your init file so that you can
scroll through PDFs seamlessly.

# Resources

* [Using auctex with emacs](https://piotrkazmierczak.com/2010/emacs-as-the-ultimate-latex-editor/) 
* [Latex, Auctex and emacs.](http://hal.case.edu/~rrc/blog/2013/11/04/latex/)
* [Latex tutorial.](https://www.latex-tutorial.com) 
* [Preview Latex symbols without preview-latex.](https://piotrkazmierczak.com/2012/previewing-latex-symbols-without-preview-latex/)
* [DocView navigation.](https://www.gnu.org/software/emacs/manual/html_node/emacs/DocView-Navigation.html) 
* [Inserting images in latex.](https://www.sharelatex.com/learn/Inserting_Images) 
