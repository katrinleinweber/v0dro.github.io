layout: post
title: Interpreting the results of the STREAM benchmark
date: 2020-02-27 09:00 +0900
---

# Introduction

The STREAM benchmark is considered an important benchmark for understanding the memory
bandwidth and access latency of a particular computer. This benchmark was conceptualized
in the 1995 paper <!-- insert name -->.

# Machine Balance

At the heart of the benchmark lies a definition of 'machine balance'. Previous to STREAM,
machine balance was simply defined as the number of floating point operations per clock
cycle to the number of memory operations per clock cycle. This is known as the 'balance'
since it shows the time taken for executing useful work (floating point operations) vs.
work that is absolutely necessary for performing the useful work but is always a bottleneck
in performance (memory access latency).

However, this definition fails to capture the complexity
of hierarchical memory structures that use multiple layers of cache and parallelization
strategies such as pipelining and prefetching. This is because the number of floating point
operations per cycle can greatly vary depending on the location of the data that is being
operated on. The peak will be reached when the data resides in registers, whereas for 
data being accessed from memory, the number of cycles taken to execute a single floating
point operation will be much higher due to latency.

If this is the case, one might wonder why taking an average of this simple definition is
not adequate since working with a long-enough array will engage the registers and the
RAM too, and should give an estimate of the average number of floating point ops per cycle.
<!-- explain why over here -->

The STREAM benchmark refines the definition of 'machine balance' and defines it as the PEAK
floating point operations per cycle divided by the number of sustained memory operations per
cycle.

# Useful links

* https://stackoverflow.com/questions/56086993/what-does-stream-memory-bandwidth-benchmark-really-measure
* https://sites.utexas.edu/jdm4372/tag/stream-benchmark/
* https://blogs.fau.de/hager/archives/8263
* https://stackoverflow.com/questions/39260020/why-is-skylake-so-much-better-than-broadwell-e-for-single-threaded-memory-throug
