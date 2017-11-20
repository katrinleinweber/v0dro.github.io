---
layout: post
title: "GSOC 2016 Wrap Up For SciRuby"
date: 2016-11-24 09:57:34 +0530
comments: true
categories:
---

In the summer of 2016 I was chosen by the SciRuby core team to be admin for SciRuby for Google Summer of Code 2016. GSOC is an important yearly event for us as an organization since it provides a great platform for an upcoming organization like SciRuby and helps us get more users and contributors for the various libraries that we maintain.

This blog post is meant to be a summary of the work that SciRuby did over the summer and also of my experience at the GSOC 2016 mentor's summit.

## GSOC student work

For the 2016 edition of GSOC we had 4 students - [Lokesh Sharma](https://github.com/lokeshh), [Prasun Anand](https://github.com/prasunanand), [Gaurav Tamba](https://github.com/gau27) and [Rajith Vidanaarachchi](https://github.com/rajithv). All four were undergraduate computer engineering students from colleges in India or Sri Lanka at the time of GSOC 2016.

Lokesh worked on making improvements to [daru](https://github.com/sciruby/daru), a Ruby DataFrame library. He made very significant contributions to daru by adding functionality for storing and performing operations on categorical data, and also significantly sped up the sorting and grouping functionality of daru. His work has now been successfully integrated into the main branch and has also been released on rubygems. Lokesh has remained active as a daru contributor and regularly contributes code and replies to Pull Requests and issues. You can find a wrap up of the work he did throughout the summer in [this blog post](http://sciruby.com/blog/2016/11/24/gsoc-2016-adding-categorical-data-support/).

Prasun worked on creating a Java backend for [NMatrix](https://github.com/sciruby/nmatrix), a Ruby library for performing linear algebra operations similar to numpy in Python. This project opened the doors for scientific computation on JRuby. Prasun was able to complete all his project objectives, and his work is currently awaiting review because of the [sheer size of the Pull Request](https://github.com/SciRuby/nmatrix/pull/558) and the variety of changes to the library that he had to make in order to accomplish his project goals. You can read about his summer's work [here](http://sciruby.com/blog/2016/10/24/gsoc-2016-port-nmatrix-to-jruby/). Prasun will also be [speaking at Ruby Conf India 2017](http://rubyconfindia.org/program/#prasun-anand) about his GSOC work and scientific computing on JRuby in general.

Gaurav worked on creating a Ruby wrapper for NASA's [SPICE toolkit](https://naif.jpl.nasa.gov/naif/toolkit.html). A need for this was felt since Gaurav's mentor John is a rocket scientist and was keen having a Ruby wrapper for a library that he used regularly in his work. This resulted in the [spice_rub](https://github.com/SciRuby/spice_rub) gem. It exposes a very intuitive Ruby interface to the SPICE toolkit. Gaurav also gave a lightning talk about his work at [Deccan Ruby Conf (Pune, India)](). Blog posts summarizing his work can be found [here](http://sciruby.com/blog/2016/11/24/spicerub-kernelpool-and-kernels/), [here](http://sciruby.com/blog/2016/11/24/gsoc-2016-a-look-at-spicerub-body/) and [here](http://sciruby.com/blog/2016/11/24/gsoc-2016-a-look-at-spicerub-time/).

Rajith worked on growing the Ruby wrapper over [symengine](https://github.com/symengine/symengine). His mentor Abinash was a student with SciRuby for GSOC 2015 and volunteered to mentor Rajith so that Rajith could build upon the work that he had done the previous summer. This resulted in a huge increase in functionality for the [symengine.rb ruby gem](https://github.com/symengine/symengine.rb).

To summarize, all four of our students could execute their chosen tasks within the stipulated time and we did not have to fail anyone. All in all, we mentors had a great time working with the students and hope to keep doing this year on year!

## GSOC 2016 mentor's summit

The GSOC 2016 mentor's summit was fantastic. It was great meeting all the contributors and listening to ideas from projects that I had never heard about previously. I also had the opportunity to conduct an unconference session and  share my ideas on Scientific Computation in Ruby with like minded people from other organizations.

Here are some photos that I took at the summit:

{%img /images/gsoc_summit/1.JPG 'ID card'%}

{%img /images/gsoc_summit/2.JPG 'A visit to the Computer History Museum'%}

{%img /images/gsoc_summit/3.JPG 'The (now discontinued) self driving car'%}

{%img /images/gsoc_summit/4.JPG 'Chocolate table at the GSOC summit'%}

{%img /images/gsoc_summit/5.JPG 'Attendees from India'%}
