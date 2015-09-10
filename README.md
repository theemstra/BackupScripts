BackupScripts
=============
A set of small scripts that will provide backups, including the rotation of the backups.

How to use this?
=============
Use the cronjob system to schedule the scripts usage, you could use the cronic system to get notified of possible warnings and errors.

The server directory is to be used on the machine that has to be backed-up.
The remote directory is to be used on the machine(s) that store the backup files.

If you wish to use Amazon Web Services Simple Storage (S3) or another storage platform, you can add those at the bottom of the sysbackup.sh file.
Use your S3 bucket interface to set up versioning to archive or store multiple versions and remove versions older than x days.
An example has been added for AWS S3. To use this feature you need to have the s3cmd package, more information: http://s3tools.org/s3cmd

License
=============

This software is developed by XSbyte (www.xsbyte.com) and is released under the GNU GENERAL PUBLIC LICENSE V2 license.

The scripts carry the following copyright:
Copyright XSbyte 2010-2015

Contact
=============
Ideas and PR's welcome!
Contact me on thom AT heemstra.us
