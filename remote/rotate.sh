#!/bin/bash
# Backup & Rotation Scripts
# Copyright 2010-2017 by XSbyte
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
# @category    XSbyte
# @copyright   2010-2017 by XSbyte | https://xsbyte.com
# @author      Thom Heemstra <thom@heemstra.xyz>
# @license     http://www.gnu.org/licenses/gpl-2.0.html GPL v2

##
#
#  This Backup rotation script will remove backups that are older than <days_to_keep_backup_for> old.
#  This script will be called from the backup script, but can be used seperately.
#  Backup files will look like
#
##

###### HOW TO USE ######

if [ $# -lt 2 ]
then 
    echo "Error - Please supply at least 2 arguments"
    echo ""
    echo "  USAGE  : ${0} <basename> <days_to_keep_backup_for> [<location>]"
    echo ""
    echo "  Example: backuprotate.sh mars 21"
    exit
fi

###### CONFIG ######
# Here you can set and override some default settings.

defaultlocation="/volume1/Backups/servers/${basename}/"
location=""
basename=$1
days_to_keep=$2

###### CHECKS ######

# Where should we store data? If $3 is not given, use default location.
if [ -z $3 ]
then
	location=defaultlocation
else
	location=${3%/}
fi

# Days to keep must be greater than 0, if not, give error.
if [ $days_to_keep -eq 0 ]
then
	echo "Error - Invalid no. of days. days_to_keep_backup_for should be >= 0"
	exit
fi

###### ROTATE ######

# Now let's find older versions and remove them
find ${location} -maxdepth 1 -name "${basename}-*.*" \
		-mmin +$((60*24*$days_to_keep)) -type f \
		-exec rm -r {} \;

echo "Success - Files Removed ..."
exit
