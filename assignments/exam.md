# [Sample exam](https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/exam.pdf)

## Problem 1

> Name some advantages of distributed systems over centralized systems.

- **Scalability:** Easily scale by adding (or removing) nodes to accommodate
  changing workloads.
- **Fault tolerance:** Continue operating even when some nodes fail.
- **Cost Efficiency:** Leverage commodity hardware to reduce costs.

## Problem 2

> Understand the basics of the TCP and UDP communication protocol.

TCP is a connection-oriented protocol, that is, a connection is established
before data is transmitted. In contrast, UDP is a connectionless protocol,
where data is sent without establishing a connection.

## Problem 3

> Identify design patterns can be used to implement a concurrent server.

- **Multi-threading:** Each client connection is handled by a separate thread.
- **Event-driven architecture:** Use non-blocking I/O and event loops to handle
  multiple connections.

## Problem 4

> Why is threading useful on a single-core processor?

Threading allows a single-core processor to manage multiple tasks by rapidly
switching between them, creating the illusion of parallelism.

## Problem 5

> Identify what a thread has of its own (not shared with other threads):

- **Program Counter (PC):** Indicates the current position in the code.
- **Stack:** Each thread has its own stack for function calls and local
  variables.
- **Registers:** Each thread has its own set of CPU registers.

## Problem 6

> Do more threads always mean better performance?

No, better performance in multiple threads is only possible when the workload
can be distributed among all available threads.

## Problem 7

> Is super-linear speedup possible?

Yes, super-linear speedup is possible in certain scenarios, but may not be worth
the extra complexity. For example, an in-memory cache will improve performance
if the bottleneck is disk I/O. However, the improvement is negligible when the
requested dataset size far exceeds the cache size, or if implementing caching
mechanism in distributed systems is too complex.

## Problem 8

> What is an advantage to a connectionless oriented protocol compared to a
  connection-oriented protocol?

A connectionless protocol has lower latency since it does not require
establishing and maintaining a connection, making it suitable for real-time
applications like video streaming and online gaming.

## Problem 9

> What is the purpose of the scheduler in a distributed system?

In the context of a distributed system, the scheduler is responsible for
allocating tasks to various nodes in the system.

## Problem 10

> What are the advantages and disadvantages of centralized scheduling?

- **Advantages:**
  - **Simplicity:** One master node for all workers.
  - **Global view:** Better resource allocation decisions.
- **Disadvantages:**
  - **Prone to failure:** Functionality stops if the master node fails.

## Problem 11

> Why do we need distributed scheduling?

To decompose jobs into smaller tasks that can be executed in parallel across
multiple nodes.

## Problem 12

> You have a cluster with 1000 compute nodes. You have a centralized scheduler
  that can schedule 10 tasks per second. What is the smallest granularity of
  task lengths that your scheduler can support in order to achieve high system
  utilization?

Let $N$ be the number of compute nodes and $S$ be the scheduling rate of the
scheduler. The minimum time $T$ required to keep all compute nodes busy is 100
seconds. For high system utilization, we set $k$ ratio high enough to make sure
the system spends around 90% of its time computing instead of scheduling.

$$
\begin{align}
  T &= \frac{N}{S} \\
  &= \frac{1,000}{10} &= \mathbf{100s} \\
  G &= k \cdot T \\
  &= 10 \cdot 100s &= \mathbf{1,000s}
\end{align}
$$

## Problem 13

> You have a cluster with 1000 compute nodes. You have a distributed scheduler
  that has 1000 schedulers, and each scheduler can process 1 task per second.
  What is the smallest granularity of task lengths that your scheduler can
  support in order to achieve high system utilization?

The total scheduling rate $S$ is 1,000 tasks per second, calculated by
multiplying the number of schedulers $N$ with the rate of each scheduler $R$.
The minimum time $T$ required to keep all compute nodes busy is 1 second.

$$
\begin{align}
  S &= N \cdot R \\
  &= 1,000 \cdot 1 &= \mathbf{1,000} \\
  T &= \frac{N}{S} \\
  &= \frac{1,000}{1,000} &= \mathbf{1 \text{s}} \\
  G &= k \cdot T \\
  &= 10 \cdot 1s &= \mathbf{10 \text{s}}
\end{align}
$$

## Problem 14

> Name a distributed system framework that implements a centralized scheduler?
  Name the major components of this framework.

Apache Hadoop, a data framework using YARN as its centralized scheduler. The
major components are the HDFS file system, MapReduce processing and JPS
instances.

## Problem 15

> Name a technique that is well known to be used to implement distributed
  scheduling? What are the critical configuration parameters, and what do they
  depend on?

Work stealing is a well-known technique used to implement distributed
scheduling. Each node maintains its own local task queue. When a node becomes
idle, it picks another node to "steal" tasks from its queue. The configuration
should consider the steal size, selection strategy and attempt frequency.

Configuration | Dependencies
--- | ---
Steal size | <ul><li>Task granularity</li><li>Network latency</li></ul>
Selection strategy | <ul><li>Network topology</li><li>Work preference</li></ul>
Attempt frequency | <ul><li>System load</li><li>Timeout tolerance</li></ul>
Steal threshold | <ul><li>Task queue length</li></ul>

## Problem 16

> A user is in front of a browser and types in `www.google.com`, and hits the
  enter key. Think of all the protocols that are used in retrieving and
  rendering the Google logo and the empty search box.

