#!/bin/bash
if [ -z $1 ]
then
        echo "Usage: ./stagednmap.sh [IP Address]"
        exit
fi
echo "Conducting initial port scan..."

INITIAL_SCAN=$(nmap -T4 -Pn -p- -oG - $1 | grep  "Ports: " | awk -F "Ports: " '{print $2}' | tr '/' '_' )

#sample output: 135_open_tcp__msrpc___, 139_open_tcp__netbios-ssn___, 445_open_tcp__microsoft-ds___
OPEN_PORT_COUNT=$(echo $INITIAL_SCAN | awk -F', ' '{print NF; exit}')
if [ $OPEN_PORT_COUNT -eq 0 ]
then
        echo "No open ports found."
        exit
fi

echo "Number of open ports: $OPEN_PORT_COUNT"

PORTLIST=""

for ((i=1;i<=$OPEN_PORT_COUNT;i++))
do
        PORT=$(echo $INITIAL_SCAN | awk -F ', ' -v var="$i" '{print $var}' | awk -F '_' '{print $1}')
        PORT="$PORT,"
        PORTLIST="$PORTLIST$PORT"
done

PORTLIST=${PORTLIST%?}

echo "Open ports: $PORTLIST"
echo "Performing version detection, OS detection, script scanning, and traceroute. This may take some time..."

nmap -T4 -A -p$PORTLIST $1

exit
