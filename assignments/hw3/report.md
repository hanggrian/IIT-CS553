<!-- KaTeX -->
<script
  type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>

<style>
  .item-column {
    width: 240px;
  }
</style>

# [Homework 3](https://github.com/hanggrian/IIT-CS553/blob/assets/assignments/hw3.pdf): Report

> You are hired by a startup company who is considering to use cloud computing
  instead of building its own infrastructure. There is concensus that a cloud
  computing software stack at the layer of IaaS will be used, but its not clear
  whether the computing resources should be rented from a public cloud
  on-demand, or whether a private cloud should be purchased. You are tasked to
  find the cost breakdown of a private cloud, and compare that to what Amazon
  would charge. You can find many instance types defined at [AWS instance types](http://aws.amazon.com/ec2/instance-types/),
  and their prices are set at [AWS pricing](http://aws.amazon.com/ec2/pricing/).
  For pricing purposes, please stick to Linux on-demand pricing. There are a
  variety of Amazon caluclators such as [AWS calculator](https://calculator.aws/#/)
  and [AWS S3 calculator](https://calculator.aws/#/createCalculator/S3), please
  use them if you find them useful.
>
> Since you have to estimate the cost of the hardware when building a private
  cloud, you can use hardware prices found at [Thinkmate website](https://www.thinkmate.com)
  as good sources for server hardware (for configuration #1 and #3). For
  configuration #2, you will need to use the [Apple website](https://www.apple.com/mac-mini/).
  You must include a printout of your shoping cart in your final writeup report
  for this assignment; include this as an appendix at the end of your report.
>
> You are to estimate the cost of different configurations for 3 different set
  of requirements; compute prices for a 5-year period:

## Problem 1

> **Configuration 1:** Hadoop/Spark Cluster with 1M-cores, 2048TB memory,
  59.375PB HDD, and 50Gb/s Ethernet Fat-Tree network (each VM should be
  equivalent to the `c6id.metal` instance); in addition to the compute
  resources, a 100PB distributed storage shared across the entire cloud should
  be procured, with the expectation that 100PB of data will be read and written
  to S3 every year from outside of Amazon with enough capacity for 1GB/sec
  throughput (for pricing comparison, see S3 Standard). For EC2, you can use the
  lowest advertised price for this instance with up to a 5 year term commitment,
  if such pricing is available.

### On-premises

Since the vCPU requirement is massive, this server configuration will attempt to
reach the 1 million vCPU threshold before considering other components. The *AMD
EPYC 9965* has the highest core count, with 192 cores (384 vCPUs with SMT),
currently available on the market. In a 2U dual-processor rackmount server, this
results in 768 vCPUs per server.

<img
  width="640px"
  alt="Screenshot 1.1.1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot1_1_1.png">

The *Dell PowerEdge R7725* supports this CPU, but it may cost up to $100,000 per
server because the memory configuration needs to be maxed as well. *Supermicro
H14* also supports this CPU and is more affordable. However, the H14 can only be
configured with SSDs.

$$
\begin{align}
  \textsf{Compute servers} &=
    \lceil \textsf{vCPU requirement} \div \textsf{vCPU/server} \rceil \\\\
  &= \lceil 1,000,000 \div 768 \rceil \\\\
  &= \mathbf{1,303} \\\\
  \textsf{Compute memory/server (GB)} &=
    \lceil \textsf{Memory requirement} \div \textsf{Compute servers} \rceil \\\\
  &= \lceil 2,048,000 \div 1,303 \rceil \\\\
  &= \mathbf{1,572} \\\\
  \textsf{Compute disk/server (TB)} &=
    \lceil \textsf{Disk requirement} \div \textsf{Compute servers} \rceil \\\\
  &= \lceil 59,375 \div 1,303 \rceil \\\\
  &= \mathbf{46}
\end{align}
$$

<div class="item-column">Compute server</div> | Screenshot
--- | ---
<a href="https://www.supermicro.com/en/products/system/hyper/2u/as%20-2126hs-tn">Supermicro H14</a><ul><li>2 &times; AMD EPYC 9965 (768 vCPU)</li><li>20 &times; 96GB DDR5 5,600MHz (1,920GB)</li><li>14 &times; 3.8TB SSD 2.5" (53.2TB)</li><li>2 &times; Supermicro 1U (2000W)</li><li>Supermicro MCX623106AN (100GbE)</li></ul> | <img width="100%" alt="Screenshot 1.1.2" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot1_1_2.png">

For the storage servers, the *Broadberry CyberStore Xeon SP2-490-G3* can fit
90 of 24TB drives in a 4U rackmount chassis (2.16PB). The final number of
storage servers is doubled to account for RAID 1 mirroring. Notably, the
configuration does not include a RAID controller card because software RAID,
such as ZFS, is preferred.

$$
\begin{align}
  \textsf{Storage servers} &=
    \lceil \textsf{Storage requirement} \div \textsf{Storage/server} \rceil
    \cdot \textsf{RAID mirroring} \\\\
  &= \lceil 100,000 \div 2,160 \rceil \cdot 2 \\\\
  &= 47 \cdot 2 \\\\
  &= \mathbf{94}
\end{align}
$$

<div class="item-column">Storage server</div> | Screenshot
--- | ---
<a href="https://www.broadberry.com/storage-storage-servers/xeon-sp2-490-g3">Broadberry CyberStore Xeon SP2-490-G3</a><ul><li>2 &times; Intel Xeon Silver 4310 (24 vCPU)</li><li>4 &times; 8GB DDR4 3,200MHz (1,920GB)</li><li>24 &times; 24TB HDD 3.5" (2,160TB)</li><li>Unbranded PSU (2600W)</li><li>Broadcom NetExtreme P2100G (100GbE)</li></ul> | <img width="100%" alt="Screenshot 1.1.3" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot1_1_3.png">

Each rack cabinet contains a 1U network switch at the top, followed by as many
rackmount servers as possible. There should be no or minimal empty space left
for each rack. Using this approach, 48U is selected for the compute servers and
42U for the storage servers. Both racks are left with 1U empty space.

$$
\begin{align}
  \textsf{48U racks} &=
    \lceil \textsf{Compute servers} \div
    \lfloor (48U - 1U) / 2U \rfloor \rceil \\\\
  &= \lceil 1,303 \div 23 \rceil \\\\
  &= \mathbf{57} \\\\
  \textsf{42U racks} &=
    \lceil \textsf{Storage servers} \div
    \lfloor (42U - 1U) / 4U \rfloor \rceil \\\\
  &= \lceil 94 \div 10 \rceil \\\\
  &= \mathbf{10}
\end{align}
$$

<div class="item-column">Racks</div> | Screenshot
--- | ---
<a href="https://www.racksolutions.com/server-racks/rack-enclosures/rs148-data-center-enclosed-server-cabinet.html">RackSolutions RS148</a><ul><li>48U</li><li>30 &times; 48in</li></ul> <a href="https://www.racksolutions.com/server-racks/rack-enclosures/rack-mount-enclosure.html">RackSolutions RACK-151</a><ul><li>42U</li><li>600 &times; 1,000mm</li></ul> | <img width="100%" alt="Screenshot 1.1.4" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot1_1_4.png">

The network switch is required to have at least 50GbE speed and a Fat-Tree
topology. In addition, the number of available ports should not be less than the
number of installed servers in a rack. The *FS N8550-24CD8D* satisfies both
requirements.

$$
\begin{align}
  \textsf{Switches} &= \textsf{48U racks} + \textsf{42U racks} \\\\
  &= 57 + 10 \\\\
  &= \mathbf{67}
\end{align}
$$

<div class="item-column">Network switch</div> | Screenshot
--- | ---
<a href="https://www.fs.com/products/110480.html">FS N8550-24CD8D</a><ul><li>QSFP56</li><li>32 &times; 100GbE</li></ul> | <img width="100%" alt="Screenshot 1.1.5" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot1_1_5.png">

The network cable must be long enough to connect the switch at the top of the
rack to the last server at the bottom in the tallest rack, which is the 48U
enclosure. 3 meters, or approximately 10 feet, should be sufficient. However, in
practice, it is probably a bad idea to use a single length for all cables.

$$
\begin{align}
  \textsf{Cables} &= \textsf{Compute servers} + \textsf{Storage servers} \\\\
  &= 1,303 + 94 \\\\
  &= \mathbf{1,397}
\end{align}
$$

<div class="item-column">Network cable</div> | Screenshot
--- | ---
<a href="https://www.fs.com/products/106082.html">10ft Cisco Q56-200-CU3M</a><ul><li>QSFP56</li><li>200GbE</li></ul> | <img width="100%" alt="Screenshot 1.1.6" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot1_1_6.png">

Uses liquid cooling solution for sustained workloads. While there are competent
air cooling options in the market, like *SilverStone XE04-SP5,* they are capped
at 400W TDP. Dynatron coolers can accommodate the compute server's 500W TDP
requirement.

<div class="item-column">Cooling</div> | Screenshot
--- | ---
<a href="https://mitxpc.com/products/tl37">Dynatron TL37</a><ul><li>Socket SP5</li><li>700W</li></ul> <a href="https://mitxpc.com/products/l30">Dynatron TL30</a><ul><li>LGA 4189</li><li>270W</li></ul> | <img width="100%" alt="Screenshot 1.1.7" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot1_1_7.png">

Calculating the electricity cost is quite tricky because it depends on the
correctness of many assumptions. The first assumption is that all servers are
running at 60% load 24/7. The report also uses a common Power Usage
Effectiveness ratio and assumes a median electricity cost of a data center in
the U.S.

$$
\begin{align}
  \textsf{Electricity (kW)} &=
    (\textsf{Compute servers} \cdot \textsf{PSU/server} + \\\\
  &\quad \textsf{Storage servers} \cdot \textsf{PSU/server} + \\\\
  &\quad \textsf{Switches} \cdot \textsf{PSU/switch})
    \cdot \textsf{Load percentage} \cdot \textsf{PUE ratio} \\\\
  &= (1,303 \cdot 2 \cdot 2 + 94 \cdot 2.6 + 67 \cdot 0.7)
    \cdot 60\\% \cdot 1.5 \\\\
  &= (5,212 + 244.4 + 46.9) \cdot 90\\% \\\\
  &= 5503.3 \cdot 90\\% \\\\
  &= \mathbf{4952.97} \\\\
  \textsf{5-year electricity (kWh)} &=
    (\textsf{Electricity} \cdot 24 \cdot 365) \cdot 5 \\\\
  &= (4952.97 \cdot 24 \cdot 365) \cdot 5 \\\\
  &= 43,388,017.2 \cdot 5 \\\\
  &= \mathbf{216,940,086}
\end{align}
$$

<div class="item-column">Electricity power</div> | Screenshot
--- | ---
<a href="https://massedcompute.com/faq-answers/?question=What%20are%20the%20average%20electricity%20costs%20for%20data%20centers%20in%20different%20regions%20and%20how%20do%20they%20impact%20total%20costs?">Average electricity costs by region</a><ul><li>U.S. median ($0.1)</li></ul> | <img width="100%" alt="Screenshot 1.1.8" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot1_1_8.png">

In this report, an administrator can manage 500 nodes with proper alerting
tools. The report also assumes that the workload of compute servers is
comparable to that of storage servers.

$$
\begin{align}
  \textsf{Administration (people)} &=
    \lceil (\textsf{Compute servers} + \textsf{Storage servers}) \div
    500 \rceil \\\\
  &= \lceil (1,303 + 94) \div 500 \rceil \\\\
  &= \lceil 1,397 \div 500 \rceil \\\\
  &= \mathbf{3} \\\\
  \textsf{5-year administration (hr)} &=
    (\textsf{Administration} \cdot 8 \cdot 250) \cdot 5 \\\\
  &= (3 \cdot 8 \cdot 250) \cdot 5 \\\\
  &= 6,000 \cdot 5 \\\\
  &= \mathbf{30,000}
\end{align}
$$

<div class="item-column">Administration</div> | Screenshot
--- | ---
<a href="https://www.bls.gov/ooh/computer-and-information-technology/network-and-computer-systems-administrators.htm">Network and Computer Systems Administrators</a><ul><li>$96,800 per year</li><li>$46.54 per hour</li></ul> | <img width="100%" alt="Screenshot 1.1.9" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot1_1_9.png">

| | Description | Qty | Price @item | Total price
--- | --- | ---: | ---: | ---:
Compute servers | Maximized CPU configuration | 1,303 | $39,362 | $51,288,686
Network switches | Top-of-Rack switch | 67 | $12,400 | $830,800
Network cables | 10ft length | 1,397 | $159 | $222,123
Racks | Enclosed cabinet | 57<br>10 | $2,250<br>$1,125 | $128,250<br>$11,250
Storage servers | Maximized storage configuration | 94 | $71,880 | $6,756,720
Electric power | Estimate of sustained operation | 216,940,086 | $0.1 | $21,694,008
Cooling | Aftermarket liquid coolers | 1,303<br>94 | $159<br>$104 | $207,177<br>$9,776
Administration | Monitoring and automation | 30,000 | $46 | $1,380,000
**Total** | | | | **$82,528,790**

### Cloud

The `c6id.metal` instance is the highest performing instance in the C6i family.
With 2,048TB memory requirement, 8,000 instances are needed to satisfy the
memory requirement alone. The rest of the requirements are also satisfied with
8,000 instances.

$$
\begin{align}
  \textsf{EC2 instances} &=
    \max(
      \lceil \textsf{vCPU requirement} \div \textsf{vCPU/instance} \rceil, \\\\
  &\quad \lceil \textsf{Memory requirement} \div \textsf{Memory/instance} \rceil, \\\\
  &\quad \lceil \textsf{Storage requirement} \div \textsf{Storage/instance} \rceil) \\\\
  &= \max(
      \lceil 1,000,000 \div 128 \rceil, \\\\
  &\quad \lceil 2,048,000 \div 256 \rceil, \\\\
  &\quad \lceil 59,375 \div 7.6 \rceil) \\\\
  &= \max(7,813,\quad 8,000,\quad 7,812) \\\\
  &= \mathbf{8,000} \\\\
  \textsf{5-year EC2 instance years (yr)} &= \textsf{EC2 instances} \cdot 5 \\\\
  &= 8,000 \cdot 5 \\\\
  &= \mathbf{40,000}
\end{align}
$$

<div class="item-column">AWS EC2</div> | Screenshot
--- | ---
<a href="https://instances.vantage.sh/aws/ec2/c6id.metal">c6id.metal pricing</a><ul><li>128 vCPU</li><li>256GB memory</li><li>4 &times; 1.9TB NVMe (7.6TB)</li><li>50GbE network</li></ul> | <img width="100%" alt="Screenshot 1.2.1" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot1_2_1.png">

Calculating the S3 cost is straightforward using the official AWS pricing
calculator. Given the 100PB required capacity, or 100,000TB, the monthly read
and write rate is 8,333TB. The final cost is multiplied by 5 years.

<div class="item-column">AWS S3</div> | Screenshot
--- | ---
<a href="https://calculator.aws/#/createCalculator/S3">S3 calculator</a><ul><li>100PB read & write</li></ul> | <img width="100%" alt="Screenshot 1.2.2" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot1_2_2.png">

| | Description | Qty | Price @item | Total price
--- | --- | ---: | ---: | ---:
Compute servers | 3-year and 1-year reserved pricing | 24,000<br>16,000 | $23,614<br>$35,614 | $566,736,000<br>$569,824,000
Storage servers | Flat rate | 5 | $2,433,541 | $12,167,705
**Total** | | | | **$1,148,727,705**

## Problem 2

> **Configuration 2:** Support 1K application developers who are designing MacOS
  and iPad OS applications. They require a MacOS system with 14-cores, 48GB RAM,
  1TB storage, and 10Gb/s network (Amazon has `mac-m4pro.metal` instances that
  have everything you need except the 1TB storage, which you can provision
  through EBS). The developers work 40 hours/week, 48 weeks/year (they get 4
  weeks of vacation per year). You must use on-demand EC2 pricing as developers
  are expected to provision their systems at the beginning of each working day,
  and release their systems at the end of each working day.

### On-premises

The specifications requirement can be satisfied with either the base model of
*Mac Pro 2023*, an upgraded *Mac Studio 2025* or a fully maxed *Mac Mini 2024*.
The Mac Pro is not considered cost-effective, considering that it has an older
M2 chip and is significantly more expensive than the other two options. On the
other hand, the Mac Mini has the lowest TDP and may not be sufficient for heavy
workloads. The Mac Studio is currently the most balanced option until the Mac
Pro is refreshed.

<div class="item-column">Server</div> | Screenshot
--- | ---
<a href="https://www.apple.com/shop/buy-mac/mac-studio/apple-m3-ultra-with-28-core-cpu-60-core-gpu-32-core-neural-engine-96gb-memory-1tb">Mac Studio</a><ul><li>Apple M3 Ultra (28 vCPU)</li><li>96GB memory</li><li>1TB SSD</li></ul> | <img width="100%" alt="Screenshot 2.1.1" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot2_1_1.png">

RackSolutions has an interesting solution for mounting six Mac Studios in a 5U
rackmount chassis. In turn, eight such chassis can fit in a 42U rack, leaving
some space for a network switch. The 42U rack is the same model used in Problem
1.

$$
\begin{align}
  \textsf{Rack mounts} &= \lceil \textsf{Servers} \div \textsf{6} \rceil \\\\
  &= \lceil 1,000 \div 6 \rceil \\\\
  &= \mathbf{167} \\\\
  \textsf{42U racks} &=
    \lceil \textsf{Rack mounts} \div
    \lfloor (42U - 1U) / 5U \rfloor \rceil \\\\
  &= \lceil 167 \div 8 \rceil \\\\
  &= \mathbf{21}
\end{align}
$$

<div class="item-column">Rack mount</div> | Screenshot
--- | ---
<a href="https://www.racksolutions.com/hypershelf-apple-mac-studio-sliding-shelf.html">RackSolutions 5U HyperShelf</a><ul><li>6 Apple Mac Studio</li></ul> | <img width="100%" alt="Screenshot 2.1.2" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot2_1_2.png">

Since modern Macs are not upgradable, the cooling solution is limited to
external air cooling. One industrial fan is equipped for each rack mount.

<div class="item-column">Cooling</div> | Screenshot
--- | ---
<a href="https://www.racksolutions.com/hypershelf-apple-mac-studio-sliding-shelf.html">RackSolutions NEMA 1-15P Fan Upgrade Kit</a><ul><li>RackSolutions HyperShelves</li></ul> | <img width="100%" alt="Screenshot 2.1.3" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot2_1_3.png">

With six servers in each mount, one rack can have up to 48 servers. This means
that each rack requires a network switch with at least 48 ports.

<div class="item-column">Network switch</div> | Screenshot
--- | ---
<a href="https://www.fs.com/products/201303.html">IES5120-48T4S</a><ul><li>RJ45</li><li>40 &times; 10GbE</li></ul> | <img width="100%" alt="Screenshot 2.1.4" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot2_1_4.png">

It is estimated that 10ft cables are sufficient for a 48U rack in Problem 1.
Based on the same, perhaps flawed logic, 7ft cables should be sufficient for a
42U rack.

<div class="item-column">Network cable</div> | Screenshot
--- | ---
<a href="https://www.fs.com/products/148300.html">7ft Cat6a 26AWG Snagless Shielded</a><ul><li>RJ45</li><li>10GbE</li></ul> | <img width="100%" alt="Screenshot 2.1.5" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot2_1_5.png">

I received conflicting information where [a technical specification page](https://www.apple.com/mac-studio/specs/)
lists the Mac Studio's power consumption as 480W, while [a support page](https://support.apple.com/en-us/102027)
states that the TDP is 270W. This report uses the higher bound to be safe. The
network switch's power consumption is listed as 44W in its datasheet.

$$
\begin{align}
  \textsf{Electricity (kW)} &=
    (\textsf{Servers} \cdot \textsf{PSU/server} + \\\\
  &\quad\textsf{Switches} \cdot \textsf{PSU/switch})
    \cdot \textsf{Load percentage} \cdot \textsf{PUE ratio} \\\\
  &= (1,000 \cdot 0.48 + 21 \cdot 0.05) \cdot 60\\% \cdot 1.5 \\\\
  &= (480 + 1.05) \cdot 60\\% \cdot 1.5 \\\\
  &= 481.05 \cdot 90\\% \\\\
  &= \mathbf{432.94} \\\\
  \textsf{5-year electricity (kWh)} &=
    (\textsf{Electricity} \cdot 24 \cdot 365) \cdot 5 \\\\
  &= (432.94 \cdot 24 \cdot 365) \cdot 5 \\\\
  &= 3,792,554.4 \cdot 5 \\\\
  &= \mathbf{18,962,772}
\end{align}
$$

Still using the assumption that one administrator can manage 500 nodes.

$$
\begin{align}
  \textsf{Administration (people)} &=
    \lceil \textsf{Servers} \div 500 \rceil \\\\
  &= \lceil 1,000 \div 500 \rceil \\\\
  &= \mathbf{2} \\\\
  \textsf{5-year administration (hr)} &=
    (\textsf{Administration} \cdot 8 \cdot 250) \cdot 5 \\\\
  &= (2 \cdot 8 \cdot 250) \cdot 5 \\\\
  &= 4,000 \cdot 5 \\\\
  &= \mathbf{20,000}
\end{align}
$$

| | Description | Qty | Price @item | Total price
--- | --- | ---: | ---: | ---:
Servers | Upgraded Mac Studio | 1,000 | $3,999 | $3,999,000
Network switches | Top-of-Rack switch | 21 | $1,169 | $24,549
Network cables | 7ft length | 1,000 | $5 | $5,000
Rack mounts | Container of computers | 167 | $649 | $108,383
Racks | Container of containers | 21 | $1,125 | $23,625
Electric power | Estimate of sustained operation | 18,962,772 | $0.1 | $1,896,277
Cooling | Fitted to rack mounts | 167 | $79 | $13,193
Administration | Monitoring and automation | 20,000 | $46 | $920,000
**Total** | | | | **$6,990,027**

### Cloud

The `mac-m4pro.metal` instance has 14 vCPU, 48GB memory and 10GbE network.
According to [the AWS blog](https://aws.amazon.com/blogs/aws/announcing-amazon-ec2-m4-and-m4-pro-mac-instances/),
the instance has 1.9TB of NVMe storage. However, for this report, the storage is
handled through Elastic Block Storage.

$$
\begin{align}
  \textsf{5-year EC2 instance years (yr)} &= \textsf{EC2 instances} \cdot 5 \\\\
  &= 1,000 \cdot 5 \\\\
  &= \mathbf{5,000}
\end{align}
$$

<div class="item-column">AWS EC2</div> | Screenshot
--- | ---
<a href="https://instances.vantage.sh/aws/ec2/mac-m4pro.metal">mac-m4pro.metal pricing</a><ul><li>14 vCPU</li><li>48GB memory</li><li>10GbE network</li></ul> | <img width="100%" alt="Screenshot 2.2.1" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot2_2_1.png">

There are 1,000 volumes of 1TB each in the EBS calculation. The volumes are
provisioned for 160 hours per month, which is approximately 40 hours per week in
48 weeks. Once every day, a snapshot of the size of the volume is created.

<div class="item-column">AWS EBS</div> | Screenshot
--- | ---
<a href="https://calculator.aws/#/createCalculator/EBS">EBS calculator</a><ul><li>1.000 volumes</li><li>1TB per volume</li><li>160 hr per month</li><li>Daily snapshot</li></ul> | <img width="100%" alt="Screenshot 2.2.2" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot2_2_2.png">

| | Description | Qty | Price @item | Total price
--- | --- | ---: | ---: | ---:
Compute servers | On-demand pricing | 1,000 | $17,257 | $17,257,000
Storage servers | Flat rate | 5 | $2,367,144 | $11,835,720
**Total** | | | | **$29,092,720**

## Problem 3

> **Configuration 3:** Monero (XMR) crypto currency mining; you have an investor
  who has $10M to buy hardware to mine Monero Coin XMR (and pay for maintance /
  sys admin, power, and cooling), or rent resources from Amazon EC2 to mine XMR
  Coin. Configure the best hardware you can from ThinkMate. For buying hardware
  solution, make sure to leave funds to pay for power, cooling, and system
  administrator. XMR Coin mining can be done on any compute hardware (CPUs or
  GPUs), but you will likely find that its most profitable to mine using CPUs.
  Since XMR mining is compute intensive, your processor will likely require to
  have as many cores as possible; if GPU mining is used, you might be able to
  lower the processing and memory requirements to a minimm on the host machine.
  Identify the best Amazon instance (you must use Spot Instances to make sure
  you get the best hardware for the cheapest price); although spot pricing
  fluctuates over time, you can assume the spot price will remain fixed for the
  duration of your evaluation.
>
> For the purchase of the hardware scenario, you are free to locate the hardware
  in any state in the USA (for a full list of average electricity cost by state,
  see [electricity rates by state](https://www.chooseenergy.com/electricity-rates-by-state/));
  since this will be a business venture, use the business electricity rates. If
  electricity is too expensive to make a profit, invest part of the $1M in solar
  power (solar panels), and estimate the amount of energy you can extract. For
  an overview of various CPUs and their respective hashrates (the higher the
  hashrates, the more XMR Coin that can be mined), see [XMR benchmarks](https://hashrate.no/coins/XMR/benchmarks).
  Once you have a hashrate, you can estimate how much money can be made mining
  XMR by using an online calculator such as [XMR](https://minerstat.com/coin/XMR).
  The mining calculator gives an instantanous mining number, although in reality
  the amount of coin that can be mined would vary based on many factors (hash
  rate, hash difficulty, fees, etc). The profit similarly can vary based on the
  XMR Coin pricing, which can vary wildly. When computing the mining coins and
  expected profit, you can use the calculator above to compute it for a 5-year
  period, assuming the mining continues at the same rate, and the price remains
  at the same level. Your task is to compute the amount of profit that is
  expected after $10M is invested in buying hardware and running it for 5-years,
  vs. renting the hardware from Amazon. Its possible that the profits you make
  will be less than the original investment (especially with the Amazon
  scenario).

### On-premises

In this problem, the majority of the 10M budget is distributed to the GPU with
the highest hashrate to TDP ratio and a reasonable price. However, all consumer
GPUs fail to reach daily profitability, considering the high electricity cost in
the U.S. Because of this constraint, the business invests in *Antminer X5,* a
dedicated mining rig with a reported $2 daily profit.

<img
  width="640px"
  alt="Screenshot 3.1.1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot3_1_1.png">

The configuration is targeting 3,000 mining rigs to maximize profitability,
leaving large portion of the budget for recurring costs.

<div class="item-column">Server</div> | Screenshot
--- | ---
<a href="https://shop.bitmain.com/product/detail?pid=00020231023114009392Wa6C3QuD0658">Antminer X5</a><ul><li>212,000 hashrate</li><li>1,350W</li></ul> | <img width="100%" alt="Screenshot 3.1.2" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot3_1_2.png">

The selected rack is an open frame model because the Antminer X5 is not a
rackmount device. The open frame rack also allows better airflow for cooling.
The height of the 48U rack is 84in. It could accommodate at least 10 mining rigs
stacked vertically (7.6in each), leaving some space for a network switch.

$$
\begin{align}
  \textsf{48U racks} &= \lceil \textsf{Servers} \div \textsf{10} \rceil \\\\
  &= \lceil 3,000 \div 10 \rceil \\\\
  &= \mathbf{300}
\end{align}
$$

<div class="item-column">Racks</div> | Screenshot
--- | ---
<a href="https://www.racksolutions.com/server-racks/data-center-openframe-rack.html">RackSolutions 151DC</a><ul><li>48U</li><li>24 &times; 48in</li></ul> | <img width="100%" alt="Screenshot 3.1.3" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot3_1_3.png">

The Antminer X5 supports up to 1GbE network speed. With only 10 required ports,
the selected network switch is an unbranded and unmanaged model.

<div class="item-column">Network switch</div> | Screenshot
--- | ---
<a href="https://www.fs.com/products/166642.html">S3270-10TM-P</a><ul><li>RJ45</li><li>10 &times; 1GbE</li></ul> | <img width="100%" alt="Screenshot 3.1.4" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot3_1_4.png">

Drawing example from Problem 1, 10ft cables should be sufficient for a 48U rack.

<div class="item-column">Network cable</div> | Screenshot
--- | ---
<a href="https://www.fs.com/products/71913.html">10ft Cat6a 28AWG Snagless Unshielded</a><ul><li>RJ45</li><li>1GbE</li></ul> | <img width="100%" alt="Screenshot 3.1.5" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot3_1_5.png">

The cooling solution is included with the purchase of the mining rig. The
administration cost is not calculated because the mining rigs are considered
low-maintenance. This leaves electricity as the only recurring cost, which is
already calculated using [Monero Mining Calculator](https://www.coinwarz.com/mining/monero/calculator).

| | Description | Price @item | Qty | Total price
--- | --- | ---: | ---: | ---:
Servers | Dedicated mining rig | 3,000 | $2,999 | $8,997,000
Network switches | Top-of-Rack switch | 300 | $319 | $95,700
Network cables | 10ft length | 3,000 | $5.8 | $17,400
Racks | Open frame rack | 300 | $1,249 | $374,700
**Total** | | | | **$9,484,800**

Over a 5-year period, if the XMR price remains constant, the service is expected
to generate approximately $1.5M revenue.

$$
\begin{align}
  \textsf{5-year mining profit} &=
    (\textsf{Servers} \cdot \textsf{Daily profit} \cdot 365) \cdot 5 - \textsf{Total cost} \\\\
  &= (3,000 \cdot 2 \cdot 365) \cdot 5 - 9,484,800 \\\\
  &= 2,190,000 \cdot 5 - 9,484,800 \\\\
  &= 10,950,000 - 9,484,800 \\\\
  &= \mathbf{1,465,200}
\end{align}
$$

### Cloud

For a 10M budget, 25 instances can be rented over a 5-year period.

$$
\begin{align}
  \textsf{EC2 instances (annual)} &=
    \lfloor \textsf{Budget} \div \textsf{Instance price} \div 5 \rfloor \\\\
  &= \lfloor 10,000,000 \div 77,598 \div 5 \rfloor \\\\
  &= \mathbf{25}
\end{align}
$$

<div class="item-column">AWS EC2</div> | Screenshot
--- | ---
<a href="https://instances.vantage.sh/aws/ec2/c6a.metal">c6a.metal pricing</a><ul><li>192 vCPU</li><li>384GB memory</li><li>50GbE network</li></ul> | <img width="100%" alt="Screenshot 3.2" src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw3/screenshot3_2.png">

| | Description | Qty | Price @item | Total price
--- | --- | ---: | ---: | ---:
Servers | 3-year pricing | 125 | $77,598 | $9,699,750
**Total** | | | | **$9,699,750**

Having 192 core count, one could assume that `c6a.metal` is equipped with AMD
EPYC 9965 processors. In a user-submitted benchmark [website](https://xmrig.com/benchmark?cpu=AMD+EPYC+9965+192-Core+Processor),
this processor scores 224,774 hashrate, or approximately 0.015 XMR daily.

$$
\begin{align}
  \textsf{Daily revenue (\\\$)} &= \textsf{XMR mined} \cdot \textsf{XMR price} \\\\
  &= 0.015 \cdot 287 \\\\
  &= \mathbf{4.3} \\\\
  \textsf{5-year mining profit (\\\$)} &=
    (\textsf{EC2 instances} \cdot \textsf{Daily revenue} \cdot 365) \cdot 5 - \textsf{Total cost} \\\\
  &= (25 \cdot 4.3 \cdot 365) \cdot 5 - 9,699,750 \\\\
  &= 39,237.5 \cdot 5 - 9,699,750 \\\\
  &= 196,187.5 - 9,699,750 \\\\
  &= \mathbf{-9,503,562.5}
\end{align}
$$

## Problem 4

> Compare the costs of the 3 different configurations between the public cloud
  (Amazon AWS) and the private cloud.

It is easy to see that on-premises solutions are significantly cheaper than
cloud providers in all configurations. However, I personally did not expect the
gap to be this wide (over 100x in Configuration 1). One takeaway from this
study is that, when an application is growing on public cloud, it is better to
migrate to on-premises rather than scaling up on the cloud.

| | Configuration 1 | Configuration 2
--- | ---: | ---:
On-premises cost over 5 years | $82,528,790 | $6,990,027
Cloud cost over 5 years | $1,148,727,705 | $29,092,720

It is not profitable to mine XMR on the public cloud at all. When running
dedicated mining rigs, one can expect to make 15% profit over 5 years with a 10M
budget. Having already invested in the hardware, the business can continue
reaping profit for another 5 years.

| | Configuration 3
--- | ---:
On-premises mining profit over 5 years | $1,465,200
Cloud mining profit over 5 years | -9,503,562.5
