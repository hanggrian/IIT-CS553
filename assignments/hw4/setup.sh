#!/bin/bash

source _lib.sh

readonly MACOS_PACKAGES=(
  'cmake'
  'libomp'
  'boost'
)
readonly ARCH_PACKAGES=(
  'cmake'
  'openmp'
  'boost'
)
readonly FEDORA_PACKAGES=(
  'cmake'
  'libomp-devel'
  'boost-devel'
)
readonly UBUNTU_PACKAGES=(
  'cmake'
  'gcc-14' 'g++-14'
  'libomp-dev'
  'libboost-all-dev'
)

is_os_type() {
  grep -qE "^(ID|ID_LIKE)=(\"?$1\"?)$" /etc/os-release
}

has_package() {
  command -v "$1" &> /dev/null
}

# macOS requires Homebrew
if [ "$KERNEL_NAME" = 'Darwin' ]; then
  if ! has_package 'brew'; then
    die 'Need Homebrew.'
  fi
  brew install "${MACOS_PACKAGES[@]}"
  exit 0
fi

# Arch requires AUR helper
if is_os_type 'arch'; then
  if ! has_package 'yay'; then
    die 'Need AUR helper.'
  fi
  yay -S --noconfirm "${ARCH_PACKAGES[@]}"
  exit 0
fi

if is_os_type 'fedora|rhel'; then
  sudo dnf install -y "${FEDORA_PACKAGES[@]}"
  exit 0
fi

# Debian doesn't have sudo by default
# Ubuntu cmake is lower than 4.0, install it manually
if is_os_type 'ubuntu|debian'; then
  wget -O - \
    https://apt.kitware.com/keys/kitware-archive-latest.asc 2> /dev/null | \
    sudo apt-key add -

  gcc_repo='ppa:ubuntu-toolchain-r/test'
  cmake_repo='deb https://apt.kitware.com/ubuntu/ noble main'
  update_alternatives_opts=(
    --install /usr/bin/gcc gcc /usr/bin/gcc-14 60
    --slave /usr/bin/g++ g++ /usr/bin/g++-14
  )
  if has_package 'sudo'; then
    sudo apt-add-repository "$gcc_repo"
    sudo apt-add-repository "$cmake_repo"
    sudo apt update
    sudo apt install -y "${UBUNTU_PACKAGES[@]}"
    sudo update-alternatives "${update_alternatives_opts[@]}"
  else
    apt-add-repository "$gcc_repo"
    apt-add-repository "$cmake_repo"
    apt update
    apt install -y "${UBUNTU_PACKAGES[@]}"
    update-alternatives "${update_alternatives_opts[@]}"
  fi
  exit 0
fi

die 'Unsupported OS.'