1.  **User interaction:** Types URL and hits enter.
1.  **Pre-search queries:** Text autocomplete and suggestions drop-down.
1.  **DNS resolution:** Browser queries DNS server for `www.google.com` IP.
1.  **TCP connection:** Browser establishes TCP connection to Google server.
1.  **TLS handshake:** Secure connection established using TLS protocol.
1.  **HTTP request:** Browser sends HTTP GET request for the homepage.
1.  **Server processing:** Google server routes request to appropriate service.
1.  **Database queries:** Server fetches data from cloud databases.
1.  **HTTP response:** Server sends back HTML, CSS and JavaScript files.
1.  **Fetch resources:** Load static images, fonts and scripts from CDNs.
1.  **Content rendering:** Browser parses HTML and executes JavaScript.

## Problem 17

> Why are locks needed in a multi-threaded program?

Locks are needed to prevent other threads from accessing shared resources
simultaneously until the lock is released. This ensures data consistency in a
multi-threaded program.

## Problem 18

> How is replication different than caching?

Caching is a temporary storage for frequently accessed data, while replication
creates multiple copies of data across different nodes.

## Problem 19

> Why do we need replication?

Replication improves data availability and fault tolerance by providing access
to data even if some nodes fail.

## Problem 20

> Why do we need caching?

Caching reduces data access time to improve performance by duplicating data in
a faster disk or memory.

## Problem 21

> Why did processors from the 1980s not have caches?

In the early days of CPU, the manufacturer decided to allocate as many
transistors as possible to core units, given the limited number of transistors
that can fit on a die. Additionally, the speed gap between CPU and memory was
not as significant as it is today, making caches less necessary.

## Problem 22

> An alternative definition for a distributed system is that of a collection of
  independent computers providing the view of being a single system, that is, it
  is completely hidden from users that there even multiple computers. Give an
  example where this view would come in very handy.

An example is a distributed database system, where dataset is partitioned across
multiple nodes. Using the main interface, users can perform CRUD operations on
the database without having to know which node the data resides on.

## Problem 23

> Would it make sense to limit the number of threads in a server process?

Yes, limiting the number of threads lets other processes have access to the CPU.
Restricting threads also reduces strain on electricity and heat dissipation.

## Problem 24

> Constructing a concurrent server by spawning a process has some advantages and
  disadvantages compared to multithreaded servers.

- **Advantages:**
  - **Simplicity:** Code is easier to write and debug.
  - **Isolation:** Each request runs in its own process space.
  - **Security:** Processes have limited access to each other's resources.
- **Disadvantages:**
  - **Overhead:** Processes consume more resources than threads.
  - **Communication:** Inter-process communication is slower and more complex.
  - **Context switching:** More expensive compared to threads.

## Problem 25

> How does the probability of failure of an entire distributed system (assuming
  all components are necessary to function properly) change as the number of
  independent components in the system grows?

Given $n$ independent components, each with a probability of failure $p$, the
formula for system failure probability is $1 - p ^ n$. As $n$ grows, the overall
system failure probability increases exponentially.

## Problem 26

> What components in a computer system do we know how to make resilient, and
  what technique is used?

- **Memory:** Error-correcting code (ECC) memory detects and corrects single-bit
  errors.
- **Storage:** RAID (Redundant Array of Independent Disks) uses data replication
  and parity to protect against disk failures.
- **Network:** Redundant network paths and failover mechanisms ensure
  connectivity during link failures.

## Problem 27

> Which types of failures is easiest to detect?

Hardware failures are generally the easiest to detect, as failed components are
usually apparent before using software applications. For example, a computer
will not even boot if the power supply or memory modules fail.

## Problem 28

> Data resilience through forward error correcting codes is an example what type
  of recovery mechanism?

Forward error correction (FEC) is an example of proactive recovery mechanism.
It adds redundancy to data, allowing the receiver to detect and correct errors
without needing retransmission.

## Problem 29

> Data resilience through replication is an example what type of recovery
  mechanism?

Replication is an example of reactive recovery mechanism. In the event of a
failure, the system can switch to a replica to maintain availability and
integrity.

## Problem 30

> RAID (redundant array of inexpensive disks) is an example what type of
  recovery mechanism?

RAID is an example of reactive recovery mechanism. It uses data replication and
parity to protect against disk failures, allowing the system to recover data
from other disks in the array.

## Problem 31

> What is the technique called that allows applications to restart and recover
  from an intermediary point after the start of the application?

The technique is called checkpointing to restore state when a failure occurs.
Checkpointing periodically saves the last known good state to persistent
storage, allowing the application to resume from that point instead of starting
over.

## Problem 32

> Describe Moore's Law.

Moore's Law is the observation that the number of transistors on a microchip
doubles approximately every two years, leading to exponential growth in
computing power and a decrease in relative cost. This trend has driven
advancements in technology, but has slowed in recent years due to physics
constraints.

## Problem 33

> Describe Amdahl's Law.

Amdahl's Law states that the maximum speedup of a task using multiple processors
is limited by the serial portion of the task. The formula for possible speedup
is $\frac{1}{(1 - P) + \frac{P}{N}}$, where $P$ is the parallelizable portion of
the task and $N$ is the number of processors.

## Problem 34

> Today's commodity processors have 1 to 192 cores. About how many cores are
  expected to be in future processors by the end of the decade? How are these
  future processors going to look or be designed differently than today’s
  processors? What are the big challenges they need to overcome?

Looking at previous trends, we can see the growth of core counts in server
processors is $2^3$ every decade. If this trend continues, we can expect to see
a 512-core CPU by 2030. AMD has recently announced 256-core EPYC for 2026.

