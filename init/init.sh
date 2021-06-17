#! /bin/bash

# Compile SU2 on each node in session
echo "Compiling SU2 on compute nodes"

for node in 'cat /etc/JARVICE/nodes'; do
    if [ $node != "$HOSTNAME" ]; then
        ssh $node "/usr/local/SU2/init/compile_SU2.sh" &
    fi
done

# Compile SU2 on the main node in the session
echo "Compiling SU2 on main node"

/usr/local/SU2/init/compile_SU2.sh

sleep 60s

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
