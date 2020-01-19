---
title: Setup Japanese environment on Ubuntu and emacs
date: 2018-04-12T15:11:57+09:00
---

I'm currently living in Japan and learning Japanese in University. In order to make
learning easier I'm using the [Anki](https://ankiweb.net) app. However, Ubuntu and 
emacs don't come with easy Japanese functionality out of the box and in this post 
I will document the efforts I took to make this happen.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Ubuntu setup](#ubuntu-setup)
- [Emacs setup](#emacs-setup)
- [Resources](#resources)

<!-- markdown-toc end -->

# Ubuntu setup

For ubuntu, the preferred Japanese input method is a Japanese keyboard called mozc.
Use the link in the resources below for this purpose.

Then, setup the following ENV variables in your .bashrc:
```
export QT_IM_MODULE=fcitx
export GTK_IM_MODULE=fcitx
```
You can go the text entry setting and set the keyboard change button to 'pause',
which I did.

# Debian setup

You can't install mozc on Debian GUI so you should first install the `ibus-mozc` package
and then use the ibus GUI for selecting mozc.

# Emacs setup

You can then proceed to setup your emacs with the mozc keyboard. For this purpose,
you should first copy-paste the file `mozc.el` from the [mozc sources](https://github.com/google/mozc/blob/master/src/unix/emacs/mozc.el)
into your .emacs.d/ folder and then paste the following into your `init.el` (after
loading the mozc.el file).
``` elisp
(require 'mozc)
(setq default-input-method "japanese-mozc")
(setq mozc-candidate-style 'overlay)
```
Once this is done, install the `emacs-mozc-bin` package from the ubuntu sources
so that emacs can communicate with the mozc server.

You should now be able to change between Japanese and English keyboards using the
`C-\` command inside emacs. This does not change your system input.

# Resources

* [Ubuntu setup instructions for mozc.](https://moritzmolch.com/2287) 
* [Writing Japanese in emacs](https://www.emacswiki.org/emacs/WritingJapanese) 
* [Archlinux mozc emacs.](https://wiki.archlinux.org/index.php/mozc#Mozc_for_Emacs) 



