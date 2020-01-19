---
title: Emacs org-mode notes
date: 2018-04-20T22:21:42+09:00
---

Note taking is getting quite tedious these days with just markdown and written notes,
so I started using org-mode, which is supposed to be very good. The results so far have
been fabulous. In this post I will docuement the things that I learned about org-mode
and will update the post as and when I find out new things.

# Expand and collapse headers

Headers are written with `*`. More `*`'s you add more the level of indentation. Going to
a header title and pressing TAB will collapse or expand the contents of the header.

# Tagging and searching

Link: https://orgmode.org/worg/org-tutorials/advanced-searching.html

Org mode has some powerful search features that allow you to tag certain headers with
certain tags that allow you to search headers by tag. The tag has the syntax `:<tag_name>:`
after a header. So if you want a header `foo` as `bar` you can do:
```
* foo :bar:
```

# Writing presentations

Link: https://orgmode.org/worg/exporters/beamer/tutorial.html
