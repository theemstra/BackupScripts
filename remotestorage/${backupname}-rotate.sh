#!/bin/bash
# XSByte 2015

#
## Make sure to change the name of this file to reflect the backup name!
#

basename=$1
numbertokeep=$2
## This location has to match the server backup's location for the rotate to work.
location="LOCATION_HERE"

loopstart=$((numbertokeep-1))

if [ -f ${location}${basename}.${numbertokeep} ]; then
    rm ${location}${basename}.${numbertokeep}; fi

for ((i=loopstart; i>=1; i--))
do
    new=$(($i+1))
    if [ -f ${location}${basename}.${i} ]; then
        mv ${location}${basename}.${i} ${location}${basename}.${new}
    fi
done

mv ${location}${basename} ${location}${basename}.1
