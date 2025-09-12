<!-- KaTeX -->
<script
  type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {inlineMath: [['$', '$']]},
    messageStyle: 'none',
  });
</script>

# [Homework 2](https://github.com/hanggrian/IIT-CS553/blob/assets/assignments/hw2.pdf): Report

> This project aims to teach you how to understand the overhead of various
  virtualization technologies through benchmarking as well as familiarize
  yourself with operating Linux environment on the cloud. You can be creative
  with this project. Since there are many experiments to run, find ways (e.g.
  scripts) to automate the performance evaluation. You might find a combination
  of bash scripting along with tmux/screen helpful. You can use any Linux
  distribution for this assignment, but you must make sure your program runs and
  are the results are re-producible on **Ubuntu Linux 24.04 on the Chameleon
  Cloud.**
>
> In this project, by using **sysbench** and **iPerf,** you will perform strong
  scaling studies for each of the benchmark types: **CPU, Memory, Disk** and
  **Network.** Strong scaling studies mean this means you will set the amount of
  work (e.g. the number of instructions or the amount of data to evaluate in
  your benchmark) and reduce the amount of work per thread as you increase the
  number of threads. You must incorporate bash scripting for: environment
  (baremetal/container/VM) orchestration, run benchmark and Python to analyze
  the results and plotting.

Each benchmark script produces a text file that reports the running performance,
which, in this instance, is for strong scaling studies. Once the benchmarks are
complete, the values from the text files are manually collected into
`benchmark_result.json`. The Python script uses this resource to plot bar
graphs.

<img
  width="320"
  alt="Screenshot 1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot1.png">

<span style="color: yellow;">
  Data from <code>benchmark_result.json</code> is currently measured in local
  computer for testing purposes.
  <b>
    Replace with Chameleon Cloud later.
  </b>
</span>

## Problem 1

> **CPU:**
>
> - Strong scaling studies: Fixed prime numbers limit at 100,000. Then, measure
    the performance of each virtualization technologies when varying the number
    of threads.
> - Sample command (you might need to use additional command line arguments):
>   ```sh
>   sysbench cpu --cpu-max-prime=100000 --threads=1
>   ```
> - Fill in the below using benchmark results of each scale regarding the
    processor performance:
>
>   Note that the efficiency denotes a relative performance of a virtualization
    type vs. baremetal. EX:
>
>   - Baremetal: 10 events per second
>   - Container: 11 events per second
>   - VM: 12 events per second
>
>   This translates to the efficiency of:
>
>   - Baremetal: 100%
>   - Container: 90%
>   - VM: 80%



<img
  width="320"
  alt="Screenshot 2.1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot2_1.png">

<img
  width="640"
  alt="Screenshot 2.2"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot2_2.png">

Virtualization type | Threads | Avg. latency<br>(ms) | Measured throughput<br>(events per second) | Overheads
--- | --- | --- | --- | ---
Bare-metal | 1 | | | 100%
Container | 1
VM | 1
Bare-metal | 2 | | | 100%
Container | 2
VM | 2
Bare-metal | 4 | | | 100%
Container | 4
VM | 4
Bare-metal | 8 | | | 100%
Container | 8
VM | 8
Bare-metal | 16 | | | 100%
Container | 16
VM | 16
Bare-metal | 32 | | | 100%
Container | 32
VM | 32
Bare-metal | 64 | | | 100%
Container | 64
VM | 64

## Problem 2

> **Memory:**
>
> - Strong scaling studies: Fixed total data size in memory at 120GB. Then,
    measure the performance of each virtualization technologies with the
    following specifications:
>   1.  Block size: 1KB i.e., $2^{10}$ to $2^{20}$ bytes
>   1.  Operations: Read
>   1.  Access pattern: Random
> - Sample command:
>   ```sh
>   sysbench memory --memory-block-size=1K --memory-total-size=120G --threads=1 run
>   ```
> - Fill in the below using benchmark results of each scale/type regarding the
    memory performance:
>
>   Similar to efficiency example in CPU benchmark, the efficiency denotes a
    relative performance of a virtualization type vs. baremetal.

<img
  width="320"
  alt="Screenshot 3.1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot3_1.png">