Year | Core count
--- | ---:
1990&ndash;2000 | 1
2000&ndash;2010 | 8
2010&ndash;2020 | 64
2020 | 192

## Problem 35

> Describe what a core and hardware thread is on a modern processor, and the
  difference between them? What type of workloads are hardware threads trying to
  improve performance for?

A core is often referred to as a physical processing unit within a CPU that can
execute instructions independently. Multi-threading allows a single core to
handle multiple threads concurrently, but no longer available in modern Intel
CPUs. They are designed for workloads with high levels of parallelism, such as
web servers and scientific simulations.

## Problem 36

> Describe what shared address space and message passing is, and the difference
  between them? In what environments would one be used over the other?

Shared address space is a communication model where multiple processes can
access the same memory locations directly. On the other hand, message passing is
a communication model where each process has its own private address space.
Shared address space is typically used in multi-threaded applications on a
single machine, while message passing is often used in distributed systems where
processes run on different machines.

## Problem 37

> Describe what a process and a thread is, and the difference between them? Why
  are synchronization locks needed with threads? Why is this not the case with
  processes?

A process is a running program with its own resources, while thread is a logical
execution unit within a process that shares the same resources. Synchronization
locks are not needed for processes because their resources are isolated, managed
by the OS. However, locking mechanisms are necessary for threads to prevent
accessing shared resources.

## Problem 38

> Define a cluster of computers. Define a supercomputer. What is the difference
  between clusters and supercomputers?

A cluster is a group of interconnected computers that work together as a single
system, typically using commodity hardware. A supercomputer is a
high-performance computing system using specialized hardware. They are serving
different purposes: clusters are designed for high availability, supercomputers
are optimized for performance.

## Problem 39

> Define grid computing. Define cloud computing. What is the difference between
  grids and clouds?

Grid computing is a distribution model across multiple geographical locations.
Cloud computing is a centralized model where access is provided on-demand over
the internet. Grids are often used for scientific research where resources are
shared among institutions, while clouds are used for commercial applications
where resources are provided as a service.

## Problem 40

> Briefly characterize the following three cloud computing models: IaaS, PaaS,
  Saas.

- **IaaS (Infrastructure as a Service):** Provides virtualized computing
  resources over the internet. Users can rent virtual machines, storage, and
  networking components.
- **PaaS (Platform as a Service):** Provides a platform for developers to build,
  deploy, and manage applications without worrying about the underlying
  infrastructure.
- **SaaS (Software as a Service):** Delivers software applications over the
  internet on a subscription basis. Users can access applications through web
  browsers without installing them locally.

## Problem 41

> List and describe main characteristics of cloud computing systems.

- **On-demand service:** Users can provision computing resources without human
  interaction.
- **Network access:** Resources are accessible over the internet and
  compatible with various devices.
- **Resource pooling:** Providers use multi-tenant models to serve multiple
  customers with shared resources.
- **Rapid elasticity:** Resources can be scaled up or down without migration.
- **Measured service:** Usage is monitored and billed based on consumption.

## Problem 42

> Discuss key enabling technologies in cloud computing systems.

- **Virtualization:** Allows multiple virtual machines to run on a single
  physical machine.
- **Distributed storage:** File systems and databases that store data across
  multiple nodes.
- **Automation and orchestration:** Tools for managing and deploying resources
  automatically.
- **Web services:** Frameworks for building consumable APIs over the internet.
- **Monitoring:** Tools to track and analyze resource usage.

## Problem 43

> Discuss different ways for cloud service providers to maximize their revenue.

- **Dynamic pricing:** Adjust prices based on demand and supply.
- **Tiered services:** Offer different service levels at varying price points.
- **Resource optimization:** Efficiently allocate resources to minimize costs.
- **Value-added services:** Provide additional services like security and backup
  for extra fees.

## Problem 44

> What are differences between multi-core CPU and GPU in architecture and
  usages?

| | CPU | GPU
--- | --- | ---
Architecture | Fewer but more powerful cores optimized for sequential processing. | Many smaller cores optimized for parallel processing.
Usages | General-purpose computing tasks, such as OS and user applications. | Specific tasks like graphically-intensive applications and parallel computations.

## Problem 45

> Discuss the major advantages and disadvantages using virtual machines and
  virtual clusters in cloud computing systems?

- **Advantages:**
  - **Isolation:** VMs provide strong isolation between different users and
    applications.
  - **Flexibility:** VMs can run different operating systems and software stacks.
  - **Resource utilization:** VMs allow for better resource allocation and
    utilization.
- **Disadvantages:**
  - **Overhead:** VMs introduce performance overhead due to virtualization.
  - **Complexity:** Managing VMs and virtual clusters can be more complex than
    managing physical machines.

## Problem 46

> Why power consumption is critical to datacenter operations?

Power consumption directly impacts operational costs, as electricity bills can
be a significant portion of a data center's expenses. Additionally, high power
consumption generates heat, requiring cooling systems that further increase
costs.

## Problem 47

> If you were to build a large $1B data center, which would require $50M/year in
  power costs to run the data center and $50M/year in power costs to cool the
  data center with traditional A/C and fans. Name 2 things that the data center
  designer could do to significantly reduce the cost of cooling the data center?
  Is there any way to reduce the cost of cooling to virtually $0? Explain why or
  why not?

1. **Free cooling:** Blow outside air into the data center when the external
   temperature is low enough, reducing the need for traditional cooling methods.
