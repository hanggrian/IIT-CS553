#!/bin/bash

source setup.sh

install 'lxc'

sudo lxd init --auto
sudo lxc launch ubuntu:24.04 container
sudo lxc shell container
