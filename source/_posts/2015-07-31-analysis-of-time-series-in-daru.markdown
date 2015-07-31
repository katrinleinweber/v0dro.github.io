---
layout: post
title: "Analysis of Time Series in Daru"
date: 2015-07-31 18:26:23 +0530
comments: true
categories: 
---

The newest release of daru brings alongwith it added support for time series data analysis, manipulation and visualization.

A time series is any data is indexed (or labelled) by time. This includes the stock market index, prices of crude oil or precious metals, or even geo-locations over a period of time.

The primary manner in which daru implements a time series is by indexing data objects (i.e Daru::Vector or Daru::DataFrame) on a new index called the DateTimeIndex. A DateTimeIndex consists of dates, which can queried individually or sliced.

## Introduction

A very basic time series can be created with something like this:

``` ruby
require 'distribution'
require 'daru'

rng = Distribution::Normal.rng

index  = Daru::DateTimeIndex.date_range(:start => '2012-4-2', :periods => 1000, :freq => 'D')
vector = Daru::Vector.new(1000.times.map {rng.call}, index: index)
```
{% img center /images/daru_time_series/simple_vector.png 'A Simple Vector indexed on DateTimeIndex' %}

In the above code, the `DateTimeIndex.date_range` function is creating a `DateTimeIndex` starting from a particular date and spanning for 1000 periods, with a frequency of 1 day between period. For a complete coverage of DateTimeIndex see [this]() notebook. For an introduction to the date offsets used by daru see [this blog post](http://v0dro.github.io/blog/2015/07/27/date-offsets-in-daru/).

The index is passed into the Vector like a normal `Daru::Index` object.

## Statistics functions and plotting for time series

Many functions are avaiable in daru for computing useful statistics and analysis. A brief of summary of statistics methods available on time series is as follows:

| **Method Name** | **Description** |
|:-:|:-:|
|---
|`rolling_mean`| Calculate Moving Average|
|`rolling_median`| Calculate Moving Median|
|`rolling_std`| Calculate Moving Standard Deviation|
|`rolling_variance`| Calculate Moving Variance|
|`rolling_max`| Calculate Moving Maximum value|
|`rolling_min`| Calcuclate moving minimum value|
|`rolling_count`| Calculate moving non-missing values|
|`rolling_sum`| Calculate moving sum |
|`ema`| Calculate exponential moving average |
|`macd`| Moving Average Convergence-Divergence |
|`acf`| Calculate Autocorrelation Co-efficients of the Series |
|`acvf`| Provide the auto-covariance value |

 

To demonstrate, the rolling mean of a Daru::Vector can be computed as follows:

``` ruby

require 'daru'
require 'distribution'

rng    = Distribution::Normal.rng
vector = Daru::Vector.new(
  1000.times.map { rng.call }, 
  index: Daru::DateTimeIndex.date_range(
    :start => '2012-4-2', :periods => 1000, :freq => 'D')
)
# Compute the cumulative sum
vector = vector.cumsum
rolling = vector.rolling_mean 60

rolling.tail
```
{% img center /images/daru_time_series/rolling_mean.png 'Rolling Mean Tail' %}

 
This time series can be very easily plotted with its rolling mean by using the [GnuplotRB](https://github.com/dilcom/gnuplotrb) gem:

``` ruby

require 'gnuplotrb'

GnuplotRB::Plot.new(
  [vector , with: 'lines', title: 'Vector'],
  [rolling, with: 'lines', title: 'Rolling Mean'])
```

{% img center /images/daru_time_series/cumsum_rolling_line_graph.png 'Line Graph of Rolling mean and cumsum' %}

These methods are also available on DataFrame, which results in calling them on each of numeric vectors:

``` ruby

require 'daru'
require 'distribution'

rng    = Distribution::Normal.rng
index  = Daru::DateTimeIndex.date_range(:start => '2012-4-2', :periods => 1000, :freq => 'D')
df = Daru::DataFrame.new({
  a: 1000.times.map { rng.call },
  b: 1000.times.map { rng.call },
  c: 1000.times.map { rng.call }
}, index: index)
```
{% img center /images/daru_time_series/dataframe.png 'DateTime indexed DataFrame' %}


In a manner similar to that done with Vectors above, we can easily plot each Vector of the DataFrame with GNU plot:

``` ruby

require 'gnuplotrb'

# Calculate cumulative sum of each Vector
df = df.cumsum

# Compute rolling sum of each Vector with a loopback length of 60.
r_sum = df.rolling_sum(60)

plots = []
r_sum.each_vector_with_index do |vec,n|
  plots << GnuplotRB::Plot.new([vec, with: 'lines', title: n])
end
GnuplotRB::Multiplot.new(*plots, layout: [3,1], title: 'Rolling sums')
```
{% img center /images/daru_time_series/dataframe_plot.png 'Plotting the DataFrame' %}

## Usage with statsample-timeseries