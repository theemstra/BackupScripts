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

#
##
## Edit the config section below to fit your needs.
## Simply comment out any parts you don't want to use.
## By default some folders are being backed-up, as well as all MySQL databases.
##
#

###### START CONFIG ######
## Your backup name
basename="{YOUR BACKUP NAME}"

## Where we'll prepare the backup for packaging
spooler="/var/spool/backup-prepare/system/"

## Your remote server hostname(s)
host[0]="backupserver.mycompany.tld"
host[1]="nas.mycompany.tld"

## Your remote server locations (Comment one out if you only use one)
remote[0]="root@${HOST[0]}:/home/backups/${basename}/"
remote[1]="root@${HOST[1]}:/volume1/Backups/${basename}"

## Your SSH ports (22 by default)
sshport[0]="22"
sshport[1]="9901"

## Where is the remote rotations script located?
remoterotate[0]="root@{YOUR_HOST1} /root/scripts/backup/rotate.sh"
remoterotate[1]="root@{YOUR_HOST2} /volume1/Backups/scripts/rotate.sh"

## Your database password if you do not have an option-file (http://dev.mysql.com/doc/refman/5.6/en/password-security-user.html)
## Leave "" if you have a option file set up
## WARNING: It is not recommended to put your password in here, because it would be readable via top and ps ax.
DB_PASSWORD="YOUR_PASSWORD"

### S3 configuration, uncomment the specific line at the end of the file to enable this feature
## It's important that S3cmd is installed and set up before using this feature.

## Your S3 bucket name 
S3BUCKET="mybackupbukket"
## Choose the path inside your bukket (Default: Empty) (END WITHOUT SLASH)
S3PATH=""
## Choose what chunk size each chunk sent to S3 should be (Default: "25")
CHUNKSIZE="25"

### B2 configuration, uncomment the specific line at the end of the file to enable this feature

## Where is B2 located? (you can comment out the command later)
b2_location="/usr/local/bin/b2"

## What will be your bucket name?
b2_bucket="backups"

## Authentication details for B2
bb_id="YOUR ACCOUNT ID"
bb_key="YOUR SECRET KEY"

###### END CONFIG ######

###### START BACKUP ######

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

## Add folders you would like to be backed-up here (example)
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

## Before we're going to pack, let's repair and optimize the databases
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

rm ${spooler}${basename}.tar

tar -cf ${spooler}${basename}.tar -C ${spooler}part .
rm ${spooler}part/*

## Now let's upload it to server 0
scp -P ${sshport[0]} ${spooler}${basename}.tar ${remote[0]}
ssh -p ${sshport[0]} ${remoterotate[0]} ${basename} 10

## Now let's upload it to server 1
## Comment 2 lines below out if only one server is in use
scp -P ${sshport[1]} ${spooler}${basename}.tar ${remote[1]}
ssh -p ${sshport[1]} ${remoterotate[1]} ${basename} 10

### External backup features; uncomment to enable. Make sure to install and configure (and test) before enabling.

## An example to store your backup at AWS S3 storage (install and configure s3cmd first) (http://s3tools.org/s3cmd)
#/usr/local/bin/s3cmd put ${spooler}${basename}.tar s3://${S3BUCKET}/${S3PATH}/${basename}.tar --multipart-chunk-size-mb=${CHUNKSIZE}

## An example to store your backup at BackBlaze B2 storage (install and configure b2 first) (https://www.backblaze.com/b2/docs/quick_command_line.html)
#${b2_location} authorize_account ${bb_id} ${bb_key}
#${b2_location} upload_file --noProgress --threads 1 ${b2_bucket} ${spooler}${backupname}-${TDAY}.tar ${backupname}.tar

###### END BACKUP ######
