cmake_minimum_required(VERSION 4.0)
project(hw4)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_BUILD_TYPE Release)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  set(
    CMAKE_CXX_FLAGS_RELEASE
    "${CMAKE_CXX_FLAGS_RELEASE} -O3 -march=native -fwhole-program -funroll-loops"
  )
elseif (CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
  set(
    CMAKE_CXX_FLAGS_RELEASE
    "${CMAKE_CXX_FLAGS_RELEASE} /O2 /arch:AVX2 /GL /Gw"
  )
endif()

set(NONCE_SIZE "6" CACHE STRING "Nonce size in bytes")
set(HASH_SIZE "10" CACHE STRING "Hash size in bytes")
add_compile_definitions(
  NONCE_SIZE=${NONCE_SIZE}
  HASH_SIZE=${HASH_SIZE}
)

include(FetchContent)
FetchContent_Declare(
  blake3
  GIT_REPOSITORY https://github.com/BLAKE3-team/BLAKE3.git
  GIT_TAG master
  SOURCE_SUBDIR c
)
FetchContent_MakeAvailable(blake3)

find_package(Boost REQUIRED COMPONENTS program_options)
find_package(Threads REQUIRED)
find_package(OpenMP REQUIRED)

add_executable(
  vaultx
  src/main.cpp
  src/generating.cpp
  src/sorting.cpp
  src/verifying.cpp
  src/searching.cpp
  src/printing.cpp
)

target_link_libraries(
  vaultx
  PRIVATE
  blake3
  Boost::program_options
  Threads::Threads
  OpenMP::OpenMP_CXX
)
