---
title: Setup emacs for LaTeX editing
date: 2018-04-14T17:23:09+09:00
---

I mainly followed other blog posts to setup this one. Setup auctex in emacs by first 
installing auctex using `apt-get install auctex`.

I then installed setup flymake with tex so that emacs will automatically check my
latex for errors. Just put the following in your `init.el`:
``` elisp
(require 'flymake)

(defun flymake-get-tex-args (file-name)
(list "pdflatex"
(list "-file-line-error" "-draftmode" "-interaction=nonstopmode" file-name)))

(add-hook 'LaTeX-mode-hook 'flymake-mode)
```
Apparently flymake is quite CPU-expensive so maybe switch it off when you're sure
you're doing the right thing.

# Resources

* [Using auctex with emacs](https://piotrkazmierczak.com/2010/emacs-as-the-ultimate-latex-editor/) 