1. **Liquid cooling:** Cooling with liquids is more efficient than air cooling,
   which consumes more energy to spin fans.

Eliminating cooling costs entirely is only possible if the data center is
located in a cold region all year round. Natural energy sources like solar may
also work, but the generation is not consistent and not sufficient to power
large data centers.

## Problem 48

> Compare GPU and CPU chips in terms of their strength and weakness. In
  particular, discuss the tradeoffs between power efficiency, programmability
  and performance.

| | CPU | GPU
--- | --- | ---
Power efficiency | Less power efficient due to complex architecture. | More power efficient for parallel workloads.
Programmability | Easier to program with a wide range of languages and tools. | More complex programming model, often requiring specialized knowledge.
Performance | Better for single-threaded and low-latency tasks. | Excels in parallel processing and high-throughput tasks.

## Problem 49

> There are three implementations of the `MapReduce` engine and its extensions:
  Google MapReduce, Apache Hadoop and Apache Spark. What is unique about each
  system that sets them apart?

- **Google MapReduce:** The original implementation, designed for large-scale
  data processing on Google's infrastructure. It introduced the MapReduce
  programming model and is tightly integrated with Google Cloud Platform.
- **Apache Hadoop:** An open-source implementation of the MapReduce model,
  designed for distributed storage and processing of large datasets across
  clusters of commodity hardware. It includes the Hadoop Distributed File System
  (HDFS) for storage and YARN for resource management.

## Problem 50

> Briefly characterize the following branches of distributed systems: HPC, HTC,
  MTC, P2P, Grid, Cluster, Cloud, Supercomputing

- **HPC (High-Performance Computing):** Focuses on solving complex computational
  problems using powerful supercomputers and parallel processing techniques.
- **HTC (High-Throughput Computing):** Emphasizes maximizing the number of
  tasks completed over a long period, often using distributed computing
  resources.
- **MTC (Many-Task Computing):** Combines aspects of HPC and HTC, focusing on
  executing a large number of tasks with varying resource requirements.
- **P2P (Peer-to-Peer):** A decentralized network architecture where nodes
  share resources directly without relying on a central server.
- **Grid Computing:** Utilizes a distributed network of computers to share
  resources and solve large-scale problems collaboratively.
- **Cluster Computing:** Involves a group of interconnected computers working
  together as a single system, often using commodity hardware.
- **Cloud Computing:** Provides on-demand access to computing resources over
  the internet, allowing users to scale resources as needed.
- **Supercomputing:** Involves the use of extremely powerful computers to
  perform complex calculations and simulations at high speeds.

## Problem 51

> Assume that when a node fails, it takes 10s to diagnose the fault and another
  30s for the workload to be switched over>
>
> 1.  What is the availability of the cluster if planned downtime is ignored?

Availability is determined by unplanned downtime and the time it takes to
recover. The Mean Time To Repair (MTTR) is 40 seconds. If the cluster has 1000
nodes and the Mean Time Between Failure (MTBF) of each node is 100 hours, then
the availability rate is 99.989%.

$$
\begin{align}
  MTBF &= 100\ hours &= \mathbf{360,000s} \\
  MTTR &= 10s + 30s \\
  &= 40s &= \mathbf{0.0111h} \\
  A &= \frac{MTBF}{MTBF + MTTR} \\
  &= \frac{100}{100 + 0.0111} &\approx \mathbf{99.989\%}
\end{align}
$$

> 2.  What is the availability of the cluster if the cluster is taken down 1
      hour per week for maintenance, but one node at a time?

One hour every week amounts to 52 hours annually. Calculate unavailability rate
by dividing downtime $D$ by total time $T$ in a year. The availability rate is
99.969%.

$$
\begin{align}
  T &= 1,000 \cdot \left(7 \cdot 24\right) &= \mathbf{168,000h} \\
  D &= 1h \cdot 52 &= \mathbf{52h} \\
  U &= \frac{D}{T} \\
  &= \frac{52}{168,000} &\approx \mathbf{0.0003095} \\
  A &= 1 - U \\
  &= 1 - 0.0003095 &\approx \mathbf{99.969\%}
\end{align}
$$

## Problem 52

> Throughput can be used to measure processors, memory, disk, and networks. What
  are the basic units of measurement for each of these?

- **Processors:** Instructions per second (IPS) or Floating Point Operations
  Per Second (FLOPS).
- **Memory:** Megabytes per second (MB/s) or Gigabytes per second (GB/s).
- **Disk:** Megabytes per second (MB/s) or Input/Output Operations Per Second
  (IOPS).

## Problem 53

> Name two network technologies you would use in building a large scale
  computing system? One network should be used to optimize cost, while the other
  should be used to optimize performance. Give cost/performance details for each
  network type.

| | Ethernet | InfiniBand
--- | --- | ---
Cost | Lower cost, widely available and uses standard hardware. | Higher cost due to specialized hardware and infrastructure.
Performance | Speeds ranging from 1Gbps to 100Gbps. | Speeds up to 200Gbps with low latency.

## Problem 54

> Name two network topologies you would use in building a large scale computing
  system? One of these network topologies is destined to be used in most future
  supercomputers due to some desirable properties at large scale. What are these
  properties?

| | Fat Tree | Torus
--- | --- | ---
Scalability | Highly scalable, can accommodate a large number of nodes. | Scales well but may require more complex routing.
Fault tolerance | Provides multiple paths for data, improving fault tolerance. | Can handle node failures but may have limited alternative paths.

Because of its high scalability, Fat Tree topology is expected to be widely used
in future supercomputers.

