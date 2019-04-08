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
