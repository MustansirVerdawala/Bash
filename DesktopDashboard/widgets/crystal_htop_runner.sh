#!/bin/bash
#
# crystal_htop_runner.sh by locupleto
# https://github.com/locupleto/crystal-widgets
#
# Common runner script for crystal_htop widgets
#
# Description:
# This script manages the execution of crystal_htop widgets within a controlled
# environment. It checks the CPU architecture to determine whether to run
# crystal_htop_arm64 or crystal_htop_x86_64. It ensures that exactly one 
# instance of the custom logging htop runs and manages a hidden screen session 
# for that instance.
#
# Info:
# - Reattach to session for inspection: screen -r crystal_htop_session
# - List screen sessions: screen -ls
# - Terminate the session: screen -X -S crystal_htop_session quit
#
# Note: This script should be placed in the top ubersicht directory

# Source the common configuration script
source "crystal_common.sh"

export HTOP_TEMP_DIR=${HTOP_TEMP_DIR:-/tmp}
export HTOPRC=$HTOP_TEMP_DIR/htop_htoprc
lockfile="$HTOP_TEMP_DIR/crystal_htop.lock"

# Determine the host architecture and use executable accordingly
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    HTOP_EXECUTABLE="crystal_htop_arm64"
elif [[ "$ARCH" == "x86_64" ]]; then
    HTOP_EXECUTABLE="crystal_htop_x86"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Use flock to ensure single thread access in critical section below
(
    while true; do
        # Try to acquire a lock using file descriptor 200
        $FLOCK_CMD -n 200 || {
            # If the lock cannot be acquired (another instance is running)
            break
        }

        # Check if the screen session 'crystal_htop_session' is already running
        if ! screen -list | grep -q "crystal_htop_session"; then
            # Start the appropriate htop executable in a detached screen session
            screen -dmS crystal_htop_session "$WIDGET_NAME/../$HTOP_EXECUTABLE"

            # List the current screen sessions to file
            screen -ls > "$HTOP_TEMP_DIR/htop_session_list.txt"

            # Report the total no of CPU cores in the system (e.g. 20)
            /usr/sbin/sysctl -n hw.ncpu > "$HTOP_TEMP_DIR/htop_num_cpus.txt"

            # Report type of mac cpu (e.g. 'Apple M1 Ultra')
            /usr/sbin/sysctl -n machdep.cpu.brand_string > "$HTOP_TEMP_DIR/htop_htop_cpu_brand.txt"

            # Report kernel version
            uname -a >> "$HTOP_TEMP_DIR/htop_kernel_version.txt"

            # Give htop a second to create the files we rely on next
            sleep 1
        fi

        # Exit the loop after executing the critical section
        break
    done
) 200>$lockfile
