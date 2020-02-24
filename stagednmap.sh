#!/bin/bash
if [ -z $1 ]
then
        echo "Usage: ./stagednmap.sh [IP Address]"
        exit
fi

exec 5>&1
INITIAL_SCAN=$(nmap -T4 -p- $1 2>&1 | tee /dev/fd/5 ) #output results of scan to both a variable and stdout
PORTS=$(echo "$INITIAL_SCAN" | grep ^[0-9] | awk -F/ '{print $1}') #grab only port numbers from scan results
OPEN_PORT_COUNT=$(echo "$PORTS" | wc -w) #count number of lines in PORTS variable
printf "\n\n" #Add space after initial nmap scan
if [ $OPEN_PORT_COUNT -eq 0 ] #no open ports
then
        echo "No open ports found."
        exit
fi

PORTLIST=""

for port in $PORTS; do
        PORTLIST="$PORTLIST$port,"
done

PORTLIST=${PORTLIST::-1}


nmap -T4 -A -p$PORTLIST $1

exit
