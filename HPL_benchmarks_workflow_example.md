
[HPL - High Performance Linpack Benchmark](https://www.top500.org/project/linpack/):
====

Testing on multiple computing platforms with Docker
----
Using Ubuntu, I have created a Docker image that installs the dependencies, then downloads, compiles, configures and runs the HPL benchmark. The benchmark measures performance in solving a dense system of linear equations; the user is able to scale the size of the problem.

The computing platforms I will test on are as follows:
1. Mac laptop
2. Azure VM 1 - Standard D2s v3 (2 vcpus, 8 GB memory)
3. Azure VM 2 - Standard NC6 (6 vcpus, 56 GB memory)

*Note: I created a [custom Make file](https://github.com/alan-turing-institute/data-science-benchmarking/blob/master/workflow/example_3_HPL/Make.ubuntu) to work with the dependencies installed via ```apt``` and ```apt-get```*


```python
%%writefile Dockerfile
FROM ubuntu:18.04

# Install dependencies  
RUN apt-get update
RUN apt-get install build-essential emacs -y
RUN apt install libopenmpi-dev -y
RUN apt install openssh-server -y
RUN apt-get install libatlas-base-dev gfortran -y

# Download HPL
RUN wget http://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz
RUN tar xf hpl-2.3.tar.gz
RUN mv hpl-2.3 hpl

# Compile the benchmark with custom Make file
COPY Make.ubuntu /hpl/Make.ubuntu
WORKDIR "/hpl"
RUN make arch=ubuntu
WORKDIR "/hpl/bin/ubuntu"

# Custom config file
COPY HPL.dat HPL.dat

# Run the benchmark
CMD mpirun -np 4 --allow-run-as-root ./xhpl
```

    Overwriting Dockerfile


Setup the HPL.dat configuration file for benchmarking
---

Each line of this config file is explained in [here](http://www.netlib.org/benchmark/hpl/tuning.html).

Here I keep many of the default settings, but change the following:

1. N - set the number of linear equations being solved to 10,000
2. P and Q - since I am using 4 MPI ranks when running the benchmarks (see the ```CMD``` in the Dockerfile), I set a 2 x 2 process grid


```python
%%writefile HPL.dat
HPLinpack benchmark input file
Innovative Computing Laboratory, University of Tennessee
HPL.out      output file name (if any)
6            device out (6=stdout,7=stderr,file)
1            # of problems sizes (N)
10000         Ns
1            # of NBs
232          NBs
0            PMAP process mapping (0=Row-,1=Column-major)
1            # of process grids (P x Q)
2            Ps
2           Qs
16.0         threshold
1            # of panel fact
2            PFACTs (0=left, 1=Crout, 2=Right)
1            # of recursive stopping criterium
4            NBMINs (>= 1)
1            # of panels in recursion
2            NDIVs
1            # of recursive panel fact.
1            RFACTs (0=left, 1=Crout, 2=Right)
1            # of broadcast
1            BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
1            # of lookahead depth
1            DEPTHs (>=0)
2            SWAP (0=bin-exch,1=long,2=mix)
64           swapping threshold
0            L1 in (0=transposed,1=no-transposed) form
0            U  in (0=transposed,1=no-transposed) form
1            Equilibration (0=no,1=yes)
8            memory alignment in double (> 0)
```

    Overwriting HPL.dat



```bash
%%bash
docker build -t edwardchalstrey/hpl_benchmark .
```

    
    Step 1/15 : FROM ubuntu:18.04
     ---> 1d9c17228a9e
    Step 2/15 : RUN apt-get update
     ---> Using cache
     ---> d9ff41fcf2c7
    Step 3/15 : RUN apt-get install build-essential emacs -y
     ---> Using cache
     ---> 1ae04d308aab
    Step 4/15 : RUN apt install libopenmpi-dev -y
     ---> Using cache
     ---> 7b2bce57546a
    Step 5/15 : RUN apt install openssh-server -y
     ---> Using cache
     ---> 66f0dcc1ec2f
    Step 6/15 : RUN apt-get install libatlas-base-dev gfortran -y
     ---> Using cache
     ---> 0c32d16a01c2
    Step 7/15 : RUN wget http://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz
     ---> Using cache
     ---> db1c09a4bd4e
    Step 8/15 : RUN tar xf hpl-2.3.tar.gz
     ---> Using cache
     ---> 723e4047ab5c
    Step 9/15 : RUN mv hpl-2.3 hpl
     ---> Using cache
     ---> bd3415912c99
    Step 10/15 : COPY Make.ubuntu /hpl/Make.ubuntu
     ---> Using cache
     ---> 3308c52d2b49
    Step 11/15 : WORKDIR "/hpl"
     ---> Using cache
     ---> ebbfc230b7fc
    Step 12/15 : RUN make arch=ubuntu
     ---> Using cache
     ---> 9fd80ebb632b
    Step 13/15 : WORKDIR "/hpl/bin/ubuntu"
     ---> Using cache
     ---> 729147c5ad37
    Step 14/15 : COPY HPL.dat HPL.dat
     ---> Using cache
     ---> df0731f40190
    Step 15/15 : CMD mpirun -np 4 --allow-run-as-root ./xhpl
     ---> Using cache
     ---> 0b10062c35f9
    Successfully built 0b10062c35f9
    Successfully tagged edwardchalstrey/hpl_benchmark:latest



```bash
%%bash
docker push edwardchalstrey/hpl_benchmark
```

    The push refers to repository [docker.io/edwardchalstrey/hpl_benchmark]
    6f3f7e77eef4: Preparing
    77d796561be4: Preparing
    d6a2438a68fe: Preparing
    76db63a1ea23: Preparing
    031701f75160: Preparing
    dcfb774847e1: Preparing
    91d0f71d8391: Preparing
    04d308d03718: Preparing
    204467103833: Preparing
    ab748e27090c: Preparing
    7a4226e9f5db: Preparing
    2c77720cf318: Preparing
    1f6b6c7dc482: Preparing
    c8dbbe73b68c: Preparing
    2fb7bfc6145d: Preparing
    91d0f71d8391: Waiting
    04d308d03718: Waiting
    204467103833: Waiting
    ab748e27090c: Waiting
    7a4226e9f5db: Waiting
    2c77720cf318: Waiting
    1f6b6c7dc482: Waiting
    c8dbbe73b68c: Waiting
    2fb7bfc6145d: Waiting
    dcfb774847e1: Waiting
    031701f75160: Layer already exists
    77d796561be4: Layer already exists
    76db63a1ea23: Layer already exists
    6f3f7e77eef4: Layer already exists
    d6a2438a68fe: Layer already exists
    dcfb774847e1: Layer already exists
    91d0f71d8391: Layer already exists
    204467103833: Layer already exists
    04d308d03718: Layer already exists
    ab748e27090c: Layer already exists
    7a4226e9f5db: Layer already exists
    1f6b6c7dc482: Layer already exists
    2c77720cf318: Layer already exists
    c8dbbe73b68c: Layer already exists
    2fb7bfc6145d: Layer already exists
    latest: digest: sha256:70b5800b688b26ccf6e9de67e3d37ea8659c0e1ca839d0266fead60b750e315e size: 3465


Benchmark on different computing platforms
----

1. Mac laptop
2. Azure VM 1 - Standard D2s v3 (2 vcpus, 8 GB memory)
3. Azure VM 2 - Standard NC6 (6 vcpus, 56 GB memory)

```docker run edwardchalstrey/hpl_benchmark```


```python
from IPython.display import HTML, display
import tabulate
```


```python
headers = ["Platform", "Time (s)", "Gflops"]
results_1 = ["Mac laptop", 16.87, 3.9520e+01]
results_2 = ["Azure VM 1", 80.36, 8.2983e+00]
results_3 = ["Azure VM 2", 17.16, 3.8856e+01]
display(HTML(tabulate.tabulate([headers, results_1, results_2, results_3], tablefmt='html')))
```


<table>
<tbody>
<tr><td>Platform  </td><td>Time (s)</td><td>Gflops</td></tr>
<tr><td>Mac laptop</td><td>16.87   </td><td>39.52 </td></tr>
<tr><td>Azure VM 1</td><td>80.36   </td><td>8.2983</td></tr>
<tr><td>Azure VM 2</td><td>17.16   </td><td>38.856</td></tr>
</tbody>
</table>