## Problem 55

> What is live migration of virtual machines? Describe the steps needed to
  complete for live migration to occur. What type of workloads are not suitable
  for live migration?

Live migration is the process of moving a running virtual machine (VM) from one
physical host to another without downtime. It is performed by establishing a
connection between source and destination hosts, copying memory pages and
briefly pausing the VM to transfer the remaining state. Because of the high
memory write, live migration is not suitable for memory-bound workloads.

## Problem 56

> Name an open source cloud IaaS middleware system. What are common components
  across other IaaS middleware systems?

OpenStack is the most popular open-source cloud IaaS middleware system. Common
components include compute orchestration to provision VMs, block storage for
persistent data, object storage for unstructured data, networking and identity
management.

## Problem 57

> What is the difference between a NOSQL and SQL database? Give some examples of
  each.

| | SQL | NoSQL
--- | --- | ---
Structure | Relational, uses tables with rows and columns. | Non-relational, uses various data models like key-value, document, column-family, or graph.
Examples | <li>MySQL</li><li>PostgreSQL</li><li>SQLite</li> | <ul><li>MongoDB</li><li>Cassandra</li></ul>

## Problem 58

> What is an elastic block device (EBS) in Amazon’s infrastructure? Why is it a
  useful system?

An Elastic Block Store (EBS) is a scalable block storage service provided by
Amazon Web Services (AWS). It allows users to create and attach persistent
block storage volumes to their EC2 instances. EBS is useful because it provides
additional capacity for VMs and containers with limited local storage.

## Problem 59

> What does it mean for a system to be scalable?

A scalable system can handle increasing workloads by adding resources, such as
additional CPUs, memory or storage. Scalability can be achieved through vertical
scaling (adding resources to a single node) or horizontal scaling (adding more
nodes).

## Problem 60

> Under what conditions would live migration not work? Assume the VM is running
  off a network disk.

Live migration via network disk may not work if the connection between source
and destination cannot be established, or terminated during migration.
Additionally, migration may fail if the destination host lacks sufficient disk
space or memory to accommodate the VM.

## Problem 61

> What is 1 advantage of full virtualization compared to para-virtualization?

Full virtualization allows unmodified guest operating systems to run on the
hypervisor, providing better compatibility and performance. In contrast,
para-virtualization requires modifying the guest OS to work with the hypervisor,

## Problem 62

> Why do we not have processors running at 1THz today (as would have been
  predicted in 2000 based on prior growth patterns)?

Processors are not running at 1THz today due to physical limitations such as
transistor size and heat dissipation. It is increasingly difficult to shrink
current transistor sizes while maintaining Moore's Law.

## Problem 63

> What is an advantage of a modular data center shipping container resource over
  traditional racks with machines?

Modular data center shipping containers offer rapid deployment compared to
traditional racks. They can be pre-fabricated and shipped to the site, reducing
construction time and costs.

## Problem 64

> What technique is used to secure data in a storage system with the least
  performance penalty?

Data encryption is used to secure data in storage systems with minimal
performance penalty. It protects data using algorithms like AES, ensuring
integrity while having low overhead.

## Problem 65

> What technique is used to secure data in a computer system?

Access control mechanisms are used to secure data in a computer system. This
includes authentication, authorization, and auditing to ensure that only
authorized users can access or modify data.

## Problem 66

> What is the local loopback network interface?

The local loopback network interface is a virtual network interface that allows
a computer to communicate with itself. It is typically assigned the IP address
127.0.0.1 and is used for testing and network software development.

## Problem 67

> Describe the difference between strong scaling and weak scaling experiments.

Strong scaling measures how the solution time varies with the number of
processors for a fixed total problem size. Conversely, the problem per processor
in weak scaling remains constant as the number of processors and problem size
increase proportionally.

## Problem 68

> Why does Cloud Computing claim to offer infinite capacity? Why is it not the
  case for Supercomputing?

Cloud computing claims to offer infinite capacity because it can dynamically
allocate resources on-demand from a large pool of shared infrastructure. In
contrast, building supercomputers requires significant upfront investment in
hardware, limiting upgrade plans.

## Problem 69

> Assume you have virtual machines with 1-core, 10MB caches, 10GB memory, 100GB
  disk, and a 10Gb/sec network. Assume the 100GB disk resides on a network
  volume. Estimate the downtime the VM would have as it migrated from one
  physical machine to another. The downtime should measure from when the
  application on node 1 stops until it is running again on node 2. Measure
  downtime in milliseconds, and round to the nearest millisecond.

$$
\begin{align}
  \textsf{Memory transfer time} &= \frac{10\ GB}{10\ Gb/s} \\
  &= 8s &= \mathbf{8,000ms} \\
  \textsf{Disk transfer time} &= \frac{100\ GB}{10\ Gb/s} \\
  &= 80s &= \mathbf{80,000ms} \\
  \textsf{Total downtime} &=
    \textsf{Memory transfer time} + \textsf{Disk transfer time} \\
  &= 8,000ms + 80,000ms \\
  &= \mathbf{88,000ms}
\end{align}
$$

## Problem 70

> Assume that you have a private cloud that has 100 physical nodes which has a
  decentralized storage system to manage its VM images. Assume the storage
  system can sustain up to 10GB/sec I/O rates, and assume the 100 nodes running
  VMs are equipped with 10Gb/sec network interfaces. Assume that a single user
  wants to launch 100 VMs on the 100 physical machines. Assume that the cloud
  scheduler can initiate 10 VM launch requests per second. Assuming image sizes
  of 1GB each and that the OS takes 10 seconds to boot, estimate how long (in
  milliseconds; round to nearest millisecond) it would take for a single user to
  launch 100 VMs on the 100 nodes?

