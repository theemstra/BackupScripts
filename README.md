BackupScripts
=============
A set of small scripts that will provide backups, including the rotation of the backups.

How to use this?
=============
Use the cronjob system to schedule the scripts usage, you could use the cronic system to get notified of possible warnings and errors.

The server directory is to be used on the machine that has to be backed-up.
The remote directory is to be used on the machine(s) that store the backup files.

Uploading the backups
=============
The examples have code that allow uploading your backups to Web Services Simple Storage (S3) and BackBlaze Buckets (B2).
If you wish to use Amazon Web Services Simple Storage (S3), BackBlaze Buckets (B2) or another storage platform, you can add those at the bottom of the sysbackup.sh file.

Use your S3 bucket or B2 bucket interface to set up versioning to archive or store multiple versions and remove versions older than x days.

To use S3, install and configure the s3cmd package, more information: http://s3tools.org/s3cmd
To use B2, install and configure the b2 package, more information: https://www.backblaze.com/b2/docs/quick_command_line.html

License
=============

This software is developed by XSbyte (xsbyte.com) and is released under the GNU GENERAL PUBLIC LICENSE V2 license and have the following copyright:
© Copyright XSbyte 2010-2017. All rights Reserved.

Contact
=============
Ideas and PR's welcome!
Contact me on thom AT xsbyte.com
