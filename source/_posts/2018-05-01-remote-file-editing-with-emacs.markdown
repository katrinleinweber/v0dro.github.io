---
title: Remote file editing with emacs.
date: 2018-05-01T17:59:14+09:00
---

I'm logging into various computers to harness their superior hardware which my
laptop can never support. In this post I'm documenting the stuff that should
be done for accessing remote files using emacs via your local machine.

# TRAMP

TRAMP is an emacs utility that lets you edit remote files just like they're local
files. In order to access a remote file, you need to use the following syntax
after doing a `C-x C-f`:
```
/method:user@host:/path/to/file. 
```
In my case, I have the hosts written down in an ssh config file, so I can access a
file on computer `a2` in the following manner:
```
/ssh:a2:/home/sameer/a.cpp
```
This is so incredibly intuitive and simple!