$$
\begin{align}
  \text{Scheduling time} &= \frac{100\ VMs}{10\ VMs/s} &= \mathbf{10s} \\
  \text{Image transfer time} &= \frac{100\ GB}{10\ GB/s} &= \mathbf{10s} \\
  \text{Boot time} &= 10s &= \mathbf{10s} \\
  \text{Total time} &=
    \text{Scheduling time} + \text{Image transfer time} + \text{Boot time} \\
  &= 10s + 10s + 10s &= \mathbf{30s} \\
  &= 30s \cdot 1,000ms/s &= \mathbf{30,000ms}
\end{align}
$$

## Problem 71

> If you have a system with 99.999% availability, how much downtime a year can
  you have (round to nearest second)?

At 99.999% availability, the system can have approximately 316 seconds of
downtime per year.

Availability | Downtime per year
---: | ---:
90% | 36.53d
99% | 3.65d
99.9% | 8.77h
99.99% | 52.6m
99.999% | 5.26m

## Problem 72

> Assume you have a cluster with 30 nodes. You have 1 network card per node with
  1Gb/sec Ethernet Full Duplex, and have access to 6-port switches (also 1Gb/sec
  Ethernet Full Duplex) in order to build a Fat Tree network architecture. Draw
  a picture of the Fat Tree topology for your 30-node cluster (clearly show the
  switches, cables, and nodes). How many switches in total do you need? What is
  the bi-section bandwidth of your network? What is the bi-section bandwidth of
  your network in Gb/sec (round to nearest Gb/sec)? Assuming each switch incurs
  a 100-microsecond forwarding delay, and networking stack requires
  40-microseconds to process network messages (e.g. TCP/IP) on each side (e.g.
  sender and receiver), what is the best-case and worst-case latency you can
  expect from this network topology?

To build a Fat Tree topology for a 30-node cluster using 6-port switches, we can
organize the nodes into pods. Each pod will contain two layers of switches: edge
switches and aggregation switches. Each edge switch connects to 5 nodes and one
aggregation switch. Each aggregation switch connects to multiple edge switches.

$$
\begin{align}
  \text{Number of edge switches} &=
    \frac{30\ \text{nodes}}{5\ \text{nodes/switch}} &= \mathbf{6\ switches} \\
  \text{Number of aggregation switches} &=
    \frac{6\ \text{edge switches}}{2\ \text{edge/switch}} &= \mathbf{3\ switches} \\
  \text{Total switches} &=
    \text{Number of edge switches} + \text{Number of aggregation switches} \\
  &= 6 + 3 &= \mathbf{9\ switches} \\
  \text{Bi-section bandwidth} &=
    \text{Number of links across bi-section} \times
    \text{Link bandwidth} \\
  &= 3\ \text{links} \times 1\ Gb/s &= \mathbf{3\ Gb/s} \\
  \text{Best-case latency} &=
    \text{Processing delay (sender + receiver)} + \text{Switch forwarding delay} \\
  &= (40\ \mu s + 40\ \mu s) + 100\ \mu s &= \mathbf{180\ \mu s} \\
  \text{Worst-case latency} &=
    \text{Processing delay (sender + receiver)} +
    2 \times \text{Switch forwarding delay} \\
  &= (40\ \mu s + 40\ \mu s) + 2 \times 100\ \mu s &= \mathbf{280\ \mu s}
\end{align}
$$

## Problem 73

> A MapReduce Job consists of many tasks that are distributed among TaskTrackers
  for execution. Sometimes, even when the machines and the tasks are identical,
  a few of the tasks will take much longer to complete than the others. But, a
  map or reduce stage cannot complete until its constituent tasks all complete.
  Describe a technique used by both Google’s MapReduce and Hadoop MapReduce to
  mitigate this problem. Explain why it is safe and effective.

When a task is taking significantly longer than expected, both Google MapReduce
and Hadoop MapReduce launch a duplicate instance of the task on another node.
This technique is known as speculative execution.

- **Safety:** No risk of data corruption or inconsistency occurs, as the system
  only accepts the result from the first task to complete and discards the
  duplicate.
- **Effectiveness:** Helps reduce overall job completion time by mitigating the
  impact of straggler tasks, which may be delayed due to hardware issues or
  resource contention.

## Problem 74

> While using the Amazon AWS or a similar cloud services, imagine running an
  application that could have access to a Hadoop Distributed File System (HDFS),
  an Elastic Block Service (EBS), Simple Storage Service (S3), and DynamoDB.
  Which of the four storage options would you expect to be the easiest for a
  traditional enterprise application to be modified to use, and why? Which would
  give the best throughput for large datasets (e.g. 1 petabyte)? How about for
  small object access (e.g. 1KB)?

- **Easiest to modify:** EBS has a block storage interface similar to
  traditional enterprise storage systems.
- **Best throughput for large datasets:** HDFS is optimized for high-throughput
  access to large datasets.
- **Best for small object access:** DynamoDB is designed for low-latency access
  to small objects.

## Problem 75

> In HW4, you had to generate hashes using a NONCE, organize the hashes, and
  ultimately sort them before storing them on disk. Write the pseudo code of
  your program implemented in your homework (make sure your psuedo code utilize
  multi-core architectures).

