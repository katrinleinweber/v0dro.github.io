---
title: Debugging MPI programs with GDB
date: 2018-04-04T15:04:47+09:00
---

When programming with MPI you might get run time errors like segfaults due to faulty IO programming or the like. The openMPI [FAQ](https://www.open-mpi.org/faq/?category=debugging) has some useful insights.

# Basic stuff

Since you're programming in a distributed environment, using gdb with MPI programs 
is a bit of a challenge, but is quite possible and reasonalbly easy to use as well. 
All you need to do is use the `mpirun` command with gdb in the following manner:
```
mpirun -np <num_processes> xterm -e gdb ./a.out
```

A modified Makefile using the above command would look like so:
```
mpi_debug: mpi_types.o $(SOURCES)
	$(CXX) $? -llapacke -llapack -lcblas
    mpirun -np 2 xterm -e gdb ./a.out
```

You can then call `run` inside gdb for each process. [This stackoverflow answer](https://stackoverflow.com/questions/329259/how-do-i-debug-an-mpi-program) provides more insights into this. 
Basically just use the `-ex` argument right after the `gdb` command.

For example:
```
mpirun -np 4 xterm -e gdb -ex="run" --args ./a.out
```

In case your processes exit after they're finished and the xterm window closes, use
the following to prevent that from happening:
```
mpirun -n 4 xterm -hold -e gdb -ex="run" --args matmul
```
The `hold` option does the trick.

# Multiple nodes

If you're using multiple nodes for running your MPI processes, the debugging process is
slightly different.

