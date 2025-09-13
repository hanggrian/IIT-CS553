<!-- KaTeX -->
<script
  type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
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

<style>
  .warning-table tr {
    color: red;
  }
  .warning-table td {
    color: red;
  }
</style>

<span style="color: red;">
  Data from <code>benchmark_result.json</code> is currently measured in local
  computer for testing purposes.
  <b>
    Replace with Chameleon Cloud later.
  </b>
</span>

<table class="warning-table">
  <thead>
    <tr>
      <th>Hardware</th>
      <th>Model</th>
      <th>Specifications</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>CPU</td>
      <td>Intel Core i5-10400</td>
      <td>2.9&ndash;4.3 GHz, 6 cores, 12 threads, 65 W</td>
    </tr>
    <tr>
      <td>Memory</td>
      <td>Corsair Vengeance LPX</td>
      <td>4&times;8 GB, DDR4-2666, CL16</td>
    </tr>
    <tr>
      <td>Disk</td>
      <td>Samsung 970 EVO</td>
      <td>250 GB, PCIe Gen3</td>
    </tr>
    <tr>
      <td>Network</td>
      <td>Intel I219-V</td>
      <td>1 GbE</td>
    </tr>
  </tbody>
</table>

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

The container and virtual machine perform respectably well at above 93% compared
to bare-metal in the CPU benchmark. When all 12 threads are depleted, all
instances scored the same result with 29 ms latency.

<img
  width="320"
  alt="Screenshot 2.1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot2_1.png">

<img
  width="640"
  alt="Screenshot 2.2"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot2_2.png">

Virtualization type | Threads | Avg. latency | Measured throughput | Overheads
--- | ---: | ---: | ---: | ---:
Bare-metal | 1 | 17.26 ms | 57.94 events/sec | 95%
Container | 1 | 16.90 ms | 59.17 events/sec | 97%
VM | 1 | 16.51 ms | 60.57 events/sec | 100%
Bare-metal | 2 | 18.01 ms | 111.01 events/sec | 94%
Container | 2 | 17.10 ms | 1116.89 events/sec | 98%
VM | 2 | 16.94 ms | 118.00 events/sec | 100%
Bare-metal | 4 | 18.45 ms | 216.72 events/sec | 93%
Container | 4 | 17.34 ms | 230.48 events/sec | 99%
VM | 4 | 17.16 ms | 232.97 events/sec | 93%
Bare-metal | 8 | 20.01 ms | 399.48 events/sec | 96%
Container | 8 | 19.38 ms | 412.22 events/sec | 100%
VM | 8 | 19.36 ms | 412.98 events/sec | 100%
Bare-metal | 16 | 29.09 ms | 549.30 events/sec | 100%
Container | 16 | 29.30 ms | 545.63 events/sec | 99%
VM | 16 | 29.20 ms | 547.35 events/sec | 99%

## Problem 2

> **Memory:**
>
> - Strong scaling studies: Fixed total data size in memory at 120GB. Then,
    measure the performance of each virtualization technologies with the
    following specifications:
>   1.  Block size: 1KB i.e., 2<sup>10</sup> to 2<sup>20</sup> bytes
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

VM unexpectedly scored higher than the container in the memory benchmark,
although not by much. All instances seem to peak at 8 threads despite having a
total of 12 available.

<img
  width="320"
  alt="Screenshot 3.1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot3_1.png">

<img
  width="640"
  alt="Screenshot 3.2"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot3_2.png">

