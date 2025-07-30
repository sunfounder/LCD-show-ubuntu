#!/bin/bash
# MHS35 IPS display need to reset io17 to on boot to enable touch on ubuntu

# Max wait time for desktop to start (seconds)
MAX_WAIT_TIME=120
# Check interval (seconds)
CHECK_INTERVAL=1

# Check Xorg process and X11 socket
wait_for_desktop() {
    local start_time=$(date +%s)
    
    while true; do
        # Check Xorg process
        if ! pgrep -x "Xorg" > /dev/null; then
            echo "Waiting Xorg process..."
        # Check X11 socket (X0 default display)
        elif [ ! -S "/tmp/.X11-unix/X0" ]; then
            echo "Xorg started, but X11 socket is not ready..."
        else
            echo "Desktop environment (Xorg + X11) started"
            return 0  # Success return
        fi
        
        # Timeout check
        local current_time=$(date +%s)
        if [ $((current_time - start_time)) -ge $MAX_WAIT_TIME ]; then
            echo "Timeout: Desktop not started within $MAX_WAIT_TIME seconds"
            return 1  # Timeout return
        fi
        
        sleep $CHECK_INTERVAL
    done
}

# Main logic
if wait_for_desktop; then
    echo 'Desktop started, resetting io17...'
    # Drive io17 low
    pinctrl 17 op dl
    sleep 1
    # Set io17 as input
    pinctrl 17 ip pd
else
    echo "Desktop start failed, exit script"
    exit 1
fi
