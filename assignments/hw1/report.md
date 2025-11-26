# [Homework 1](https://github.com/hanggrian/IIT-CS553/blob/assets/assignments/hw1.pdf): Report

> This project aims to teach you the basics of Linux and Virtual Machines, as
  well as some basic Q&A about computer systems. Any programming you do in this
  assignment will be limited to BASH scripting and/or Python. You can use any
  computer for this part of the assignment (e.g. your laptop running any OS).
>
> Here is your assignment. Collect evidence of your work through screen shots
  and log files. You will write a report at the end that outlines what you have
  done to complete this assignment.

## Problem 1

> Setup VM, Linux, and basic testing &mdash; must take screen shots at each step
  to receive points
>
> 1.  Read [Oracle VirtualBox White Paper](https://www.oracle.com/a/ocom/docs/dc/em/oracle-vm-virtualbox-overview-2981353.pdf)
> 1.  Download [Oracle VirtualBox 7.1.4](https://www.virtualbox.org/wiki/Downloads)
> 1.  Install VirtualBox
> 1.  Download [Ubuntu Server 24.04.1 LTS](https://ubuntu.com/download/server)
      ISO image &mdash; no need to install the Desktop version
> 1.  Create Virtual Machine (VM), to support Linux, Ubuntu, 64- bit, 4GB RAM,
      Virtual Disk 25GB, VDI image, dynamically allocated, 2- core, and a
      network interface (1GbE or WiFi) with NAT support

I am using Boxes on my test device instead of VirtualBox. Boxes is more tightly
integrated with a GNOME desktop with [libvirt](https://wiki.archlinux.org/title/Libvirt)
and QEMU.

<img
  width="480px"
  alt="Screenshot 1.1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot1_1.png">

The basic resources of a VM can be configured in the settings pane of GNOME
Boxes. To enable NAT support, we need to change the interface type from `user`
to `bridge` in the XML preferences file and register a virtual bridge. I have
been told that this setting is also found on [virt-manager](https://wiki.archlinux.org/title/Virt-manager)
GUI. However, in my test, it was only successfully done with `virsh` command.

<img
  width="320px"
  alt="Screenshot 1.2"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot1_2.png">

> 6.  Install Linux from the ISO image
> 6.  Create a user id and password

Here are the selected settings when the VM is installed through live boot media.

<img
  width="480px"
  alt="Screenshot 1.3"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot1_3.png">

<img
  width="480px"
  alt="Screenshot 1.4"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot1_4.png">

> 8.  Turn on Firewall and block all ports
> 8.  Enable SSH access to your new Linux installation; open SSH port in
      firewall
> 8.  Repeat steps e through i, and create another VM with the same
      specifications as the first one
> 8.  Create private/public keys and install them properly in both of your new
      VMs
> 8.  Test that you can connect remotely to your VMs with your keys, from one VM
      to the other VM

The firewall (UFW) is installed by default, while remote login (SSH) is enabled
on installation. Both services are enabled after a fresh install and remote
login is successfully tested. This process is documented on `setup.sh`.

<img
  width="320px"
  alt="Screenshot 1.5"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot1_5.png">

## Problem 2

> Show an example of using the following commands (hint: you can use man to find
  more information about each one); take screen shots of your commands; make
  sure to clear the screen between each command; explain in your own words what
  these commands do:
>
> 1.  ssh

`ssh` command facilitates secure remote login. The first argument is the remote
server destination.iperf -s -w $SERVER_WINDOW_SIZE

<img
  width="320px"
  alt="Screenshot 2.1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_1.png">

> 2.  ssh-keygen

`ssh-keygen` generates private and public keys used in SSH logins.

<img
  width="320px"
  alt="Screenshot 2.2"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_2.png">

> 3.  scp

`scp` copies a source file into a destination directory.

<img
  width="320px"
  alt="Screenshot 2.3"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_3.png">

> 4.  history

`history` prints the recently used commands in my terminal.

<img
  width="320px"
  alt="Screenshot 2.4"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_4.png">

> 5.  sudo

`sudo` is a prefix for commands that execute with a superuser privilege.

<img
  width="320px"
  alt="Screenshot 2.5"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_5.png">

> 6.  ip

`ip` shows details related to networking, like IP and MAC address.

<img
  width="320px"
  alt="Screenshot 2.6"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_6.png">

> 7.  dd

To the best of my knowledge, `dd` writes the content of input files into bit
values that can be read as a disk device.

<img
  width="320px"
  alt="Screenshot 2.7"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_7.png">

> 8.  fdisk

`fdisk` is an interactive shell to configure partition of a disk.

<img
  width="320px"
  alt="Screenshot 2.8"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_8.png">

> 9.  apt

`apt` is the Debian package manager.

<img
  width="320px"
  alt="Screenshot 2.9"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_9.png">

> 10. vi

`vi` is a command-line text editor.

<img
  width="320px"
  alt="Screenshot 2.10"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_10.png">

> 11. time

`time` measures the execution duration of other commands.

<img
  width="320px"
  alt="Screenshot 2.11"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_11.png">

> 12. tar

`tar` archives a set of files, that is, compressing them into a single file.

<img
  width="320px"
  alt="Screenshot 2.12"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_12.png">

> 13. cat

`cat` prints the content of a text file.

<img
  width="320px"
  alt="Screenshot 2.13"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_13.png">

> 14. watch

`watch` keeps monitoring a certain command until completion.

<img
  width="320px"
  alt="Screenshot 2.14"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_14.png">

> 15. ps

`ps` lists all commands started by a user.

<img
  width="320px"
  alt="Screenshot 2.15"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_15.png">

> 16. top

`top` is a command-line task manager, providing a live feed to system resources.

<img
  width="320px"
  alt="Screenshot 2.16"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_16.png">

> 17. htop

`htop` is an improved version of top with better progress bars and a colorized
console.

<img
  width="320px"
  alt="Screenshot 2.17"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_17.png">

> 18. gcc

`gcc` compiles C source code into executables.

<img
  width="320px"
  alt="Screenshot 2.18"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_18.png">

> 19. tail

`tail` obtains the last section of a text file.

<img
  width="320px"
  alt="Screenshot 2.19"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_19.png">

> 20. grep

`grep` finds text lines that match the input pattern.

<img
  width="320px"
  alt="Screenshot 2.20"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_20.png">

> 21. kill

`kill` terminates a program given its process ID.

<img
  width="320px"
  alt="Screenshot 2.21"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_21.png">

> 22. killall

`killall` terminates all programs given their process name.

<img
  width="320px"
  alt="Screenshot 2.22"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_22.png">

> 23. du

`du` calculates the disk usage of a directory.

<img
  width="320px"
  alt="Screenshot 2.23"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_23.png">

> 24. df

`df` estimates the remaining disk usage of each filesystem.

<img
  width="320px"
  alt="Screenshot 2.24"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_24.png">

> 25. screen

`screen` manages terminal session, it can be used to keep the session even after
all jobs are finished.

<img
  width="320px"
  alt="Screenshot 2.25"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_25.png">

> 26. vim

`vim` is an improved version of vi with more macros.

<img
  width="320px"
  alt="Screenshot 2.26"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_26.png">

> 27. chmod

`chmod` changes file permissions. It controls which files can be read, written
or executed.

<img
  width="320px"
  alt="Screenshot 2.27"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_27.png">

> 28. chown

`chown` picks a new owner of a file.

<img
  width="320px"
  alt="Screenshot 2.28"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_28.png">

> 29. useradd

`useradd` registers a new user account for this system.

<img
  width="320px"
  alt="Screenshot 2.29"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_29.png">

> 30. man

`man` shows the tutorial on how to use a command.

<img
  width="320px"
  alt="Screenshot 2.30"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_30.png">

> 31. locate

`locate` searches certain files in pre-determined locations.

<img
  width="320px"
  alt="Screenshot 2.31"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_31.png">

> 32. find

`find` lists all files whose name matches the input pattern.

<img
  width="320px"
  alt="Screenshot 2.32"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_32.png">

> 33. sed

`sed` is a stream-based text transformer. It is often used to find and replace
text.

<img
  width="320px"
  alt="Screenshot 2.33"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_33.png">

> 34. awk

`awk` is a better text processing utility, but its syntax is more difficult to
understand.

<img
  width="320px"
  alt="Screenshot 2.34"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_34.png">

> 35. diff

`diff` highlights the difference between two text files.

<img
  width="320px"
  alt="Screenshot 2.35"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_35.png">

> 36. sort

`sort` rearranges the index of each text line based on its comparable content.

<img
  width="320px"
  alt="Screenshot 2.36"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_36.png">

> 37. export

`export` allows a variable to be used by other processes.

<img
  width="320px"
  alt="Screenshot 2.37"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_37.png">

> 38. pwd

`pwd` locates the current working directory and prints its path.

<img
  width="320px"
  alt="Screenshot 2.38"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_38.png">

> 39. crontab

`crontab` is an interactive shell to configure a list of commands that are
scheduled to execute at a specified time.

<img
  width="320px"
  alt="Screenshot 2.39"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_39.png">

> 40. mount

`mount` plugs in a disk image (or device) into a given directory path.

<img
  width="320px"
  alt="Screenshot 2.40"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_40.png">

> 41. passwd

`passwd` modifies the password of a user, or self if no user is specified.

<img
  width="320px"
  alt="Screenshot 2.41"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_41.png">

> 42. uname

`uname` shows the system's Linux version and distribution.

<img
  width="320px"
  alt="Screenshot 2.42"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_42.png">

> 43. whereis

`whereis` locates the installation path of a package.

<img
  width="320px"
  alt="Screenshot 2.43"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_43.png">

> 44. whatis

`whatis` explains the description of a package.

<img
  width="320px"
  alt="Screenshot 2.44"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_44.png">

> 45. su

`su` switches the user in the current shell into root. However, this convention
is not standard in Debian because the root user is not configured by default.

<img
  width="320px"
  alt="Screenshot 2.45"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_45.png">

> 46. ping

`ping` tests network availability by sending packets to the destination address.

<img
  width="320px"
  alt="Screenshot 2.46"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_46.png">

> 47. traceroute

`traceroute` diagnoses network connectivity by tracing packet movement from
source to destination.

<img
  width="320px"
  alt="Screenshot 2.47"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_47.png">

> 48. date

`date` shows the current time in the timezone preferred by the system, or UTC if
left unconfigured.

<img
  width="320px"
  alt="Screenshot 2.48"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_48.png">

> 49. time

<img
  width="320px"
  alt="Screenshot 2.49"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_49.png">

> 50. wget

`wget` downloads files from the web. It can also be used to download a webpage.

<img
  width="320px"
  alt="Screenshot 2.50"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_50.png">

> 51. wc

`wc` counts the number of words and text lines.

<img
  width="320px"
  alt="Screenshot 2.51"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_51.png">

> 52. pwgen

`pwgen` generates a set of random passwords.

<img
  width="320px"
  alt="Screenshot 2.52"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot2_52.png">

## Problem 3

> Write bash scripts to do the following:
>
> 1.  Write a script called `generate-dataset.sh <filename> <num_records>` with
      two command line arguments specifying the file name to output and the
      number of records, where each record is separated by new line character,
      and each has the following format: `<integer> <integer> <ASCII_string>`.
      The integer should be any random number up to a 32-bit integer. The
      `ASCII_string` should be any string using ASCII of exactly 100 bytes long.
      Use the “time” command to show how long the benchmark took to complete.
      The benchmark should run for at least 10 seconds, and it should complete
      even if the ssh (or bash) session is terminated. How many records does
      your file contain after running it? You must write this script entirely
      with existing Linux commands (which you can install if they don't exist on
      your system), without using any other programming languages like C, C++,
      Java, or Python.

In this example, the dataset is generated within less than 10 seconds, thus
triggering a waiting period to make sure that the script takes at least 10
seconds.

<img
  width="320px"
  alt="Screenshot 3.1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot3_1.png">

> 2.  Write a script called `sort-data.sh` that takes input a file from part (a)
      above and sorts the file based on the first column data (make sure to only
      sort based on the first column data, and not on the entire line of data;
      also make sure you are treating the data in column 1 as numbers and not
      text). Use the “time” command to show how long the sort script took to
      complete.

The sorting execution took considerably less time than generating the dataset.
The generated output file name is suffixed with _sorted while still taking
account of the file extension.

<img
  width="320px"
  alt="Screenshot 3.2"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot3_2.png">

> 3.  Use the script in part (a) and generate 3 data files with different number
      of records (1000, 100000, 10000000); measure time taken to generate these
      records. Sort the data with your script from part (b) and measure the
      time. Write a Python matplotlib script to generate a graph for the time
      taken to generate the data and the time taken to sort the data at the 3
      different scales. The graph should automatically adjust to the number of
      entries, and the scale of the data.

The Python script executes Shell scripts to generate and sort up to 10000000
records. Because the task is to measure the performance, the output files are
removed once the benchmark analysis is complete. The final output of this script
is a Matplotlib graph that visualizes the performance comparison between
generating and sorting the dataset.

<img
  width="320px"
  alt="Screenshot 3.3"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/screenshot3_3.png">

<img
  width="640px"
  alt="Figure 1"
  src="https://github.com/hanggrian/IIT-CS553/raw/assets/assignments/hw1/figure1.svg">

## Problem 4

> Answer the following questions about VMs:
>
> 1.  In the system configuration of the VM, explain how changing the number of
      processors changes the behavior of your VM. Explain a scenario where you
      want to set this to the minimum, and a scenario where you want to set it
      to the maximum. Why is setting it to the maximum potentially a bad idea?

The number of processors in the VM configuration refers to CPU threads allocated
to the virtual system. Increasing the number of processors theoretically gives
the system a better performance by allowing background processes to run in
additional threads.

However, the performance benefits may not be as crucial if the running programs
are not optimized for multi-threading. For example, a server without a desktop
environment may not need as many CPU threads. Extra processors to a VM also mean
fewer resources for the host system, potentially straining other VMs or
processes.

> 2.  In the system configuration of the VM, under the Acceleration Tab, explain
      the difference between the paravirtualization options: None, Legacy,
      Minimal, Hyper-V, and KVM. Explain which one would be best to use with
      Ubuntu Linux, and why.

Paravirtualization facilitates direct hardware access to a VM based on the
hypervisor level. It is known to drastically improve VM performance with the
correct configuration.

- **None:** No paravirtualization, any communication to hardware is emulated.
- **Legacy:** Older paravirtualization used in unsupported models.
- **Minimal:** Basic paravirtualization that requires less configuration,
  providing a notable performance boost.
- **Hyper-V:** Proprietary paravirtualization in Microsoft Windows systems.
- **KVM:** Kernel-based paravirtualization is the standard in Linux computers.
  KVM is also known to play nice with QEMU, a hardware emulator backend used by
  GNOME Boxes.

> 3.  In storage devices when configuring the VM, there are multiple types of
      storage controllers: explain the difference between the IDE, SATA, and
      NVMe controller. Give an example for each type of storage controller of a
      scenario where you may want to use this type of controller.

Storage controllers define the emulated disk interface of a VM. The VM
controller type impacts disk speed and compatibility with certain OS.

- **IDE:** An older interface with slow speed by modern standards. It is useful
  for legacy OS with no support for newer interfaces.
- **SATA:** The replacement of IDE with serial communication. It drastically
  improves the maximum speed to 6 Gbps with support for most OSes.
- **NVMe:** The newest controller designed for solid-state drives with no moving
  parts. While it has the best I/O performance, support is limited only to
  modern OSes.

> 4.  In the network configuration of the VM, there are multiple types of
      network adapters: explain the difference between NAT, Bridged Adapter,
      Internal Network, and Host-only Network. Give an example for each type of
      network of a scenario where you may want to use this type of network.

Network adapters define how the VM communicates with other devices (or the
host).

- **NAT:** Allows the VM to have the same IP address as the host while setting
  up its own private address. The private addresses are hosted in an internal
  network managed by the virtualization stack. This is the best option when the
  VM does not need access to other computers on the same router.
- **Bridged:** Any connection is forwarded to the same physical network as the
  host. It is often the default option in many virtualization software. It is
  suitable if the VM wants to behave as a regular physical device (as the host
  does).
- **Internal:** Creates a contained network that is only available to other
  computers with the same network name. It is used for testing purposes.

> 5.  For the USB configuration of the VM, explain the difference between USB
      1.1, 2.0 and 3.0 controllers.

USB versions follow the semantic versioning convention, that is, a larger number
is newer and better.

- **USB 1.1:** legacy protocol with slow 1.5 Mbps maximum transfer. Although
  newer motherboards no longer support this protocol, older devices are still
  operable due to the backwards compatibility nature of USB.
- **USB 2.0:** Significant improvement over USB 1.1 with 480 Mbps transfer
  speed. USB 2 is also capable of delivering 2.5 watts of power, sufficient for
  most peripherals.
- **USB 3.0:** The new protocol that is often characterized by the colorized
  entry port. With a maximum of 5 Gbps, USB 3 is best used for heavy operations
  like docking hubs and external drives.

## Problem 5

> Answer the following questions about computer processors:
>
> 1.  Describe what a core and hardware thread is on a modern processor and the
      difference between them?

A CPU core is a physical die full of transistors to compute instructions.
Depending on the CPU's multi-threading capability, each core may contain smaller
threads that execute separate commands to achieve the end goal faster. The
capability is tightly integrated into the CPU architecture and has different
branding for each company: Hyper-threading for Intel and SMT for AMD.

> 2.  How many cores do the fastest processors from each manufacturer have? Give
      an example (specific model, specs, and price).
>     1.  Intel CPU (x86)
>     1.  AMD CPU (x86)
>     1.  IBM CPU (Power9)
>     1.  ThunderX CPU (ARM)
>     1.  NVIDIA GPU

Below are the fastest processors in their respective categories as of 2025. The
price section is the MSRP listed on official websites instead of street value.

- Intel CPU (x86)

  Intel desktop CPUs are divided into performance and efficiency cores. In the
  newer Ultra version, the Hyper-threading support is no longer available.

  Class | Model | Speed | Cores | TDP | Price
  --- | --- | --- | --- | --- | ---
  Mobile | Core Ultra 9 285HX | 2.1&ndash;5.5GHz | 16 cores, 24 threads | 55&ndash;160W | OEM
  Desktop | Core Ultra 9 285K | 3.2&ndash;5.7GHz | 24 cores, 36 threads | 125&ndash;250W | $599
  Workstation | Xeon w9-3495X | 1.9&ndash;4.8GHz | 56 cores, 112 threads | 350&ndash;420W | $5,889
  Server | Xeon Max 9480 | 1.9&ndash;3.5GHz | 56 cores, 112 threads | 350W | $12,980
- AMD CPU (x86)

  Higher-end AMD CPUs are divided into more than one physical die, known as CCD.
  In the X3D version, one of those CCDs has a larger cache size.

  Class | Model | Speed | Cores | TDP | Price
  --- | --- | --- | --- | --- | ---
  Mobile | Ryzen AI 9 HX 375 | 3.3&ndash;5.1GHz | 12 cores, 24 threads | 15&ndash;54W | OEM
  Desktop | Ryzen 9 9950X3D | 4.2&ndash;5.7GHz | 16 cores, 32 threads | 170W | $699
  Workstation | Ryzen Threadripper 9980X | 3.2&ndash;5.4GHz | 64 cores, 128 threads | 350W | $4,999
  Server | EPYC 9965 | 2.25&ndash;3.7GHz | 192 cores, 384 threads | 500W | $14,813
- IBM CPU (Power9)

  The IBM enterprise motherboard supports multiple CPUs, and each CPU may have a
  different number of cores. This report only evaluates an individual CPU.

  Class | Model | Speed | Cores | TDP | Price
  --- | --- | --- | --- | --- | ---
  Server | Power System E980 | 3.55&ndash;4GHz | 12 cores, 96 threads | 240W | $1,291 @month
- ThunderX CPU (ARM)

  Multithreading is not available in ARM CPUs.

  Class | Model | Speed | Cores | TDP | Price
  --- | --- | --- | --- | --- | ---
  Server | CN8890 | 1.9GHz | 48 cores, 48 threads | 575W | $1,999
- NVIDIA GPU

  Class | Model | Speed | VRAM | TDP | Price
  --- | --- | --- | --- | --- | ---
  Mobile | RTX 5090 Laptop | 1.59&ndash;2.16GHz | 24GB | 95&ndash;150W | OEM
  Desktop | RTX 5090 | 2.01&ndash;2.41GHz | 32GB | 500W | $1,999
  Workstation | RTX PRO 6000 | 1.59&ndash;2.28GHz | 96GB | 600W | $8,565
  Server | B100 | 1.66&ndash;1.83GHz | 192GB | 700W | $11,025

> 3.  Why do we not have processors running at 1THz today (as might have been
      predicted in the year 2000)?

Increasing the clock speed of the CPU requires more transistors to perform the
job. To increase the number of transistors, the transistors need to be shrunk so
more of them can be fitted into a physical container. Thus, the research and
development turn the focus into increasing the core count to achieve higher
speed while maintaining heat.

However, it is growing increasingly difficult to keep shrinking the transistor
size due to physical limitations. I believe such limitations prevent us from
breaking the 1THz barrier.

> 4.  Describe Moore's Law. Is it going to go on forever? If not, when will it
      end? Justify your answer to why it will end and when.

Moore's Law states that the industry should strive to double the transistor
count every two years. Using these guidelines, Intel devised a plan that
alternated between implementing new technologies and changing chip design each
year, known as the tick-tock model.

In my opinion, Moore's Law died in 2002 when Intel failed to halve its process
node from **180 nm** to 90 nm. It was instead **130 nm** or 28% of size
reduction, instead of the required 50%. Intel's struggle is mostly apparent with
**14 nm,** when it took them four years to get to **10 nm.**

## Problem 6

> Answer the following questions about threading:
>
> 1.  Why is threading useful on a single-core processor?

Multi-threading splits a CPU core into two threads. More threads allow for more
pools of execution, making it crucial for CPUs with limited cores. In a
single-core CPU, I imagine modern OSes would be unusable without multithreading
support.

> 2.  Do more threads always mean better performance?

No, computers with more threads can perform faster only if the tasks are
optimized for multi-threading. More threads also allow the execution of multiple
processes. However, processes that are not CPU-bound may not benefit from
multiple threads.

> 3.  Is super-linear speedup possible? Explain why or why not.

Yes, linear improvement is possible through distribution, workload balancing and
hardware upgrades. However, there is a point where addressing a performance
bottleneck may not be worth the extra effort, thus not ideal.

> 4.  Why are locks needed in a multi-threaded program?

Locks are necessary to indicate that a process is actively working, preventing
other threads from making changes to the resources. A lock is essentially a
queuing system where tasks are executed in an orderly manner to protect data
integrity.

> 5.  Would it make sense to limit the number of threads in a server process?

Yes, limiting the server environment resources, such as CPU threads, can lower
the TDP requirement and the cost of power consumption. There is also a heat
concern of running the maximum number of threads 24/7 without rest. In such
cases, it makes sense to reduce the server capability in periods of peak usage.
