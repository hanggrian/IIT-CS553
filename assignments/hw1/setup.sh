#!/bin/bash

source _lib.sh

# package requirements
sudo apt-get install -y ufw openssh-server python3 \
  gcc plocate traceroute pwgen

# enable firewall and block incoming ports
sudo ufw enable
if ! systemctl is-active --quiet ufw; then die 'UFW is not enabled.'; fi
sudo ufw default deny incoming

# enable SSH and allow firewall access
sudo systemctl enable ssh --now
if ! systemctl is-active --quiet ssh; then die 'SSH is not enabled.'; fi
