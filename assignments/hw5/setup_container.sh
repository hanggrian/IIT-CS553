#!/bin/bash

source _lib.sh

install 'tmux' 'lxc'

echo 'Initializing LXD...'
sudo lxd init --auto

echo 'Allow firewall...'
sudo firewall-cmd --permanent --zone=trusted --add-interface=lxdbr0
sudo firewall-cmd --permanent --zone=trusted --add-masquerade
sudo firewall-cmd --reload

echo 'Generating SSH key for cluster...'
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa

warn "Execute 'launch_container.sh' in a new tmux session."
