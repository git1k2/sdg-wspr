#!/bin/bash

# SDG IP address
address="192.168.50.117"

# Center WSPR frequency in Herz
freq10="28126100"
freq20="14097100"
freq40="7040100"

# WSRP FM dev
fm_dev="2.1972"

# Amplitude in Vpp, 1 dBm (for coax loss)
ampl="0.710"

# Arb waveform name
wave="wspr0dbm"

# Arb wave frame in seconds
wave_frame="120"

# tx frame
tx_frame="112"

trap ctrl_c INT
stty -echoctl # hide ^C

send() {
        lxi scpi -a "${address}"  "$1"
}

ctrl_c() {
        echo "Ctrl-C pressed, switching off outputs."
        send "C1:OUTP OFF"
        send "C2:OUTP OFF"
        echo "Goodbye."
        exit
}

# Print identification
send "*IDN?"

# Configure output channel 1 and 2
send "C1:OUTP OFF"
send "C2:OUTP OFF"

# Enable external 10 MHz clock input
send "ROSC EXT"

# Configure output channel 1 and 2
send "C1:OUTP LOAD,50"
send "C2:OUTP LOAD,50"

# Disable wave combine
send "C1:CMBN OFF"
send "C2:CMBN OFF"


configure_fm() {
        freq=$1
        wsprfreq_low=$((freq - 80))
        wsprfreq_high=$((freq + 80))
        random_freq=$(shuf -i $wsprfreq_low-$wsprfreq_high -n 1)
        echo "Next TX freq: $random_freq Hz, amplitude: ${ampl} Vpp"

        # Configure wave channel 1
        send "C1:BSWV WVTP,SINE,FRQ,$random_freq,AMP,${ampl},OFST,0,PHSE,0"

        # Load Arb wave channel 2
        send "C2:ARWV NAME,${wave}"
        send "C2:BSWV PERI,${wave_frame},AMP,6,OFST,0,PHSE,0"

        # Modulation channel 1
        send "C1:MDWV FM"
        send "C1:MDWV STATE,ON"
        send "C1:MDWV FM,SRC,EXT"
        send "C1:MDWV FM,DEVI,${fm_dev}"

        # Enable screen saver
        send "SCSV 1"
}

wait_for_minute() {
        if [ "$1" = "0" ]; then
                next="$(date --date='10 min' +%H:%M:%S | cut -b 1-4)$1:$2"
        else
                next="$(date +%H:%M:%S| cut -b 1-4)$1:$2"
                next_epoch=$(date -d "${next}" +%s)
                if [ ${next_epoch} -le $(date +%s) ]; then
                        next="$(date --date='10 min' +%H:%M:%S | cut -b 1-4)$1:$2"
                fi
        fi
        echo "Next TX at:   $next"
        current_epoch=$(date +%s.%N)
        target_epoch=$(date -d "$next" +%s.%N)
        sleep_seconds=$(echo "$target_epoch - $current_epoch"|bc)
        sleep "$sleep_seconds"
}

while true
do
        echo "======================================"
        configure_fm ${freq40}

        # Pick random slot
        array[0]="0"
        array[1]="2"
        array[2]="4"
        array[3]="6"
        array[4]="8"
        size=${#array[@]}
        index=$(($RANDOM % $size))
        wait_for_minute ${array[$index]} 00

        # Format M:SS
        #wait_for_minute 4 00

        echo "$(date) - TX ON"
        send "C1:MDWV STATE,ON"
        send "C2:OUTP ON"
        send "C1:OUTP ON"
        sleep "${tx_frame}"

        send "C1:OUTP OFF"
        send "C2:OUTP OFF"
        send "C1:MDWV STATE,OFF"
        echo "$(date) - TX OFF"

done