<img
  width="640"
  alt="Screenshot 3.2"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot3_2.png">

Virtualization type | Threads | Total operations | Throughput<br>(MiB/sec) | Efficiency
--- | --- | --- | --- | --- |
Bare-metal | 1 | | | 100%
Container | 1
VM | 1
Bare-metal | 2 | | | 100%
Container | 2
VM | 2
Bare-metal | 4 | | | 100%
Container | 4
VM | 4
Bare-metal | 8 | | | 100%
Container | 8
VM | 8
Bare-metal | 16 | | | 100%
Container | 16
VM | 16
Bare-metal | 32 | | | 100%
Container | 32
VM | 32
Bare-metal | 64 | | | 100%
Container | 64
VM | 64

## Problem 3

> **Disk:**
>
> - Strong scaling studies: Fixed total data size on disk at 120GB. Then,
    measure the performance of each virtualization technologies with the
    following specifications:
>   1.  Number of files: 128
>   1.  File block size: 4,096 bytes
>   1.  File total size: 120GB
>   1.  Test mode: Random Read
>   1.  IO Mode: Synchronous
>   1.  Extra IO flag: DirectIO
> - Sample commands:
>   ```sh
>   sysbench fileio --file-num=128 --file-block-size=4096 --file-total-size=120G --file-test-mode=rndrd --file-io-mode=sync --file-extra-flags=direct --threads=1 <prepare/run/cleanup>
>   ```
> - Fill in the below using benchmark results of each scale/type regarding the
    I/O performance:
>
>   Similar to efficiency example in CPU benchmark, the efficiency denotes a
    relative performance of a virtualization type vs. baremetal.

<img
  width="320"
  alt="Screenshot 4.1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot4_1.png">

<img
  width="640"
  alt="Screenshot 4.2"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot4_2.png">

Virtualization type | Threads | Total operations | Throughput<br>(MiB/sec) | Efficiency
--- | --- | --- | --- | --- |
Bare-metal | 1 | | | 100%
Container | 1
VM | 1
Bare-metal | 2 | | | 100%
Container | 2
VM | 2
Bare-metal | 4 | | | 100%
Container | 4
VM | 4
Bare-metal | 8 | | | 100%
Container | 8
VM | 8
Bare-metal | 16 | | | 100%
Container | 16
VM | 16
Bare-metal | 32 | | | 100%
Container | 32
VM | 32
Bare-metal | 64 | | | 100%
Container | 64
VM | 64

## Problem 4

> **Network:**
>
> - Strong scaling studies using one server vs. N number of clients. Measure the
    performance of each virtualization technologies with the following
    specifications:
>   1.  Server TCP window size: 1MB
>   1.  Client TCP write buffer size: 8192KB
>   1.  Client TCP window size: 2.5MB
>   1.  Naggle algorithm: Off
> - The configuration of client/server should communicate using TCP over local
    loopback.
> - Sample commands:
>   ```sh
>   iperf -s -w 1M
>   iperf -c 127.0.0.1 -e -i 1 --nodelay -l 8192K --trip-times --parallel 1
>   ```
> - Fill in the below using benchmark results of each scale/type regarding the
    I/O performance:
>
>   Similar to efficiency example in CPU benchmark, the efficiency denotes a
    relative performance of a virtualization type vs. baremetal.

<img
  width="320"
  alt="Screenshot 5.1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot5_1.png">

<img
  width="320"
  alt="Screenshot 5.2"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot5_2.png">

<img
  width="640"
  alt="Screenshot 5.3"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot5_3.png">

Virtualization type | Threads | Total operations | Measured throughput<br>(Gbits/sec) | Efficiency
--- | --- | --- | --- | --- |
Bare-metal | 1 | | | 100%
Container | 1
VM | 1
Bare-metal | 2 | | | 100%
Container | 2
VM | 2
Bare-metal | 4 | | | 100%
Container | 4
VM | 4
Bare-metal | 8 | | | 100%
Container | 8
VM | 8
Bare-metal | 16 | | | 100%
Container | 16
VM | 16
Bare-metal | 32 | | | 100%
Container | 32
VM | 32
Bare-metal | 64 | | | 100%
Container | 64
VM | 64
