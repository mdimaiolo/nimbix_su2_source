#! /bin/bash

# Compile SU2 on each node in session
echo "Compiling SU2 on compute nodes"

while read node; do
    echo "Initializing $node"
    if [ "$node" != "$HOSTNAME" ]; then
        ssh $node "/usr/local/SU2/init/compile_SU2.sh" &
    fi
done < /etc/JARVICE/nodes

# Compile SU2 on the main node in the session
echo "Compiling SU2 on main node"

/usr/local/SU2/init/compile_SU2.sh
echo "$HOSTNAME" | cat >> /tmp/node_ready_status.txt

# Wait for all nodes to complete compilation
node_count=$(wc -l < "/etc/JARVICE/nodes")
nodes_ready=0
SECONDS=0
while [ "$nodes_ready" -lt "$node_count" ]; do  
	if [ "$SECONDS" -gt 60 ]; then
	    echo "At least one node has not initialized SU2."
		echo "Exiting..."
		exit 1
	fi
	sleep 5s
	nodes_ready=$(wc -l < "/tmp/node_ready_status.txt")
done

echo "All nodes initialized."
echo "Changing to /data/SU2 directory to begin data processing."

cd /data/SU2

# Provide permission to run bash file in /data directory
sudo chmod -R 0777 /data/SU2

# Get bash filename from session initialization
while [[ -n "$1" ]]; do
    case "$1" in
	-file)
	    shift
        BASH_FILE="$1"
		;;
	esac
    shift
done

# Call the bash file
$BASH_FILE