```cpp
function generate_and_sort_hashes(num_hashes, nonce_start):
  hashes = array of size num_hashes
  parallel_for i from 0 to num_hashes - 1:
    nonce = nonce_start + i
    hashes[i] = compute_hash(nonce)
  sorted_hashes = parallel_sort(hashes)
  write_to_disk(sorted_hashes)
```

## Problem 76

> Assuming you have a sorted dataset (as the one you generated in HW4), write
  the pseudo code to implement an efficient search routine. Discuss the time
  complexity of your search. Assuming you have a 16TB file, how much data will
  you have to read in order to find the specific hash you are searching for?
  Estimate the amount of time the search will take in milliseconds. Assume a
  spinning hard drive (HDD) that runs at 7200 RPM to compute the minimum latency
  of the HDD. Assume a SATA interface that allows a sustained read/write speed
  of 250MB/sec.

```cpp
function binary_search(sorted_hashes, target_hash):
  left = 0
  right = length(sorted_hashes) - 1
  while left <= right:
    mid = left + (right - left) / 2
    if sorted_hashes[mid] == target_hash:
      return mid
    else if sorted_hashes[mid] < target_hash:
      left = mid + 1
    else:
      right = mid - 1
  return -1
```

## Problem 77

> What was the bottleneck in your HW4 implementation? Was it the processor core
  counts, processor speed frequency, memory capacity, memory speed, disk
  capacity, or disk speed? If the bottleneck lies in multiple places, discuss
  all of them, and how you were able to determine where the bottleneck came
  from. What tools did you use to identify these bottlenecks? If you were a
  hardware designer, how would you design the hardware differently so that this
  bottleneck could be overcome.

The bottleneck in my HW4 implementation was primarily CPU, as seen in the
plotting diagram. Memory also played a role to a smaller extent, but only
towards the sorting phase.

<img
  width="480px"
  alt="Figure 2"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw5/figure2.png"/>

## Problem 78

> What is the difference between in-memory sort and external sort? What do you
  believe was the bottleneck in your implementation of external sort?

In-memory sort occurs when the entire dataset fits into the system's RAM,
allowing for fast sorting operations. External sort is used when the dataset
exceeds available memory, requiring data to be read from and written to disk
during the sorting process.

## Problem 79

> What are two most important properties of hashing algorithms.

1. **Determinism:** The same input will always produce the same hash output.
1. **Collision resistance:** It should be computationally infeasible to find two
   different inputs that produce the same hash output.

## Problem 80

> What are two most important properties of cryptographic hashing algorithms.

1. **Pre-image resistance:** Given a hash output, it should be computationally
   infeasible to find the original input.
1. **Avalanche effect:** A small change in the input should produce a
   significantly different hash output.

## Problem 81

> What is the difference between hashing algorithms and cryptographic hashing
  algorithms.

Hashing algorithms are designed for efficient data retrieval and storage,
focusing on generation speed. On the other hand, cryptographic hashing
algorithms prioritize security features such as collision resistance and
pre-image resistance, making them suitable for secure applications like digital
signatures and data integrity verification.

## Problem 82

> Write the pseudo code to a simple hashing algorithm.

```cpp
function simple_hash(input_string):
  hash_value = 0
  for each character in input_string:
    hash_value = (hash_value * 31 + ASCII(character)) mod TABLE_SIZE
  return hash_value
```

## Problem 83

> Write the pseudo code to a simple hash table implementation.

```cpp
class HashTable:
  function __init__(self, size):
    self.size = size
    self.table = array of size size initialized to None

  function hash_function(key):
    hash_value = 0
    for each character in key:
      hash_value = (hash_value * 31 + ASCII(character)) mod self.size
    return hash_value

  function insert(key, value):
    index = self.hash_function(key)
    while self.table[index] is not None:
      index = (index + 1) mod self.size
    self.table[index] = (key, value)

  function search(key):
    index = self.hash_function(key)
    while self.table[index] is not None:
      if self.table[index][0] == key:
        return self.table[index][1]
      index = (index + 1) mod self.size
    return None
```

## Problem 84

> Describe what OpenMP is, and what it could be used for.

OpenMP (Open Multi-Processing) is an API to parallelize code execution on
shared-memory architectures. It is known for being easy to use and available in
many compilers.

## Problem 85

> Describe what MPI is, and what it could be used for.

MPI (Message Passing Interface) is a standardized and portable message-passing
system designed to function on a wide variety of parallel computing
architectures. It is used for communication between processes in distributed
computing environments, allowing for efficient data exchange and coordination
among multiple nodes.

## Problem 86

> How is the namespace of a POSIX file system organized?

The namespace of a POSIX file system is organized as a hierarchical tree
structure. Root, denoted by `/`, is the top-level directory. Below the root are
directories and files, which can contain subdirectories and files recursively.

## Problem 87

> Describe the binning process of computer processors, and how a small core
  count CPU can be nearly identical to a large core count CPU.

During the manufacturing process, processors are tested for defects and
performance. Processors that pass all tests are classified into different bins
based on their core count and clock speed. A small core count CPU may be nearly
identical to a large core count CPU if the additional cores in the larger CPU
are defective or do not meet performance standards, leading to their
disabling.

## Problem 88

> Describe what the program SSH does in Linux. What is SSH Public Key
  Authentication?

SSH (Secure Shell) is a network protocol that provides secure remote access to
computers over an unsecured network. It encrypts the communication between the
client and server. Users generate an SSH key pair, exposing the public key to
the server while keeping the private key secure. The server uses the public key
to verify the user's identity during login.

