<script
  type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {inlineMath: [['$', '$']]},
    messageStyle: "none",
  });
</script>

# [Homework 4](https://github.com/hanggrian/IIT-CS553/blob/assets/assignments/hw4.pdf): Report

> This project aims to teach you about file I/O and benchmarking. You must C or
  C++ for this assignment. You can use the following libraries: STL, Boost,
  PThread, OMP, BLAKE3, SYCL, CUDA, MMAP, and CUFile. You must use Linux system
  for your development and evaluation. The performance evaluation should be done
  on Chameleon on Ubuntu Linux 24.03. You will make use of a hashing algorithm:
>
> [View Blake3 repo][Blake3] / [paper](https://github.com/BLAKE3-team/BLAKE3-specs/blob/master/blake3.pdf)
>
> Your benchmark will use a 6-byte NONCE to generate $2^{26}$ (SMALL) or
  $2^{32}$ (LARGE) BLAKE3 hashes of 10-bytes long each and store them in a file
  on disk in sorted order (sorted by 10-byte hash). A record could be defined in
  C as follows:
>
> ```c
> #define NONCE_SIZE 6
> #define HASH_SIZE 10
>
> // Structure to hold a 16-byte record
> typedef struct {
>     uint8_t hash[HASH_SIZE]; // hash value as byte array
>     uint8_t nonce[NONCE_SIZE]; // Nonce value as byte array
> } Record;
> ```
>
> Your file should be 1GB (SMALL) or 64GB (LARGE) in size when your benchmark
  completes $(64GB = 2^{32} \cdot (10B + 6B))$ &mdash; your file should be
  written in binary to ensure efficient write and read to this data; do not
  write the data in ASCII. You are to parallelize your various stages (hash
  generation, sort, and disk write) with a pool of threads per stage, that can
  be controlled separately.
>
> Here are the command line arguments your program should have:
>
> ```
> cc@hw4-raicu-skylake:~/vault$ ./vaultx -h
> Usage: ./vaultx [OPTIONS]
> Options:
> -a, --approach [task|for] Parallelization mode (default: for)
> -t, --threads NUM Hashing threads (default: all cores)
> ⋮
> -h, --help Display this help message
> Example:
> ./vaultx -t 24 -i 1 -m 1024 -k 26 -g memo.t -f memo.x -d true
>
> cc@hw4-raicu-skylake:~/vault$ ./vaultx -t 24 -i 1 -m 256 -k 26 -g memo.t -f
> k26-memo.x -d true
> Selected Approach : for
> Number of Threads : 24
> ⋮
> Final Output File : k26-memo.x
> [1.34] HashGen 25.00%: 15.35 MH/s : I/O 87.84 MB/s
> [2.36] HashGen 50.00%: 16.48 MH/s : I/O 94.31 MB/s
> ⋮
> [7.38] Shuffle 75.00%: 155.98 MB/s
> File 'memo.t' removed successfully.
> Total Throughput: 6.80 MH/s 103.79 MB/s
> Total Time: 9.866384 seconds
>
> cc@hw4-raicu-skylake:~/vault$ ./vaultx -t 24 -i 1 -m 256 -k 26 -g memo.t -f
> k26-memo.x -d false vaultx t24 i1 m256 k26 6.82 104.02 9.844270
> ```

This project uses C++ 23 standard, [Boost libraries](https://www.boost.org/),
[OpenMP interface](https://www.openmp.org/) and [Blake3] pulled from the GitHub
repository. Run `./build.sh` to generate the executable with CMake commands. GCC
version 14 or higher is required to compile the project, run `./setup.sh` to
automate this process.

The help command is implemented using [Boost Program Options](https://www.boost.org/doc/libs/latest/doc/html/program_options.html) library. It helps capture flags, parse boolean switches
and format the help message.

<img
  width="320px"
  alt="Screenshot 1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw4/screenshot1.png">

> You should be able to verify that the data you are writing is correct.
>
> ```
> cc@hw4-raicu-skylake:~/vault$ ./vaultx -t 24 -i 1 -m 256 -k 26 -g memo.t -f
> k26-memo.x -d false -v true
> vaultx t24 i1 m256 k26 6.71 102.45 9.995002
> verifying sorted order by bucketIndex of final stored file...
> Size of 'k26-memo.x' is 1073741824 bytes.
> [1.22] Verify 25.00%: 236.97 MB/s
> [2.36] Verify 50.00%: 237.32 MB/s
> ⋮
> [4.72] Verify 100.00%: 237.26 MB/s
> sorted=42413664 not_sorted=0 zero_nonces=24695200 total_records=67108864
> ```
>
> You should be able to print the contents:
>
> ```
> cc@hw4-raicu-skylake:~/vault$ ./vaultx -k 26 -f k26-memo.x -p 20
> [0] stored: BLANK nonce: BLANK
> [16] stored: 0000009fcad95785e04e nonce: 180358880493568
> ⋮
> [304] stored: BLANK nonce: BLANK
> ```

The hash generation stage divides the nonce into smaller chunks and processes
each chunk in parallel using a thread pool by default, or OpenMP parallelization
when the `-a task` flag is set. The chunks, stored in memory buffers, are then
sorted using parallel sort with the [Boost Sort](https://www.boost.org/doc/libs/latest/libs/sort/doc/html/index.html) library. The sorted chunks are saved into temporary files (`-g` flag) before
being merged into the final output file (`-f` flag).

<img
  width="320px"
  alt="Screenshot 2"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw4/screenshot2.png">

The verification process, with the `-v` flag, sequentially reads the final
sorted file to make sure that all records are in correct order. The verification
also checks for empty nonce entries.

<img
  width="320px"
  alt="Screenshot 3.1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw4/screenshot3_1.png">
<img
  width="320px"
  alt="Screenshot 3.2"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw4/screenshot3_2.png">

> Once you have everything done, we want to search through the file. You are
  going to generate random search queries based on the difficulty, and execute
  the search, and report statistics at the end of the search.
>
> ```
> cc@hw4-raicu-skylake:~/vault$ ./vaultx -k 26 -f k26-memo.x -s 10 -q 3 -d true
> searches=10 difficulty=3
> Parsed k : 26
> Nonce Size : 6
> ⋮
> Actual file size on disk : 1073741824 bytes
> [0] 1213ae MATCH 1213aef913a754c0aee2 185081113280512 time=0.053 ms comps=3
> MATCH 1213aea8365ef5c396d8 153924027875328 time=0.053 ms comps=3
> ⋮
> MATCH 66a4461ea8513780f333 142229553283072 time=0.041 ms comps=4
> Search Summary: requested=10 performed=10 found_queries=10 total_matches=33
>   notfound=0
> total_time=0.000433 s avg_ms=0.043 ms searches/sec=23081.842 total_seeks=10
> avg_seeks_per_search=1.000 total_comps=33 avg_comps_per_search=3.300
> avg_matches_per_found=3.300
>
> cc@hw4-raicu-skylake:~/vault$ ./vaultx -k 26 -f k26-memo.x -s 10 -q 4 -d true
> searches=10 difficulty=4
> Parsed k : 26
> Nonce Size : 6
> ⋮
> Actual file size on disk : 1073741824 bytes
> [0] 3267c542 NOTFOUND time=0.052 ms comps=0
> [1] 26992e1a NOTFOUND time=0.042 ms comps=4
> ⋮
> [9] ffd3869c NOTFOUND time=0.040 ms comps=3
> Search Summary: requested=10 performed=10 found_queries=0 total_matches=0
>   notfound=10
> total_time=0.000419 s avg_ms=0.042 ms searches/sec=23893.378 total_seeks=10
>
> avg_seeks_per_search=1.000 total_comps=30 avg_comps_per_search=3.000
> avg_matches_per_found=0.000
> ```

Searching is done with the `-s` and `-q` flags, defining the number of searches
and difficulty, respectively. Each search query is performed using binary search
on the sorted file to minimize disk seeks per query. When a match is found, the
program then scans backwards and forwards to find all matching records.

<img
  width="320px"
  alt="Screenshot 4"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw4/screenshot4.png">

> You are to create a makefile that helps build your benchmark, as well as run
  it through the benchmark bash script. You must be able to configure the
  `NONCE_SIZE` and `HASH_SIZE` at compile time, or possibly at runtime through a
  command line interface (e.g. `make vaultx_x86_c NONCE_SIZE=6 RECORD_SIZE=16`)
>
> Other requirements:
>
> - You must write all benchmarks from scratch. Do not use code you find online,
    as you will get 0 credit for this assignment. This is also an individual
    group assignment, make sure you do this assignment by yourself.
> - All of the benchmarks will have to evaluate concurrency performance;
    concurrency can be achieved using processes or threads.
> - Not all timing functions have the same accuracy; you must find one that has
    at least 1ms accuracy or better, assuming you are running the benchmarks for
    at least seconds at a time.
> - Since there are many experiments to run, you must use a bash script to
    automate the performance evaluation.
> - You must use binary data when writing in this benchmark.
> - No GUIs are required. Simple command line interfaces are required.

Nonce and record sizes are configurable at compile-time using
`-DNONCE_SIZE=6 -DHASH_SIZE=10` with CMake. These options are passed to the
compiler during build time, or fallback to default values defined in
`CMakeLists.txt`.

<img
  width="320px"
  alt="Screenshot 5"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw4/screenshot5.png">

## Problem 1

> You will have several command line arguments that you will explore from a
  performance point of view for the SMALL 1GB workload. There are
  $42 = 3 \cdot 7 \cdot 2$ experiments to run, so make sure to automate the
  execution of these runs in a bash script (e.g. 3 nested loops in bash should
  work).
>
> 1.  Maximum memory allowed to use (MB): 256, 512, 1024
> 1.  Number of compute threads: 1, 2, 4, 8, 12, 24, 48
> 1.  Number of write threads: 1, 2, 4
>
> Each experiment should take less than a minute, depending on the hardware,
  processor type, core counts, and hard drive technology. These experiments
  should take less than 1 hour to run.
>
> Fill in the table below for the small workload $(K = 26)$:

Based on the results from the small workload benchmark, the throughput
performance grows with the number of compute threads, although the improvement
is negligible after 24 threads. Larger memory sizes also help improve the
throughput, but is not always consistent like the number of threads. Oddly,
increasing the number of IO threads impacts the performance negatively, at least
in small workloads.

Threads | Memory size | 1 IO threads (MH/s) | 2 IO threads (MH/s) | 4 IO threads (MH/s)
---: | ---: | ---: | ---: | ---:
1 | 256 | 4.70642 | 4.58874 | 5.01103
1 | 512 | 5.06895 | 5.07055 | 4.96701
1 | 1,024 | 5.11752 | 5.14437 | 5.14633
2 | 256 | 5.80156 | 5.83668 | 5.86966
2 | 512 | 6.47532 | 6.52293 | 6.41774
2 | 1,024 | 6.68696 | 6.75846 | 6.66097
4 | 256 | 7.42224 | 6.26674 | 6.26236
4 | 512 | 7.46685 | 7.53278 | 7.25330
4 | 1,024 | 7.08692 | 7.08101 | 7.01328
8 | 256 | 7.28460 | 7.30864 | 7.27058
8 | 512 | 10.79820 | 8.23176 | 8.21978
8 | 1,024 | 7.91785 | 7.75438 | 8.84303
12 | 256 | 9.30797 | 7.38320 | 7.34609
12 | 512 | 8.55917 | 11.01410 | 8.49093
12 | 1,024 | 9.13278 | 8.81494 | 8.96643
24 | 256 | 7.61887 | 7.68504 | 7.64386
24 | 512 | 9.32281 | 8.67591 | 8.86775
24 | 1,024 | 9.31559 | 9.54625 | 9.43943
48 | 256 | 7.79639 | 7.62827 | 7.66559
48 | 512 | 8.94213 | 8.94200 | 8.93600
48 | 1,024 | 9.70507 | 11.37100 | 9.46415

## Problem 2

> Now evaluate the large workload with 64GB data. There are
  $7 = 7 \cdot 1 \cdot 1$ experiments to run, so make sure to automate the
  execution of these runs in a bash script.
> 1.  Maximum memory allowed to use (MB): 1024, 2048, 4096, 8192, 16384, 32768,
      65536
> 1.  Number of compute threads: 24
> 1.  Number of write threads: 1
>
> Each experiment should take a few minutes to tens of minutes, depending on the
  hardware, processor type, core counts, and hard drive technology. These
  experiments should take less than 3 hours to run.
>
> Fill in the table below for the large workload $(K = 32)$:

Increasing the memory size improves the throughput performance for large
workloads, up to a certain point. After 32GB of memory, the performance
significantly drops, likely due to excessive memory allocation given only one
IO thread. The GCC optimization flags are notably impactful in this benchmark,
trimming off minutes from the hash generation time.

Threads | Memory size | 1 IO threads (MH/s)
---: | ---: | ---:
24 | 1,024 | 7.14540
24 | 2,048 | 7.92516
24 | 4,096 | 8.63750
24 | 8,192 | 9.38243
24 | 16,384 | 9.90971
24 | 32,768 | 9.99402
24 | 65,536 | 7.90725

## Problem 3

> Plot the results of these 42+7 experiments and identify the best combination
  of command line arguments. You should create 4 separate plots:
>
> 1.  $K = 26$, fixed write threads = 1, vary memory size and compute threads
> 1.  $K = 26$, fixed write threads = 2, vary memory size and compute threads
> 1.  $K = 26$, fixed write threads = 4, vary memory size and compute threads
> 1.  $K = 32$, fixed write threads = 1, fixed compute threads = 24, vary memory
      size

<img
  width="640px"
  alt="Diagram 1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw4/diagram1.svg">

<img
  width="640px"
  alt="Diagram 2"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw4/diagram2.svg">

## Problem 4

> Explain why you believe the best and worst configurations make sense.

The best configuration for small workloads is 12 compute threads and 1024 MB of
memory size, achieving approximately 9 MH/s. The IO threads do not seem to
impact since file to write is small enough to be handled by a single thread. In
the large workload, the best configuration is 24 threads and 32 GB of memory.
The OpenMP parallelization approach performs better in both cases, reducing up
to 110 seconds in the k=32 workload with default options.

The worst configuration for any case is 1 compute thread and 256 MB of memory.
This is to be expected since single-threaded execution cannot take advantage of
worker threads or OpenMP parallelization. Low memory size also limits the
amount of data that can be buffered before writing to disk.

## Problem 5

> You must run a number of search workloads to fill in the following table:

<img
  width="640px"
  alt="Diagram 3"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw4/diagram3.svg">

K | Difficulty | Number of searches | Average number of disk seek per search | Average data read per search (bytes) | Total time for all searches | Time / search (ms) | Throughput | Number of searches found | Number of searches not found
---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---:
26 | 3 | 1,000 | 1 | 4,096 | 1.83521 | 0.00183 | 545.1 | 1,000 | 0
26 | 4 | 1,000 | 1 | 4,096 | 2.16235 | 0.00216 | 462.7 | 0 | 1,000
26 | 5 | 1,000 | 1 | 4,096 | 2.17494 | 0.00217 | 460.1 | 0 | 1,000
32 | 3 | 1,000 | 1 | 4,096 | 1.86285 | 0.00186 | 537.6 | 1,000 | 0
32 | 4 | 1,000 | 1 | 4,096 | 1.87287 | 0.00187 | 534.1 | 0 | 1,000
32 | 5 | 1,000 | 1 | 4,096 | 1.86923 | 0.00186 | 535.1 | 0 | 1,000

[Blake3]: https://github.com/BLAKE3-team/BLAKE3
