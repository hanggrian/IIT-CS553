#!/bin/bash

source _lib.sh
require "$1" \
  "$#" \
  2 \
  "Usage: startup.sh <${BOLD}m${END}aster|${BOLD}w${END}orker> <master_ip>
Example: startup.sh master 192.168.1.100

Set up Hadoop and Spark environment and, if master, start daemons.

Arguments:
  <master|worker> The role of this node in the Hadoop cluster.
  <master_ip>     The range of IP addresses for the master node to 8 worker nodes."

readonly ROLE="$1"
readonly MASTER_IP="$2"

start_daemon() {
  local daemon_name="$1"
  local jps_name="$2"

  if jps | grep -q "$jps_name"; then
    warn "'$daemon_name' is already running."
  else
    echo "${GREEN}Starting '$daemon_name'...$END"

    "start-$daemon_name.sh"
  fi
}

set_hadoop_env() {
  echo "$1" | \
    sudo tee -a "$HADOOP_CONF_DIR/hadoop-env.sh" > \
    /dev/null
}

echo 'Copying configuration files...'
mkdir -p "$HADOOP_CONF_DIR"
for site_file in ./*-site.xml; do
  cp -f "$site_file" "$HADOOP_CONF_DIR/"
done

echo 'Writing environment variables...'
if [[ "$(uname)" = 'Darwin' ]]; then
  jdk_home='/Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home'
elif is_os_type 'arch'; then
  jdk_home='/usr/lib/jvm/java-11-temurin'
elif is_os_type 'ubuntu|debian'; then
  jdk_home='/usr/lib/jvm/temurin-11-jdk-amd64'
else
  echo 'Unsupported OS.'
fi
set_hadoop_env "export JAVA_HOME='$jdk_home'"
set_hadoop_env "export HDFS_NAMENODE_USER=$(whoami)"
set_hadoop_env "export HDFS_DATANODE_USER=$(whoami)"
set_hadoop_env "export HDFS_SECONDARYNAMENODE_USER=$(whoami)"
set_hadoop_env "export YARN_RESOURCEMANAGER_USER=$(whoami)"
set_hadoop_env "export YARN_NODEMANAGER_USER=$(whoami)"

echo 'Configuring hostname resolution...'
ip_prefix=$(echo "$MASTER_IP" | awk -F. '{print $1"."$2"."$3}')
ip_suffix=$(echo "$MASTER_IP" | awk -F. '{print $4}')
sudo sed -i '/master/d' /etc/hosts
sudo sed -i '/worker[0-9]/d' /etc/hosts
{
  echo "$MASTER_IP master"
  echo "$ip_prefix.$((ip_suffix + 1)) worker1"
  # echo "$ip_prefix.$((ip_suffix + 2)) worker2"
  # echo "$ip_prefix.$((ip_suffix + 3)) worker3"
  # echo "$ip_prefix.$((ip_suffix + 4)) worker4"
  # echo "$ip_prefix.$((ip_suffix + 5)) worker5"
  # echo "$ip_prefix.$((ip_suffix + 6)) worker6"
  # echo "$ip_prefix.$((ip_suffix + 7)) worker7"
  # echo "$ip_prefix.$((ip_suffix + 8)) worker8"
} | sudo tee -a /etc/hosts > /dev/null

case "$ROLE" in
  m | master)
    echo 'Setting up hostname...'
    sudo hostnamectl set-hostname master 2>/dev/null || \
      echo 'master' | sudo tee /etc/hostname > /dev/null

    echo 'Configuring workers list...'
    {
      echo 'worker1'
      # echo 'worker2'
      # echo 'worker3'
      # echo 'worker4'
      # echo 'worker5'
      # echo 'worker6'
      # echo 'worker7'
      # echo 'worker8'
    } > "$HADOOP_CONF_DIR/workers"

    echo 'Preparing Hadoop directories...'
    sudo mkdir -p /hadoop/dfs/name
    sudo chown -R "$(whoami):$(whoami)" /hadoop

    echo 'Formatting namenode...'
    hdfs namenode -format

    echo 'Launching JPS instances...'
    start_daemon 'dfs' ' NameNode' # whitespace to exclude SecondaryNameNode
    start_daemon 'yarn' 'ResourceManager'
    start_daemon 'master' 'Master'

    echo 'Exiting safe mode...'
    hdfs dfsadmin -safemode leave
    ;;
  w | worker)
    echo "Setting up hostname as $worker_name..."
    current_ip=$(hostname -I | awk '{print $1}')
    worker_suffix=$(echo "$current_ip" | awk -F. '{print $4}')
    worker_num=$((worker_suffix - ip_suffix))
    worker_name="worker$worker_num"
    sudo hostnamectl set-hostname "$worker_name" 2>/dev/null || echo "$worker_name"

    echo 'Preparing Hadoop directories...'
    sudo mkdir -p /hadoop/dfs/data
    sudo chown -R "$(whoami):$(whoami)" /hadoop
    ;;
  *)
    die 'Unknown role, see help.'
    ;;
esac
