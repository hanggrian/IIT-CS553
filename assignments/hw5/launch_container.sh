#!/bin/bash

source _lib.sh
require "$1" \
  "$#" \
  3 \
  "Usage: launch_container.sh <${BOLD}t${END}iny|${BOLD}s${END}mall|${BOLD}l${END}arge> <container_name> <ip_suffix>
Example: launch_container.sh t master 10

Launch an LXC container using shared storage pool and enter session.

Arguments:
  <tiny|small|large> Specification of CPU, RAM and storage.
  <container_name>   The name of the container.
  <ip_suffix>        The last octet of the static IP."

readonly SPEC="$1"
readonly CONTAINER_NAME="$2"
readonly IP_SUFFIX="$3"

declare -A TINY_SPEC=(
  [CORES]=4
  [RAM]=6144
  [DISK]=10
)
declare -A SMALL_SPEC=(
  [CORES]=4
  [RAM]=4096
  [DISK]=30
)
declare -A LARGE_SPEC=(
  [CORES]=32
  [RAM]=32768
  [DISK]=240
)

lxc_exec() {
  sudo lxc exec "$CONTAINER_NAME" -- "$@"
}

lxc_config_set() {
  sudo lxc config set "$CONTAINER_NAME" "$@"
}

case "$SPEC" in
  t | tiny)
    cores=${TINY_SPEC[CORES]}
    ram_mb=${TINY_SPEC[RAM]}
    disk_gb=${TINY_SPEC[DISK]}
    ;;
  s | small)
    cores=${SMALL_SPEC[CORES]}
    ram_mb=${SMALL_SPEC[RAM]}
    disk_gb=${SMALL_SPEC[DISK]}
    ;;
  l | large)
    cores=${LARGE_SPEC[CORES]}
    ram_mb=${LARGE_SPEC[RAM]}
    disk_gb=${LARGE_SPEC[DISK]}
    ;;
  *)
    die 'Unknown specifications, see help.'
    ;;
esac

gateway_ip=$( \
  sudo lxc network show lxdbr0 | \
  grep 'ipv4.address:' | \
  awk '{print $2}' | cut -d'/' -f1)
if [[ -z "$gateway_ip" ]]; then
  die 'Could not determine gateway.'
fi
ip_prefix=$(echo "$gateway_ip" | sed 's/\.[0-9]\+$//')
ip_address="$ip_prefix.$IP_SUFFIX"

if sudo lxc info "$CONTAINER_NAME" &> /dev/null; then
  die 'Container with already exists.'
fi

echo "CPU:  ${BOLD}$cores cores$END"
echo "RAM:  ${BOLD}$((ram_mb / 1024)) GB$END"
echo "Disk: ${BOLD}$disk_gb GB$END"
echo "IP:   ${BOLD}$ip_address$END"
echo

echo 'Starting container...'
sudo lxc launch ubuntu:24.04 "$CONTAINER_NAME"

echo 'Configuring resources...'
lxc_config_set limits.cpu "$cores"
lxc_config_set limits.memory "$ram_mb"MB
if sudo lxc config device show "$CONTAINER_NAME" | grep -q '^root:'; then
  sudo lxc config device set "$CONTAINER_NAME" root size "${disk_gb}GB"
else
  sudo lxc config device add "$CONTAINER_NAME" \
    root disk path=/ pool=default size="${disk_gb}GB"
fi

echo 'Setting up static IP...'
lxc_exec ip addr add "$ip_address/24" dev eth0
lxc_exec ip route add default via "$gateway_ip" dev eth0

echo 'Resolving DNS...'
lxc_exec sh -c "cat > /etc/resolv.conf << EOF
nameserver $gateway_ip
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF"

echo 'Setting hostname...'
lxc_exec sh -c "echo '$CONTAINER_NAME' > /etc/hostname"
lxc_exec hostname "$CONTAINER_NAME"

echo 'Distributing SSH cluster key...'
lxc_exec apt-get update
lxc_exec apt-get install -y openssh-server
lxc_exec systemctl enable --now ssh
lxc_exec mkdir -p /root/.ssh
lxc_exec chmod 700 /root/.ssh
if [[ -f ~/.ssh/id_rsa.pub ]]; then
  host_pub_key=$(cat ~/.ssh/id_rsa.pub)
  lxc_exec sh -c "echo '$host_pub_key' >> /root/.ssh/authorized_keys"
  lxc_exec chmod 600 /root/.ssh/authorized_keys
fi
lxc_exec sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
lxc_exec sed -i 's/PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
lxc_exec systemctl restart ssh
sudo lxc file push ~/.ssh/id_rsa "$CONTAINER_NAME/root/.ssh/id_rsa"
sudo lxc file push ~/.ssh/id_rsa.pub "$CONTAINER_NAME/root/.ssh/id_rsa.pub"
lxc_exec chmod 600 /root/.ssh/id_rsa
lxc_exec chmod 644 /root/.ssh/id_rsa.pub
lxc_exec sh -c "cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys"
lxc_exec chmod 600 /root/.ssh/authorized_keys

echo 'Entering session...'
lxc_exec /bin/bash
