#!/bin/bash

source _lib.sh
require "$1" \
  "$#" \
  1 \
  "Usage: startup.sh <${BOLD}m${END}aster|${BOLD}w${END}orker>
Example: startup.sh master

Set up Hadoop environment and, if master, start daemons.

Arguments:
  <master|worker> The role of this node in the Hadoop cluster."

readonly ROLE="$1"

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

echo 'Copying configuration files...'
mkdir -p "$HADOOP_CONF_DIR"
for site_file in ./*-site.xml; do
  cp -f "$site_file" "$HADOOP_CONF_DIR/"
done

echo 'Writing environment variables...'
hadoop_env_file="$HADOOP_CONF_DIR/hadoop-env.sh"
if [[ "$(uname)" = 'Darwin' ]]; then
  jdk_home='/Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home'
elif is_os_type 'arch'; then
  jdk_home='/usr/lib/jvm/java-11-temurin'
elif is_os_type 'ubuntu|debian'; then
  jdk_home='/usr/lib/jvm/temurin-11-jdk-amd64'
else
  echo 'Unsupported OS.'
fi
echo "export JAVA_HOME='$jdk_home'" | \
  sudo tee -a "$hadoop_env_file" > \
  /dev/null
echo "export HDFS_NAMENODE_USER=$(whoami)" | \
  sudo tee -a "$hadoop_env_file" > \
  /dev/null
echo "export HDFS_DATANODE_USER=$(whoami)" | \
  sudo tee -a "$hadoop_env_file" > \
  /dev/null
echo "export HDFS_SECONDARYNAMENODE_USER=$(whoami)" | \
  sudo tee -a "$hadoop_env_file" > \
  /dev/null
echo "export YARN_RESOURCEMANAGER_USER=$(whoami)" | \
  sudo tee -a "$hadoop_env_file" > \
  /dev/null
echo "export YARN_NODEMANAGER_USER=$(whoami)" | \
  sudo tee -a "$hadoop_env_file" > \
  /dev/null

case "$ROLE" in
  m | master)
    echo 'Preparing Hadoop directories...'
    mkdir -p ~/.hadoop/name
    mkdir -p ~/.hadoop/data

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
    echo 'Preparing Hadoop directories...'
    mkdir -p ~/.hadoop/data
    ;;
  *)
    die 'Unknown role, see help.'
    ;;
esac
