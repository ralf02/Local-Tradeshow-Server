#!/bin/bash

## BACKUP ##

MAIN_PATH=/var/www/my.drupal.ca
USER_PATH=/home/UserTradeShowServer
DATE=$(date +'%Y-%m-%d-%H-%M-%S')
echo "### INIT BACKUPS ${DATE}"

echo "###"

echo "### SITE BACKUP db-backup.sql.gz"
cd $MAIN_PATH/public_html
drush sql-dump --gzip > $USER_PATH/db-backup.sql.gz

echo "### SITE BACKUP site-backup.tar.gz"
mkdir $USER_PATH/tmp
cd $MAIN_PATH
tar -czvf $USER_PATH/tmp/site-backup.tar.gz --exclude=public_html/sites/default/files/* public_html
cd $USER_PATH/tmp
tar -xzvf site-backup.tar.gz
chmod -R 777 public_html
tar -czvf $USER_PATH/site-backup.tar.gz public_html
rm -rf $USER_PATH/tmp

echo "### LIST FILES "
ls -lah $USER_PATH

DATE=$(date +'%Y-%m-%d-%H-%M-%S')
echo "### FINISH BACKUPS ${DATE}"
