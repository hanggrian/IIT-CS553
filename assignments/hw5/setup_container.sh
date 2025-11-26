#!/bin/bash

source _lib.sh

install 'tmux' 'lxc'

sudo lxd init --minimal

echo 'Enabling internet on Chameleon...'
HOST_MAC=$(ip a show eno1np0 | grep -oE '([0-9a-f]{2}:){5}[0-9a-f]{2}' | head -n 1)
sudo lxc profile device remove default eth0
sudo lxc profile device add default eth0 nic \
  nictype=macvlan \
  parent=eno1np0 \
  name=eth0 \
  hwaddr="$HOST_MAC"

warn "Execute 'launch_container.sh' in a new tmux session."
