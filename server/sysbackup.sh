#!/bin/bash
# Backup & Rotation Scripts
# Copyright 2010-2015 by XSbyte
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
# @copyright   2010-2015 by XSbyte | http://www.xsbyte.com
# @author      Thom Heemstra <thom@heemstra.us>
# @license     http://www.gnu.org/licenses/gpl-2.0.html GPL v2

#
##
## Edit the config section below to fit your needs.
## Simply comment out the 2nd remote at the bottom of the script to disable it.
## By default some folders are being backed-up, as well as all MySQL databases.
##
#

###### Config ######
## Your backup name
backupname="{YOUR BACKUP NAME}"

## Where we'll prepare the backup for packaging
spooler="/var/spool/backup-prepare/system/"

## Your remote server hostname(s)
host[0]="myserver.sys.mycompany.tld"
host[1]="mysecond.sts.mycompany.tld"

## Your remote server locations (Comment one out if you only use one)
remote[0]="root@${HOST[0]}:/home/backups/${backupname}/"
remote[1]="root@${HOST[1]}:/volume1/Backups/${backupname}"

## Your SSH ports (22 by default)
sshport[0]="22"
sshport[1]="9901"

## Where is the remote rotations script located?
remoterotate[0]="root@{YOUR_HOST1} /root/scripts/backup/${backupname}-rotate.sh"
remoterotate[1]="root@{YOUR_HOST2} /volume1/Backups/scripts/${backupname}-rotate.sh"

## Your database password if you do not have automatic mysql sign-in set up (leave empty if you have it set up)
## It is not recommended to put your root password in here, because it would be readable via top and ps ax.
DB_PASSWORD="YOUR_PASSWORD"

####################


## We're checking if the folders exist, if not, let's create them
if [ ! -d ${spooler} ]; then
        mkdir -p ${spooler}
fi
if [ ! -d ${spooler}part/conf ]; then
        mkdir -p ${spooler}part/conf
fi
if [ ! -d ${spooler}part/db ]; then
        mkdir -p ${spooler}part/db
fi

## Add folders you would like to be backed-up here
tar -cpzf ${spooler}part/conf/proftpd.tar.gz -C / etc/proftpd
tar -cpzf ${spooler}part/conf/postfix.tar.gz -C / etc/postfix
tar -cpzf ${spooler}part/conf/dovecot.tar.gz -C / etc/dovecot
tar -cpzf ${spooler}part/conf/apache.tar.gz -C / etc/apache2
tar -cpzf ${spooler}part/conf/bind.tar.gz -C / etc/bind
tar -cpzf ${spooler}part/conf/imscp.tar.gz -C / etc/imscp
tar -cvf ${spooler}part/conf.tar -C ${spooler}part/conf .
rm ${spooler}part/conf/*
rmdir ${spooler}part/conf

## Add your custom locations or backup instructions here
## An example is added where we would like to exclude extra backups (they are sql.bz2 files)
tar -cpz --warning=no-file-changed --warning=no-file-removed -f ${spooler}part/var-www.tar.gz -C / var/www --exclude='*.sql.bz2' --exclude='*.tar.bz2'
tar -cpz --warning=no-file-changed --warning=no-file-removed -f ${spooler}part/root.tar.gz -C / root
tar -cpz --warning=no-file-changed --warning=no-file-removed -f ${spooler}part/mail.tar.gz -C / var/mail

## Before we're going to pack, let's optimize the databases
mysqlcheck -u root -p --auto-repair --optimize --all-databases | grep -v ^performance_schema$

## Let's loop through all databases and pack them
for dbname in `mysql --password=${DB_PASSWORD} --batch -e \
         "show databases" | grep -v ^performance_schema$ | grep -v "mysql" | grep  -v "test" | tail -n +3`
do
        mysqldump $dbname --password=${DB_PASSWORD} | gzip > ${spooler}part/db/${dbname}.sql.gz
done
tar -cf ${spooler}part/db.tar -C ${spooler}part/db .

rm ${spooler}part/db/*
rmdir ${spooler}part/db

rm ${spooler}${backupname}.tar

tar -cf ${spooler}${backupname}.tar -C ${spooler}part .
rm ${spooler}part/*

## Now let's upload it to server 0
scp -P ${sshport[0]} ${spooler}${backupname}.tar ${remote[0]}
ssh -p ${sshport[0]} ${remoterotate[0]} ${backupname}.tar 10 ${backupname}

## Now let's upload it to server 1
## Comment 2 lines below out if only one server is in use
scp -P ${sshport[1]} ${spooler}${backupname}.tar ${remote[1]}
ssh -p ${sshport[1]} ${remoterotate[1]} ${backupname}.tar 10 ${backupname}