## Problem 89

> Describe the work stealing load balancing technique in distributed scheduling.

Work stealing is a dynamic load balancing technique where idle processors
actively seek out and "steal" tasks from busy processors. Each processor
maintains its own task queue. When a processor becomes idle, it randomly selects
another processor and attempts to steal a task from its queue.

## Problem 90

> Describe how a mechanical hard drive works. How are bandwidth and latency
  fundamentally fixed by the hardware and technology used? For example, discuss
  the lowest possible latency achievable in a traditional hard drive at a given
  RPM of the platter.

A mechanical hard drive consists of spinning platters coated with magnetic
material and read/write heads that move across the platters to access data. The
bandwidth is determined by the data transfer rate of the drive, which is
influenced by factors such as platter speed and data density. A standard 7200
RPM hard drive has an average latency of approximately 4.17 milliseconds.

## Problem 91

> Libraries that generate random numbers typically require a SEED value to be
  passed in the initialization phase of the library. Can you explain why? What
  are good possible values for the SEED? Explain your answer.

The SEED value initializes the random number generator's internal state,
ensuring that the sequence of random numbers produced is reproducible. Good
possible values for the SEED include the current time or a combination of
system parameters, as they provide variability and unpredictability.

## Problem 92

> Explain what data locality is, and how it has helped MapReduce Hadoop to scale
  well on real world problems.

Data locality refers to the practice of processing data on the same node where
it is stored, minimizing data transfer over the network. In the context of
MapReduce and Hadoop, data locality helps to reduce network congestion and
improve performance by ensuring that tasks are executed close to the data they
need to access.

## Problem 93

> What limitations does Hadoop have that Spark has addressed? Discuss the
  workload patterns, and at a high level, how Spark has managed to address this
  shortcoming of Hadoop.

Hadoop's MapReduce model is limited in handling iterative algorithms and
interactive data analysis due to its reliance on disk I/O between each map and
reduce phase. Spark addresses these limitations by using in-memory computing,
allowing data to be cached in memory across multiple operations.

## Problem 94

> Describe what a time-series database is? How is this database different than a
  NoSQL database? How about how is it different than a relational database? Name
  2 examples of time-series databases.

A time-series database is optimized for storing and querying data points
indexed by time. It is different from NoSQL databases, which are designed for
flexible schema and scalability, and from relational databases, which use
structured tables and SQL queries. InfluxDB and TimescaleDB are two examples of
time-series databases.

## Problem 95

> If a manufacturer claims that their HDD can deliver sub-millisecond latency on
  average, can this be true? Justify your answer?

No, it is unlikely that a traditional HDD can deliver sub-millisecond latency
on average. The mechanical nature of HDDs, including seek time and rotational
latency, typically results in average latencies of several milliseconds.

## Problem 96

> Explain why flash memory SSD can deliver better performance for some
  applications than HDD.

Flash memory SSDs have no moving parts, so the transfer rate is not restricted
by mechanical movements. Additionally, flash memory has lower latency and higher
IOPS compared to HDDs.

## Problem 97

> What types of workloads benefit the most from SSD storage?

Workloads that require high random read/write performance, low latency, and
high IOPS benefit the most from SSD storage. For example, databases with
frequent CRUD operations and host OS with many guest VMs.

## Problem 98

> If a manufacturer claims they have built a storage system that can deliver 1
  Terabit/second of persistent storage per node, would you believe them? Justify
  your answer to why this is possible, or not. Make sure to use specific
  examples of types of hardware and expected performance.

Yes, it is possible to build a storage system that can deliver 1 Terabit/second
of persistent storage per node by using a combination of high-speed NVMe SSDs
and a high-performance network interface like 100GbE or InfiniBand. By
utilizing multiple NVMe drives in a RAID configuration and leveraging parallel
I/O operations, the system can achieve the desired throughput.

## Problem 99

> Name the top 10 commands you used in Linux when you implemented and evaluated
  your programming assignments in this class. Describe each command at a high
  level what it does. If there were alternatives to these commands, outline what
  these other commands were.

# | Command | Alternative |
---: | --- | ---
1 | `awk`: Pattern scanning and processing language. | `sed`: Stream-based text processing.
2 | `grep`: Search for patterns in files. | `ack`: Specialized for searching source code.
3 | `tmux`: Terminal multiplexer for OS without a desktop environment. | `screen`: Simpler to use.
4 | `nano`: Simple text editor in the terminal. | `vim`: Need to remember more key combinations.
5 | `wget`: Install software without a package manager. | `curl`: Has capabilities beyond downloading files.
6 | `git`: Clone personal repository in a fresh remote installation.
7 | `virt-manager`: Front-end for QEMU/KVM, a virtualization tool with a better. | `virsh`: Low-level access to libvirt.
8 | `lxc`: Container management tool with a better resources control. | `docker`: More community support.
9 | `vmstat`: Captures hardware resources statistics. | `iostat`: Focuses on disk I/O statistics.
10 | `gnuplot`: Save vmstat output as a diagram image. | `ttyplot`: Shows real-time statistics in terminal.

## Problem 100

> Explain what a blockchain is. Why is a blockchain system considered a
  distributed application? What are some of the largest challenges of operating
  blockchain systems (such as Bitcoin) at global scale?

A blockchain is a decentralized and distributed ledger that records transactions
across multiple nodes in a network. It is considered a distributed application
because it operates on a peer-to-peer network without a central authority,
ensuring transparency and immutability of data.
