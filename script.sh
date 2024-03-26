#!/bin/bash
# Packets Loss, Average Ping Time Watch, Spike Detection, and Peak Ping Time Reporting
# This script checks the packet loss, calculates the average ping time, detects spikes in ping times, and reports peak ping time.

#=== PARAMETERS (change them here)
HOSTS="1.1.1.1"  # Add IP/hostname separated by white space
COUNT=10  # Average Packet check

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
    echo "Check the rate of packets loss, average ping time, detect spikes, and report peak ping time, outputting the result in a file named plwatch.txt in the same directory as this script."
    echo "Note: this script is cron-friendly, so you can add it to a cron job to regularly check your packets loss, ping times, detect spikes, and peak ping times."
    exit
fi

#=== Main script
for myHost in $HOSTS
do
    # Capture the output of ping command
    output=$(ping -c $COUNT $myHost)
    # Extract packet loss information
    msg=$(echo "$output" | grep 'loss')
    # Extract times and calculate the average time and find peak time
    times=( $(echo "$output" | grep 'time=' | awk -F'time=' '{ print $2 }' | awk -F' ms' '{ print $1 }') )
    sum=0
    peakTime=0
    for t in "${times[@]}"; do
        sum=$(echo "$sum + $t" | bc)
        if (( $(echo "$t > $peakTime" | bc -l) )); then
            peakTime=$t
        fi
    done
    avgTime=$(echo "scale=2; $sum / ${#times[@]}" | bc)
    # Append the packet loss, average time, and peak time information to plwatch.txt
    echo "[$today $currtime] ($myHost $COUNT) $msg, Avg Time: $avgTime ms, Peak Time: $peakTime ms" >> plwatch.txt
    # Check for spikes
    spikeThreshold=$(echo "scale=2; $avgTime * 5" | bc)
    for t in "${times[@]}"; do
        if (( $(echo "$t > $spikeThreshold" | bc -l) )); then
            echo "Warning: Spike detected in $myHost ping time, $t ms exceeds 5 times the average ($avgTime ms)" >> plwatch.txt
        fi
    done
done
