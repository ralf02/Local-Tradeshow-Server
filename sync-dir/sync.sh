#!/bin/bash

## BACKUP DIR FORMAT ##
DATE_START=$(date +'%Y-%m-%d-%H-%M-%S')
DATE_SEG=$(date +"%s")
echo "### INIT SYNC ${DATE_START}"

until mysql -u$MYSQL_USER -p$MYSQL_PASS -h$MYSQL_HOST --execute "quit"; do
  >&2 echo "---> MYSQL IS UNAVAILABLE - SLEEPING..."
  sleep 1
done

echo "---> MYSQL IS AVAILABLE"

SYNC_DIR="/sync-dir"
FILE_DATABASE="db-backup.sql"
FILE_DB="$FILE_DATABASE.gz"
FILE_SITE="site-backup.tar.gz"
SITE_DIR="/var/www/html"
MODULE_DRUPAL=get_product_videos


fnDownloadVideosYoutube(){
    echo "### DOWNLOADING VIDEOS YOUTUBE $MODULE_DRUPAL & PDF files"
    cd $SYNC_DIR
    php YoutubeDownload/download.php
}

fnCopyMediaFilesS3(){
    echo "### COPYING S3 MEDIA FILES TO /sites/default/files"
    mkdir -p $SITE_DIR/sites/default/files
    cp -r $SYNC_DIR/s3/files/* $SITE_DIR/sites/default/files
    chmod -R 777 $SITE_DIR/sites/default/files
}

fnDownloadMediaFiles(){
    echo "### DOWNLOADING MEDIA FILES FROM S3"
    mkdir -p $SYNC_DIR/s3/files
    aws s3 sync s3://${AWS_MYBUCKET} $SYNC_DIR/s3/files --exclude="*.pdf" --exclude="*.gz" --exclude="*.xlsx"
    fnCopyMediaFilesS3
}

fnVerifyModuleCustom(){
    echo "### VERIFYING MODULE CUSTOM $MODULE_DRUPAL ..."

    cp -r $SYNC_DIR/$MODULE_DRUPAL $SITE_DIR/modules/
    cd $SITE_DIR

    IS_MOD_ENABLED=$(drush pm:list --type=module --status=enabled | grep $MODULE_DRUPAL)
    IS_MOD_ENABLED=`echo $IS_MOD_ENABLED | sed 's/ *$//g'`

    echo "  IS_MOD_ENABLED -->$IS_MOD_ENABLED<--"

    if [ -z "$IS_MOD_ENABLED" ]
    then
        echo "  MODULE CUSTOM $MODULE_DRUPAL IS NOT INSTALLED, INSTALLING..."
        drush en $MODULE_DRUPAL
    else
        echo "  MODULE CUSTOM $MODULE_DRUPAL IS INSTALLED, REINSTALLING..."
        drush pmu $MODULE_DRUPAL
        drush en $MODULE_DRUPAL
    fi
}

fnDownloadCoreFiles(){
    echo "### DOWNLOADING FILES -> $FILE_DB - $FILE_SITE INTO sync-dir by FTP"
    lftp -u $USER_FTP,$PASS_FTP $HOST_FTP << EOF
set sftp:auto-confirm yes
cd /
lcd sync-dir/tmp
mget $FILE_DB $FILE_SITE
bye
EOF

}

fnSynCoreSite(){
    cp -r $SYNC_DIR/tmp/$FILE_DB $SYNC_DIR/
    cp -r $SYNC_DIR/tmp/$FILE_SITE $SYNC_DIR/

    cd $SYNC_DIR

    if [[ -f $SYNC_DIR/$FILE_SITE ]]; then
        echo "### UNCOMPRESSING FILES..."
        tar -xzf $FILE_SITE

        echo "  # COPYING FILES LOCAL DIRECTORY -> $SITE_DIR"
        rm -rf $SITE_DIR/*
        cp -r public_html/* $SITE_DIR
        chmod -R 777 $SITE_DIR/sites/default
        cp /opt/settings.php  $SITE_DIR/sites/default
        cp /opt/ConvertExcelToHTML.php  $SITE_DIR/modules/macdonmodule/src/Services

        echo "  # CHANGING PERMISSIONS TO XLSX FILE"
        cp -r $SYNC_DIR/file.xlsx $SITE_DIR/
        chmod 644 $SITE_DIR/file.xlsx

    else
        echo "### OMITTING UNCOMPRESS FILES..."
    fi
}

fnSynDbSite(){
    cp -r $SYNC_DIR/tmp/$FILE_DB $SYNC_DIR/
    cp -r $SYNC_DIR/tmp/$FILE_SITE $SYNC_DIR/

    cd $SYNC_DIR

    if [[ -f $SYNC_DIR/$FILE_DB ]]; then
        echo "### UNCOMPRESSING DATABASE"
        gunzip $FILE_DB
        cd $SITE_DIR
        drush st
        drush sql-drop -y
        echo "  # IMPORTING DATABASE..."
        drush sql-cli < /$SYNC_DIR/$FILE_DATABASE
    else
        echo "### OMITTING UNCOMPRESS & IMPORT DATABASE..."
    fi
}

fnCleaning(){
    echo "### CLEANING DRUPAL CACHE"
    cd $SITE_DIR
    drush cr

    echo "  #CLEANING TMP FILES"
    rm -rf $SYNC_DIR/$FILE_DATABASE $SYNC_DIR/public_html $SYNC_DIR/*.tar.gz $SYNC_DIR/tmp/*
}

fnSynSite(){
    fnDownloadCoreFiles

    if [[ -f $SYNC_DIR/tmp/$FILE_DB && -f $SYNC_DIR/tmp/$FILE_SITE ]]; then

        fnSynCoreSite

        fnSynDbSite

        fnVerifyModuleCustom

        fnDownloadVideosYoutube

        fnDownloadMediaFiles

        fnCleaning

    else
        echo "### FILES NOT FOUND $SYNC_DIR/tmp/$FILE_DB & $SYNC_DIR/tmp/$FILE_SITE"
        echo "### OMITTING..."
    fi
}

wget -q --spider https://my.drupal.ca/

if [ $? -eq 0 ]; then
    echo "  #Online"

    case $STATE in
        "sleep")
            echo "SATATE -> $STATE"
            sleep 200000
            exit 123
        ;;

        "all")
            echo "SATATE -> $STATE"
            fnSynSite
        ;;

        "core")
            echo "SATATE -> $STATE"
            fnDownloadCoreFiles
            fnSynCoreSite
            fnCleaning
        ;;

        "database")
            echo "SATATE -> $STATE"
            fnDownloadCoreFiles
            fnSynDbSite
            fnCleaning
        ;;

        "download_s3")
            echo "SATATE -> $STATE"
            fnDownloadMediaFiles
        ;;

        "copy_s3")
            echo "SATATE -> $STATE"
            fnCopyMediaFilesS3
        ;;

        "download_videos")
            echo "SATATE -> $STATE"
            fnDownloadVideosYoutube
        ;;

        "module")
            echo "SATATE -> $STATE"
            fnVerifyModuleCustom
        ;;

        *)
            echo "SATATE -> unknown"
        ;;
    esac

    rm -rf $SITE_DIR/newfile*
    echo "" > $SITE_DIR/log.log

else
    echo "  #Offline"
fi

DATE_END=$(date +'%Y-%m-%d-%H-%M-%S')
DATE_END_SEG=$(date +"%s")

let DIFF=$DATE_END_SEG-$DATE_SEG
let MINUTES=$DIFF/60

echo "### START SYNC ${DATE_START}"
echo "### END SYNC ${DATE_END}"
echo "##########################"
echo "***********************************************"
echo "******* THE SYNCHRONIZATION IS FINISHED *******"
echo "******** $MINUTES minutes elapsed aprox *******"
echo "***********************************************"
