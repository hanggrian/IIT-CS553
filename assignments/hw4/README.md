[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/3z7gXw1N)

# CS553 Cloud Computing Assignment 4 Repo

**Illinois Institute of Technology**

**Team Name:** Hendra
**Students:**
- Hendra Wijaya (hwijaya@hawk.illinoistech.edu)

## AI prompts

### Prompt 1

> What is the difference between `set()` and `option()` in CMakeLists.txt?

Here’s the clear difference in one table:

Feature | `set()` | `option()`
--- | --- | ---
**Purpose** | Set any CMake variable | Create a **boolean ON/OFF** toggle
**Type** | String (or any type) | Strict boolean
**UI in CMake GUIs** | Hidden | Visible as checkbox
**Typical use** | Numbers, paths, strings | Enabling optional features
**Cache behavior** | Optional (only if `CACHE` keyword used) | Always cached
**Command line override*** | Works only if cached (`CACHE STRING`) | Always works (`-DOPTION=ON/OFF`)
**Valid values** | Anything | Only `ON`, `OFF`, `TRUE`, `FALSE`

#### Example usage

Declare options and variables in CMakeLists.txt:

```cmake
option(USE_OPENMP "Enable OpenMP" ON)

set(NONCE_SIZE 6 CACHE STRING "Nonce size in bytes")
```

CLI override:

```sh
cmake -DUSE_OPENMP=OFF -DNONCE_SIZE=8 ..
```

These become C-style flags:

```cpp
#ifdef USE_OPENMP
  // OpenMP code
#endif

#define NONCE_SIZE 6
```

### Prompt 2

> Convert my ASCII colors in Bash to Python and CPP:
>
> ```sh
> readonly END='[0m'
> readonly BOLD='[1m'
> readonly RED='[91m'
> readonly GREEN='[92m'
> readonly YELLOW='[93m'
> ```

Here are equivalent definitions in **Python** and **C++,** using the same ANSI
escape codes:

#### Python version

```py
END = "\033[0m"
BOLD = "\033[1m"
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"

print(f"{BOLD}{RED}Error!{END}")
```

#### C++ version

```cpp
#include <iostream>
#include <string>

const std::string END = "\033[0m";
const std::string BOLD = "\033[1m";
const std::string RED = "\033[91m";
const std::string GREEN = "\033[92m";
const std::string YELLOW = "\033[93m";

int main() {
    std::cout << BOLD << GREEN << "Success!" << END << std::endl;
    return 0;
}
```

### Prompt 3

> Suggest relevant CMake flags that will improve Blake3 hashing performance with
  OpenMP.

To suggest CMake flags for performance improvement, we should focus on enabling
compiler optimizations, target-specific instruction sets, and potentially
interprocedural optimizations.

Here are the suggested CMake flags, along with explanations for their
performance benefit:

#### Compiler optimization flags

These flags instruct the compiler (like GCC or Clang) to apply aggressive
optimizations.

Flag | Description | Performance benefit
--- | --- | ---
`-DCMAKE_BUILD_TYPE=Release` | Sets the build configuration to Release. | Enables the highest level of compiler optimization (`-O3`) and disables debug information.
`-O3` | Enable aggressive optimization. | The most significant flag for performance, enabling loop unrolling, function inlining, vectorization, and other high-level transformations.
`-march=native` | Target the host machine's architecture. | Allows the compiler to use instruction sets (like AVX, AVX2, SSE4, etc.) specific to the CPU compiling the code, which are generally faster.
`-flto` (or `-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=TRUE`) | Enable Link-Time Optimization. | Allows the compiler to optimize code across different compilation units (CPP files), which can lead to better function inlining and dead code elimination.
`-fwhole-program` (GCC/Clang specific) | Treat the entire program as one translation unit. | Enables more aggressive optimizations and inlining by telling the compiler it has the whole program context.
`-funroll-loops` | Unroll loops explicitly. | Reduces loop overhead and exposes opportunities for vectorization.

In your `CMakeLists.txt` file, you would typically set these properties:

```cmake
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)

if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  set(CMAKE_CXX_FLAGS_RELEASE
    "${CMAKE_CXX_FLAGS_RELEASE} -O3 -march=native -fwhole-program -funroll-loops"
  )
elseif (CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
  set(CMAKE_CXX_FLAGS_RELEASE
    "${CMAKE_CXX_FLAGS_RELEASE} /O2 /arch:AVX2 /GL /Gw"
  )
endif()
```
