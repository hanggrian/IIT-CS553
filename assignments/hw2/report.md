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
>
> **Commands you can use to install tools on Ubuntu 24.04 (and
  documentations):**
>
> - [sysbench](https://manpages.ubuntu.com/manpages/jammy/man1/sysbench.1.html):
    `sudo apt install sysbench`
> - [iPerf](https://manpages.ubuntu.com/manpages/jammy/man1/iperf.1.html):
    `sudo apt install iperf`
    
Each benchmark script produces a text file that reports the running performance,
which, in this instance, is for strong scaling studies. Once the benchmarks are
complete, the values from the text files are manually collected into
`benchmark_result.json`. The Python script uses this resource to plot bar
graphs.

<img
  width="320"
  alt="Screenshot 1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot1.png">

All tests are performed in *Ubuntu Server 24.04* in several environments:

1.  **Bare-metal:** A Chameleon Cloud instance, as discussed in [the tutorial](https://github.com/hanggrian/IIT-CS553/blob/assets/ext2_2.pdf).
1.  **Container:** A LXC container in LXD management.

    ```sh
    sudo lxd init
    sudo lxc launch ubuntu:24.04 container
    sudo lxc shell container
    ```
1.  **VM:** A QEMU/KVM virtual machine. To use the virt-install command, the ISO
    file must be in the libvirt installation directory for permission purposes.

    ```sh
    wget https://mirror.umd.edu/ubuntu-iso/24.04.3/ubuntu-24.04.3-live-server-amd64.iso
    sudo mv ubuntu-24.04.3-live-server-amd64.iso /var/lib/libvirt/images/ubuntu.iso
    sudo virt-install \
      --name vm \
      --ram 131072 \
      --disk size=128,bus=virtio \
      --os-variant ubuntu24.04 \
      --location /var/lib/libvirt/images/ubuntu.iso,kernel=casper/vmlinuz,initrd=casper/initrd \
      --graphics none \
      --console pty,target_type=serial \
      --extra-args 'console=ttyS0' \
      --noautoconsole
    sudo virsh start vm
    ```

## Problem 1

> **CPU:**
>
> - Strong scaling studies: Fixed prime numbers limit at 100,000. Then, measure
    the performance of each virtualization technologies when varying the number
    of threads.
> - Sample command (you might need to use additional command line arguments):
>
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

The container overheads are essentially the same as those of bare metal at 99%,
while the VM is slightly lower at 98%. However, VM is consistently 1&ndash;2
seconds slower in latency compared to others.

<img
  width="320"
  alt="Screenshot 2"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot2.png">

<img
  width="640"
  alt="Figure 1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/figure1.png">

Virtualization type | Threads | Avg. latency | Measured throughput | Overheads
--- | ---: | ---: | ---: | ---:
Bare-metal | 1 | 18.67 ms | 53.53 events/sec | 99%
Container | 1 | 18.66 ms | 53.55 events/sec | 100%
VM | 1 | 18.87 ms | 52.91 events/sec | 98%
Bare-metal | 2 | 19.56 ms | 102.21 events/sec | 100%
Container | 2 | 19.67 ms | 101.61 events/sec | 99%
VM | 2 | 19.83 ms | 100.76 events/sec | 98%
Bare-metal | 4 | 19.45 ms | 205.48 events/sec | 100%
Container | 4 | 19.45 ms | 205.47 events/sec | 99%
VM | 4 | 19.61 ms | 203.75 events/sec | 99%
Bare-metal | 8 | 20.04 ms | 398.71 events/sec | 99%
Container | 8 | 19.99 ms | 399.89 events/sec | 100%
VM | 8 | 20.15 ms | 396.40 events/sec | 99%
Bare-metal | 16 | 20.43 ms | 782.38 events/sec | 100%
Container | 16 | 20.56 ms | 776.85 events/sec | 99%
VM | 16 | 20.79 ms | 768.50 events/sec | 98%
Bare-metal | 32 | 23.48 ms | 1360.52 events/sec | 99%
Container | 32 | 23.47 ms | 1361.33 events/sec | 100%
VM | 32 | 23.59 ms | 1354.59 events/sec | 99%

## Problem 2

> **Memory:**
>
> - Strong scaling studies: Fixed total data size in memory at 120GB. Then,
    measure the performance of each virtualization technologies with the
    following specifications:
>
>   1.  Block size: 1KB i.e., 2<sup>10</sup> to 2<sup>20</sup> bytes
>   1.  Operations: Read
>   1.  Access pattern: Random
> - Sample command:
>
>   ```sh
>   sysbench memory --memory-block-size=1K --memory-total-size=120G --threads=1 run
>   ```
> - Fill in the below using benchmark results of each scale/type regarding the
    memory performance:
>
>   Similar to efficiency example in CPU benchmark, the efficiency denotes a
    relative performance of a virtualization type vs. baremetal.

VM has the lowest efficiency in the memory benchmark, as expected, although it
does not seem to affect the total operations. In terms of efficiency, all
instances seem to peak at 8 threads despite having a total of 32 available.

<img
  width="320"
  alt="Screenshot 3"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot3.png">

<img
  width="640"
  alt="Figure 2"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/figure2.png">

Virtualization type | Threads | Total operations | Throughput | Efficiency
--- | ---: | ---: | ---: | ---:
Bare-metal | 1 | 22906443 | 22369.57 ops/sec | 99%
Container | 1 | 22936241 | 22398.67 ops/sec | 100%
VM | 1 | 21749419 | 21239.67 ops/sec | 94%
Bare-metal | 2 | 44027063 | 42995.18 ops/sec | 100%
Container | 2 | 39730396 | 38799.21 ops/sec | 90%
VM | 2 | 38151830 | 37257.65 ops/sec | 86%
Bare-metal | 4 | 77378502 | 75564.94 ops/sec | 100%
Container | 4 | 77242347 | 75431.98 ops/sec | 99%
VM | 4 | 73990094 | 72255.95 ops/sec | 95%
Bare-metal | 8 | 125829120 | 122880.00 ops/sec | 100%
Container | 8 | 125829120 | 122880.00 ops/sec | 100%
VM | 8 | 125829120 | 122880.00 ops/sec | 100%
Bare-metal | 16 | 125829120 | 122880.00 ops/sec | 100%
Container | 16 | 125829120 | 122880.00 ops/sec | 100%
VM | 16 | 125829120 | 122880.00 ops/sec | 100%
Bare-metal | 32 | 125829120 | 122880.00 ops/sec | 100%
Container | 32 | 125829120 | 122880.00 ops/sec | 100%
VM | 32 | 125829120 | 122880.00 ops/sec | 100%

## Problem 3

> **Disk:**
>
> - Strong scaling studies: Fixed total data size on disk at 120GB. Then,
    measure the performance of each virtualization technologies with the
    following specifications:
>
>   1.  Number of files: 128
>   1.  File block size: 4,096 bytes
>   1.  File total size: 120GB
>   1.  Test mode: Random Read
>   1.  IO Mode: Synchronous
>   1.  Extra IO flag: DirectIO
> - Sample commands:
>
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
that LXC/LXD has implemented a mechanism to improve disk read speed in
containers. However, having tried multiple Linux distribution images, I still
could not explain why VMs perform better than bare-metal.

<img
  width="320"
  alt="Screenshot 4"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/screenshot4.png">

<img
  width="640"
  alt="Figure 3"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/figure3.png">

Virtualization type | Threads | Total operations | Throughput | Efficiency
--- | ---: | ---: | ---: | ---:
Bare-metal | 1 | 93354 | 36.45 ops/sec | 20%
Container | 1 | 454448 | 177.42 ops/sec | 100%
VM | 1 | 133847 | 52.24 ops/sec | 29%
Bare-metal | 2 | 170568 | 66.59 ops/sec | 19%
Container | 2 | 876696 | 342.27 ops/sec | 100%
VM | 2 | 276151 | 107.80 ops/sec | 31%
Bare-metal | 4 | 322679 | 125.98 ops/sec | 21%
Container | 4 | 1503781 | 587.10 ops/sec | 100%
VM | 4 | 546511 | 213.29 ops/sec | 36%
Bare-metal | 8 | 531908 | 207.66 ops/sec | 18%
Container | 8 | 2874140 | 1122.52 ops/sec | 100%
VM | 8 | 763809 | 298.17 ops/sec | 26%
Bare-metal | 16 | 676642 | 264.26 ops/sec | 14%
Container | 16 | 4569054 | 1784.47 ops/sec | 100%
VM | 16 | 872563 | 340.69 ops/sec | 19%
Bare-metal | 32 | 851575 | 332.58 ops/sec | 15%
Container | 32 | 5384094 | 2102.76 ops/sec | 100%
VM | 32 | 738303 | 288.20 ops/sec | 13%

## Problem 4

> **Network:**
>
> - Strong scaling studies using one server vs. N number of clients. Measure the
    performance of each virtualization technologies with the following
    specifications:
>
>   1.  Server TCP window size: 1MB
>   1.  Client TCP write buffer size: 8192KB
>   1.  Client TCP window size: 2.5MB
>   1.  Naggle algorithm: Off
> - The configuration of client/server should communicate using TCP over local
    loopback.
> - Sample commands:
>
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
  alt="Figure 4"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw2/figure4.png">

Virtualization type | Threads | Total operations | Measured throughput | Efficiency
--- | ---: | ---: | ---: | ---:
Bare-metal | 1 | 34.4 | 29.5 ops/sec | 89%
Container | 1 | 38.3 | 33.3 ops/sec | 100%
VM | 1 | 34.0 | 29.2 ops/sec | 88%
Bare-metal | 2 | 65.3 | 56.0 ops/sec | 90%
Container | 2 | 72.4 | 62.1 ops/sec | 100%
VM | 2 | 50.9 | 43.6 ops/sec | 70%
Bare-metal | 4 | 119 | 102 ops/sec | 90%
Container | 4 | 132 | 113 ops/sec | 100%
VM | 4 | 89.8 | 76.9 ops/sec | 68%
Bare-metal | 8 | 212 | 182 ops/sec | 95%
Container | 8 | 221 | 190 ops/sec | 100%
VM | 8 | 166 | 142 ops/sec | 74%
Bare-metal | 16 | 313 | 268 ops/sec | 100%
Container | 16 | 298 | 255 ops/sec | 95%
VM | 16 | 270 | 231 ops/sec | 86%
Bare-metal | 32 | 395 | 339 ops/sec | 100%
Container | 32 | 379 | 324 ops/sec | 95%
VM | 32 | 324 | 278 ops/sec | 82%
