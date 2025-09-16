#!/bin/bash

PACKAGES=(
  'sysbench'
  'iperf'
  'tmux'
  'lxc'
  'qemu-kvm'
  'virtinst'
  'libvirt-daemon-system'
)

# Ubuntu containers do not have sudo pre-installed.
if command -v sudo &> /dev/null; then
  sudo apt update
  sudo apt install -y "${PACKAGES[@]}"
else
  apt update
  apt install -y "${PACKAGES[@]}"
fi