Virtualization type | Threads | Total operations | Throughput | Efficiency
--- | ---: | ---: | ---: | ---:
Bare-metal | 1 | 26467563 | 25847.23 MiB/sec | 100%
Container | 1 | 24445004 | 23872.07 MiB/sec | 92%
VM | 1 | 25568001 | 24968.75 MiB/sec | 96%
Bare-metal | 2 | 50295724 | 49116.92 MiB/sec | 100%
Container | 2 | 47954872 | 46830.93 MiB/sec | 95%
VM | 2 | 49304550 | 48148.97 MiB/sec | 98%
Bare-metal | 4 | 96966142 | 94693.50 MiB/sec | 100%
Container | 4 | 84303296 | 82327.44 MiB/sec | 86%
VM | 4 | 86409826 | 84384.60 MiB/sec | 89%
Bare-metal | 8 | 125829120 | 122880.00 MiB/sec | 100%
Container | 8 | 125829120 | 122880.00 MiB/sec | 100%
VM | 8 | 125829120 | 122880.00 MiB/sec | 100%
Bare-metal | 16 | 125829120 | 122880.00 MiB/sec | 100%
Container | 16 | 125829120 | 122880.00 MiB/sec | 100%
VM | 16 | 125829120 | 122880.00 MiB/sec | 100%

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

For some unknown reasons, bare-metal has the lowest score in the disk benchmark
by less than half of the operations compared to the container. It is possible
that Docker has implemented a mechanism to improve disk read speed in
containers. However, having tried multiple Linux distribution images, I still
could not explain why VMs perform better than bare-metal.

<img
  width="320"
  alt="Screenshot 4.1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot4_1.png">

<img
  width="640"
  alt="Screenshot 4.2"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot4_2.png">

Virtualization type | Threads | Total operations | Throughput | Efficiency
--- | ---: | ---: | ---: | ---:
Bare-metal | 1 | 177022 | 69.14 MiB/sec | 45%
Container | 1 | 392587 | 153.34 MiB/sec | 100%
VM | 1 | 265197 | 103.58 MiB/sec | 67%
Bare-metal | 2 | 343117 | 134.01 MiB/sec | 39%
Container | 2 | 863804 | 337.38 MiB/sec | 100%
VM | 2 | 544401 | 212.63 MiB/sec | 63%
Bare-metal | 4 | 447353 | 174.72 MiB/sec | 32%
Container | 4 | 1361300 | 531.69 MiB/sec | 100%
VM | 4 | 930227 | 363.32 MiB/sec | 68%
Bare-metal | 8 | 731577 | 285.74 MiB/sec | 46%
Container | 8 | 1569443 | 612.98 MiB/sec | 100%
VM | 8 | 1268565 | 495.47 MiB/sec | 80%
Bare-metal | 16 | 1067485 | 416.92 MiB/sec | 70%
Container | 16 | 1520467 | 593.85 MiB/sec | 100%
VM | 16 | 1302822 | 508.84 MiB/sec | 85%

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

Two shell sessions are required to complete a network benchmark (or tmux), a
server script that listens in the background, and a client script that prints
the results. The bare-metal performance is comparable to the container while VM
is the worst.

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

Virtualization type | Threads | Total operations | Measured throughput | Efficiency
--- | ---: | ---: | ---: | ---:
Bare-metal | 1 | 69.7 | 59.8 Gbits/sec | 79%
Container | 1 | 87.8 | 75.4 Gbits/sec | 100%
VM | 1 | 62.1 | 53.3 Gbits/sec | 70%
Bare-metal | 2 | 124 | 107 Gbits/sec | 88%
Container | 2 | 140 | 120 Gbits/sec | 100%
VM | 2 | 106 | 90.7 Gbits/sec | 75%
Bare-metal | 4 | 190 | 163 Gbits/sec | 92%
Container | 4 | 206 | 176 Gbits/sec | 100%
VM | 4 | 150 | 129 Gbits/sec | 72%
Bare-metal | 8 | 228 | 196 Gbits/sec | 95%
Container | 8 | 240 | 206 Gbits/sec | 100%
VM | 8 | 180 | 154 Gbits/sec | 75%
Bare-metal | 16 | 200 | 172 Gbits/sec | 98%
Container | 16 | 203 | 174 Gbits/sec | 100%
VM | 16 | 205 | 175 Gbits/sec | 86%
