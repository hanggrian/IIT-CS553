#!/bin/bash

source setup.sh

install 'qemu-kvm' 'virtinst' 'libvirt-daemon-system'

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
