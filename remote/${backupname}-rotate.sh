#!/bin/bash
# Backup & Rotation Scripts
# Copyright 2010-2015 by XSByte
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# @category    XSByte
# @copyright   2010-2015 by XSByte | http://www.xsbyte.com
# @author      Thom Heemstra <thom@heemstra.us>
# @license     http://www.gnu.org/licenses/gpl-2.0.html GPL v2

#
## Make sure to change the name of this file to reflect the backup name!
## Also fill out the location below
#

###### Config ######

## Add the location to your backup dir here eg(/home/user/backups/machinename/)
location="/home/user/backups/machinename/"

####################

basename=$1
numbertokeep=$2
## This location has to match the server backup's location for the rotate to work.

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
