---
layout: post
title: "Date Offsets in Daru"
date: 2015-07-27 13:21:42 +0530
comments: true
categories: 
---

Daru's (Data Analysis in RUby) latest release (0.2.0) brings in a host of new features, most important among them being time series manipulation functionality. In this post, we will go over the date offsets that daru offers, which can be used for creating date indexes of specific intervals. The offsets offer a host of options for easy creation of different intervals and even work with standalone DateTime objects to increase or decrease time.

The date offsets are contained in the `Daru::Offsets` sub-module. A number of classes are offered, each of which implements business logic for advancing or retracting date times by a specific interval.

To demonstrate with a quick example:

``` ruby

require 'daru'

offset = Daru::Offsets::Hour.new
offset + DateTime.new(2012,4,5,4)
#=> #<DateTime: 2012-04-05T05:00:00+00:00 ((2456023j,18000s,0n),+0s,2299161j)>
```

As you can see in the above example, an hour was added to the time specified by DateTime and returned. All the offset classes work in a similar manner. Following offset classes are available to users:

+-------------------+--------------------------------------------------+
| Offset Class      | Description                                      |
|:-----------------:|:------------------------------------------------:|
|Daru::DateOffset   | Generic offset class                             |
|Second             | One Second                                       |
|Minute             | One Minute                                       |
|Hour               | One Hour                                         |
|Day                | One Day                                          |
|Week               | One Week. Can be anchored on any week of the day.|
|Month              | One Month.                                       |
|MonthBegin         | Calendar Month Begin.                            |
|MonthEnd           | Calendar Month End.                              |
|Year               | One Year.                                        |
|YearBegin          | Calendar Year Begin.                             |
|YearEnd            | Calendar Year End.                               |
+-------------------+--------------------------------------------------+

The generic Daru::DateOffset class is used for creating a generic offset by passing the number of intervals you want as the value for a key that describes the type of interval. For example to create an offset of 3 days, you pass the option `days: 3` into the Daru::Offset constructor.

``` ruby

require 'daru'

offset = Daru::DateOffset.new(days: 3)
offset + DateTime.new(2012,4,5,2)
#=> #<DateTime: 2012-04-08T02:00:00+00:00 ((2456026j,7200s,0n),+0s,2299161j)>
```

On a similar note, the DateOffset class constructor can accept the options `:secs`, `:mins`,`:hours`, `:days`, `:weeks`, `:months` or `:years`. Optionally, specifying the `:n` option will tell DateOffset to apply a particular offset more than once. To elaborate:

``` ruby

require 'daru'

offset = Daru::DateOffset.new(months: 2, n: 4)
offset + DateTime.new(2011,5,2)
#=> #<DateTime: 2012-01-02T00:00:00+00:00 ((2455929j,0s,0n),+0s,2299161j)>
```

The specialized offset classes like MonthBegin, YearEnd, etc. all reside inside the `Daru::Offsets` namespace and can be used by simply calling `.new` on them. All accept an optional Integer argument that works like the `:n` option for Daru::DateOffset, i.e it applies the offset multiple times.

To elaborate, consider the YearEnd offset. This offsets the date to the nearest year end after itself:

``` ruby

require 'daru'

offset = Daru::Offsets::YearEnd.new
offset + DateTime.new(2012,5,1,5,2,1)
#=> #<DateTime: 2012-12-31T05:02:01+00:00 ((2456293j,18121s,0n),+0s,2299161j)>

# Passing an Integer into an Offsets object will apply the offset that many times:

offset = Daru::Offsets::MonthBegin.new(3)
offset + DateTime.new(2015,3,5)
#=> #<DateTime: 2015-06-01T00:00:00+00:00 ((2457175j,0s,0n),+0s,2299161j)>
```

#### TODO: Talk about the Week offset


The most obvious use of date offsets is for creating `DateTimeIndex` objects with a fixed time interval between each date index. To make creation of indexes easy, each of the offset classes have been linked to certain _string alaises_, which can directly passed to the DateTimeIndex class.

For example, to create a DateTimeIndex of 100 periods with a frequency of 1 hour between each period:

``` ruby

require 'daru'

offset = Daru::DateTimeIndex.date_range(
  :start => '2015-4-4', :periods => 100, :freq => 'H')
#=> #<DateTimeIndex:86417320 offset=H periods=100 data=[2015-04-04T00:00:00+00:00...2015-04-08T03:00:00+00:00]>
```

Likewise all of the above listed offsets can be aliased using strings, which can be used for specifying the offset in a DateTimeIndex index. The string aliases of each offset class are as follows:

+---------------+--------------------------------+
| Alias String  | Offset Class / Description     |
|:-------------:|:------------------------------:|
|'S'            | Second                         |
|'M'            | Minute                         |
|'H'            | Hour                           |
|'D'            | Days                           |
|'W'            | Default Week. Anchored on SUN. |
|'W-SUN'        | Week anchored on sunday        |
|'W-MON'        | Week anchored on monday        | 
|'W-TUE'        | Week anchored on tuesday       |
|'W-WED'        | Week anchored on wednesday     |
|'W-THU'        | Week anchored on thursday      |
|'W-FRI'        | Week anchored on friday        |
|'W-SAT'        | Week anchored on saturday      |
|'MONTH'        | Month                          |
|'MB'           | MonthBegin                     |
|'ME'           | MonthEnd                       |
|'YEAR'         | Year                           |
|'YB'           | YearBegin                      |
|'YE'           | YearEnd                        |
+---------------+--------------------------------+

Talk about using date offsets in datetime index with Offset objects and then tell about the string aliases.

For ease of use each date offset is aliased by a string.

A generic date offset (whose use I'll show you shortly) can also be used for generic time intervals.