#!/bin/bash

source _lib.sh
require "$1" \
  "$#" \
  2 \
  "Usage: launch_container.sh <container_name> <${BOLD}t${END}iny|${BOLD}s${END}mall|${BOLD}l${END}arge>
Example: launch_container.sh containersmall s

Launch an LXC container using shared storage pool and enter session.

Arguments:
  <container_name>   The name of the container.
  <tiny|small|large> Specification of CPU, RAM and storage."

readonly CONTAINER_NAME="$1"
readonly SPEC="$2"

declare -A TINY_SPEC=(
  [CORES]=4
  [RAM]=4096
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

if sudo lxc info "$CONTAINER_NAME" &> /dev/null; then
  die "Container with that name already exists."
fi

echo "CPU:  ${BOLD}$cores cores$END"
echo "RAM:  ${BOLD}$((ram_mb / 1024)) GB$END"
echo "Disk: ${BOLD}$disk_gb GB$END"

echo
echo 'Launching container...'
sudo lxc launch ubuntu:24.04 "$CONTAINER_NAME"

echo 'Configuring resources...'
sudo lxc config set "$CONTAINER_NAME" limits.cpu "$cores"
sudo lxc config set "$CONTAINER_NAME" limits.memory "$ram_mb"MB
if sudo lxc config device show "$CONTAINER_NAME" | grep -q '^root:'; then
  sudo lxc config device set "$CONTAINER_NAME" root size "${disk_gb}GB"
else
  sudo lxc config device add "$CONTAINER_NAME" \
    root disk path=/ pool=default size="${disk_gb}GB"
fi

echo 'Setting hostname...'
sudo lxc exec "$CONTAINER_NAME" -- \
  sh -c "echo '$CONTAINER_NAME' > /etc/hostname"
sudo lxc exec "$CONTAINER_NAME" -- hostname "$CONTAINER_NAME"

echo 'Entering session...'
sudo lxc exec "$CONTAINER_NAME" -- /bin/bash
