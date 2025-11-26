#!/bin/bash

source _lib.sh

readonly MACOS_PACKAGES=(
  'temurin@11'
  'hadoop'
  'apache-spark'
)
readonly ARCH_PACKAGES=(
  'jdk11-temurin'
  'hadoop'
  'apache-spark'
)
readonly UBUNTU_PACKAGES=(
  'temurin-11-jdk'
  'ssh'
)

has_package() {
  command -v "$1" &> /dev/null
}

write_rc_file() {
  local rc_file="$1"
  local java_home="$2"
  local hadoop_home="$3"
  local spark_home="$4"

  touch "$rc_file"
  {
    echo "export JAVA_HOME='$java_home'"
    echo
    echo "export HADOOP_HOME='$hadoop_home'"
    echo 'export HADOOP_COMMON_HOME="$HADOOP_HOME"'
    echo 'export HADOOP_CONF_DIR="$HADOOP_HOME/etc/hadoop"'
    echo 'export PATH="$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin"'
    echo
    echo "export SPARK_HOME='$spark_home'"
    echo 'export PATH="$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin"'
    echo 'export PYSPARK_PYTHON=/usr/bin/python3'
  } >> "$rc_file"
}

configure() {
  echo 'Creating environment variables...'
  if [[ "$(uname)" = 'Darwin' ]]; then
    write_rc_file \
      ~/.zshrc \
      '/Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home' \
      '/opt/homebrew/opt/hadoop' \
      '/opt/homebrew/opt/apache-spark'
  elif is_os_type 'arch'; then
    write_rc_file \
      ~/.bashrc \
      '/usr/lib/jvm/java-11-temurin' \
      '/opt/hadoop' \
      '/opt/apache-spark'
  elif is_os_type 'ubuntu|debian'; then
    write_rc_file \
      ~/.bashrc \
      '/usr/lib/jvm/temurin-11-jdk-amd64' \
      '/opt/hadoop' \
      '/opt/spark'
  fi

  warn 'Restart shell session, and run startup.sh to finish setup.'
}

# macOS requires Homebrew
if [[ "$(uname)" = 'Darwin' ]]; then
  if ! has_package 'brew'; then
    die 'Need Homebrew.'
  fi
  brew install "${MACOS_PACKAGES[@]}"

  configure
  exit 0
fi

# Arch requires AUR helper
if is_os_type 'arch'; then
  if ! has_package 'yay'; then
    die 'Need AUR helper.'
  fi
  yay -S --noconfirm "${ARCH_PACKAGES[@]}"

  configure
  exit 0
fi

# official packages are not available, install them manually
if is_os_type 'ubuntu|debian'; then
  # Install Temurin by repo
  sudo apt install -y wget apt-transport-https gpg
  wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | \
    gpg --dearmor | \
    sudo tee /etc/apt/trusted.gpg.d/adoptium.gpg > \
    /dev/null
  echo "deb [arch=$(dpkg --print-architecture)] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print $2}' /etc/os-release) main" | \
    sudo tee /etc/apt/sources.list.d/adoptium.list
  sudo apt update
  sudo apt install -y "${UBUNTU_PACKAGES[@]}"

  # Enable SSH
  sudo systemctl enable --now ssh
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  ssh -o StrictHostKeyChecking=no localhost true

  # Download Hadoop
  hadoop_version='3.4.2'
  wget "https://downloads.apache.org/hadoop/common/hadoop-$hadoop_version/hadoop-$hadoop_version.tar.gz"
  tar -xzf "hadoop-$hadoop_version.tar.gz"
  sudo mv "hadoop-$hadoop_version" /opt/hadoop

  # Download Spark
  spark_version='3.5.7'
  wget "https://dlcdn.apache.org/spark/spark-$spark_version/spark-$spark_version-bin-hadoop3.tgz"
  tar -xzf "spark-$spark_version-bin-hadoop3.tgz"
  sudo mv "spark-$spark_version-bin-hadoop3" /opt/spark

  configure
  exit 0
fi

die 'Unsupported OS.'
