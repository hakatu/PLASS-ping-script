#!/bin/bash
# Packets Loss, Average Ping Time Watch, and Spike Detection
# This script checks the packet loss, calculates the average ping time, and detects spikes in ping times.
# Inspired by https://github.com/jaclu/packet_loss-script
#=== PARAMETERS (change them here)
HOSTS="google.com"  # Add IP/hostname separated by white space
COUNT=100  # Average Packet check

#=== Local vars (do not change them)
# Cron-friendly: Automatically change directory to the current one
cd $(dirname "$0")

# Current script filename
SCRIPTNAME=$(basename "$0")

# Current date and time
today=$(date '+%Y-%m-%d')
currtime=$(date '+%H:%M:%S')

#=== Help message
if [[ "$@" =~ "--help" ]]; then
    echo "Usage: bash $SCRIPTNAME"
    echo "Check the rate of packets loss, average ping time, and detect spikes, outputting the result in a file named plwatch.txt in the same directory as this script."
    echo "Note: this script is cron-friendly, so you can add it to a cron job to regularly check your packets loss, ping times, and detect spikes."
    exit
fi

#=== Main script
for myHost in $HOSTS
do
    # Capture the output of ping command
    output=$(ping -c $COUNT $myHost)
    # Extract packet loss information
    msg=$(echo "$output" | grep 'loss')
    # Extract and calculate the average time
    times=( $(echo "$output" | grep 'time=' | awk -F'time=' '{ print $2 }' | awk -F' ms' '{ print $1 }') )
    sum=0
    for t in "${times[@]}"; do
        sum=$(echo "$sum + $t" | bc)
    done
    avgTime=$(echo "scale=2; $sum / ${#times[@]}" | bc)
    # Append the packet loss and average time information to plwatch.txt
    echo "[$today $currtime] ($myHost $COUNT) $msg, Avg Time: $avgTime ms" >> plwatch.txt
    # Check for spikes
    for t in "${times[@]}"; do
        spikeThreshold=$(echo "scale=2; $avgTime * 5" | bc)
        if (( $(echo "$t > $spikeThreshold" | bc -l) )); then
            echo "Warning: Spike detected in $myHost ping time, $t ms exceeds 5 times the average ($avgTime ms)" >> plwatch.txt
        fi
    done
done
