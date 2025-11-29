[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/I7Ayx-Ld)

### CS553 Cloud Computing Assignment 5 Repo

**Illinois Institute of Technology**

**Team Name:** Hendra
**Students:**
- Hendra Wijaya (hwijaya@hawk.illinoistech.edu)

## AI prompts

### Prompt 1

> Create `is_hadoop_running` in Bash, a function that returns true if JPS finds
  `NameNode`.

```sh
# Function to check if Hadoop is running by looking for NameNode process
is_hadoop_running() {
  if command -v jps &> /dev/null; then
    if jps | grep -q "NameNode"; then
      return 0  # true - Hadoop is running
    else
      return 1  # false - NameNode not found
    fi
  else
    echo "Error: jps command not found. Is Java/JDK installed?" >&2
    return 1
  fi
}
```

You can use it in standard bash conditionals like
`if is_hadoop_running; then ...` or with the `&&` and `||` operators.

### Prompt 2

> Why does a Hadoop installation require SSH, even for a single-node setup?
>
> ```sh
> sudo systemctl enable --now ssh
> ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
> cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
> chmod 600 ~/.ssh/authorized_keys
> ssh localhost
> ```

Hadoop's daemon control scripts (`start-dfs.sh`, `stop-dfs.sh`, etc.) rely
heavily on **SSH** to start and stop the NameNode, DataNodes, ResourceManager,
and NodeManagers across all nodes in the cluster.

In a single-node, pseudo-distributed setup (like the one configured in your
`setup.sh`), Hadoop uses SSH to connect back to `localhost` to start and manage
its own daemons. Without passwordless SSH, the script would hang, repeatedly
asking you for your password for every daemon it attempts to start.

Therefore, this setup is **mandatory.**

> However, a new session is opened when calling `ssh localhost`, stopping the
  execution of the script until the session is closed.

To ensure the command runs, verifies the connection, and immediately returns
control to your script, you need to execute a **non-interactive command** using
`ssh`.

Replace the line `ssh localhost` in your `setup.sh` with the following command:

```sh
ssh -o StrictHostKeyChecking=no localhost true
```

### Prompt 3

> I couldn't get DNS to work on my LXC containers in a Chameleon Cloud
  environment. On my host OS, I observed that MASQUERADE rule has 0 packets.

Check for additional iptables rules on the host:

```sh
sudo iptables -L -n -v --line-numbers

# Check if there are rules in other tables
sudo iptables -t mangle -L -n -v
sudo iptables -t raw -L -n -v

# Check nftables (newer firewall system)
sudo nft list ruleset
```

Also check if firewalld or ufw is running:

```sh
sudo systemctl status firewalld
sudo systemctl status ufw
sudo ufw status
```

If firewalld or ufw is active, they're likely blocking the traffic. The fix:

```sh
# If ufw is active
sudo ufw allow from $GUEST_IP/24
sudo ufw reload

# If firewalld is active
sudo firewall-cmd --permanent --zone=trusted --add-source=$GUEST_IP/24
sudo firewall-cmd --reload
```

Or, if you don't need these firewalls:

```sh
sudo systemctl stop ufw
sudo systemctl disable ufw

# OR
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```
