---
layout: post
title: "Making statsample work with rb-gsl and gsl-nmatrix"
date: 2015-05-12 18:23:46 +0530
comments: true
categories: 
---

**Note: It so happens that the latest release of rb-gsl does not depend on narray anymore. Hence rb-gsl can be directly used with statsample. However, if you want to use nmatrix with GSL, use gsl-nmatrix.**

[Statsample](https://github.com/SciRuby/statsample) is the most comprehensive statistical computation suite in Ruby as of now.

Previously, it so happened that statsample would depend on [rb-gsl](https://github.com/blackwinter/rb-gsl) to speed up a lot of computations. This is great, but the biggest drawback of this approach is that rb-gsl depends on [narray](https://github.com/masa16/narray), which is incompatible with [nmatrix](https://github.com/SciRuby/nmatrix) - the numerical storage and linear algebra library from the SciRuby foundation - due to namespace collisions. 

NMatrix is used by many current and upcoming ruby scientific gems, most notably [daru](https://github.com/v0dro/daru), [mikon](https://github.com/domitry/mikon), [nmatrix-fftw](https://github.com/thisMagpie/fftw), etc. and the a big hurdle that these gems were facing was that they could not leverage the advanced functionality of rb-gsl or statsample because nmatrix cannot co-exist with narray. On a further note, daru's [DataFrame](https://github.com/v0dro/daru/blob/master/lib/daru/dataframe.rb) and [Vector](https://github.com/v0dro/daru/blob/master/lib/daru/vector.rb) data structures are to replace statsample's [Dataset](https://github.com/SciRuby/statsample/blob/master/lib/statsample/dataset.rb) and [Vector](https://github.com/SciRuby/statsample/blob/master/lib/statsample/vector.rb), so that a dedicated library can be used for data storage and munging and statsample can be made to focus on statistical analysis.

The most promising solution to this problem was that rb-gsl must be made to depend on nmatrix instead of narray. This problem was solved by the [gsl-nmatrix](https://github.com/v0dro/gsl-nmatrix) gem, which is a port of rb-gsl, but uses nmatrix instead of narray. Gsl-nmatrix also allows conversion of GSL objects to NMatrix and vice versa. Also, latest changes to statsample make it completely independent of GSL, and hence all the methods in statsample are now possible with or without GSL.

To make your installation of statsample work with gsl-nmatrix, follow these instructions:

* [Install nmatrix](https://github.com/SciRuby/nmatrix/wiki/Installation) and clone, build and install the latest gsl-nmatrix from https://github.com/v0dro/gsl-nmatrix
* Clone the latest statsample from https://github.com/SciRuby/statsample
* Open the Gemfile of statsample and add the line `gem 'gsl-nmatrix', '~>1.17'`
* Build statsample using `rake gem` and install the resulting `.gem` file with `gem install`.

You should be good able to use statsample with gsl-nmatrix on your system now. To use with rb-gsl, just install rb-gsl from rubygems (`gem install rb-gsl`) and put `gem 'rb-gsl', '~>1.16.0.4'` in the Gemfile instead of gsl-nmatrix. This will activate the rb-gsl gem and you can use rb-gsl with statsample.

However please take note that narray and nmatrix cannot co-exist on the same gem list. Therefore, you should have either rb-gsl or gsl-nmatrix installed at a particular time otherwise things will malfunction.
