#!/bin/bash

ocdir=/nextcloud

# update alpine
apk update && apk upgrade
rm -rf /var/cache/apk/*

#use external defined service
if [ -n "$MYSQL_SERVICE_HOST" ]
then
 export MYSQL_DBHOST=$MYSQL_SERVICE_HOST
fi

if [ -e $ocdir/config/config.php ]
then
  # nothing to do here
  echo "nextcloud is allready installed!"

else
  # run install
until  php  $ocdir/occ  maintenance:install --database "${DBTYPE:-mysql}" \
                                       --database-name "${MYSQL_DBNAME:-owncloud}" \
                                       --database-host "${MYSQL_DBHOST:-mysqldb}" \
                                       --database-user "${MYSQL_DBUSER:-root}" \
                                       --database-pass "${MYSQL_DBPASS:-password}" \
                                       --admin-user "${ADMIN:-admin}" \
                                       --admin-pass "${ADMINPASS:-password}"
do
  printf "."
  sleep 20
done
echo -e "\nmysql ready"
# enable default apps
#$ocdir/occ app:enable documents
#$ocdir/occ app:enable contacts
#$ocdir/occ app:enable calendar
$ocdir/occ app:enable files_external
fi


if [ -n "$OVERWRITEHOST" ]
then
  sudo -u nginx php7 $ocdir/occ config:system:set overwritehost --value=$OVERWRITEHOST
fi

if [ -n "$OVERWRITEPROTOCOL" ]
then
  sudo -u nginx  php7 $ocdir/occ config:system:set overwriteprotocol --value=$OVERWRITEPROTOCOL
fi

if [ -n "$WEB_ROOT" ]
then
  sudo -u nginx  php7 $ocdir/occ config:system:set overwritewebroot --value=$WEB_ROOT
fi

if [ -n "$OVERWRITECONDADDR" ]
then
  sudo -u nginx  php7 $ocdir/occ config:system:set overwritecondaddr --value=$OVERWRITECONDADDR
fi


if [ -n "$TRUSTED_DOMAIN1" ]
then
  sudo -u nginx php7 $ocdir/occ config:system:set trusted_domains 1 --value=$TRUSTED_DOMAIN1
fi



if [ -n "$TRUSTED_DOMAIN2" ]
then
  sudo -u nginx php7 $ocdir/occ config:system:set trusted_domains 2 --value=$TRUSTED_DOMAIN2
fi


if [ -n "$EXTERNAL_DOMAIN" ]
then
  sudo -u nginx php7 $ocdir/occ config:system:set overwrite.cli.url --value=$EXTERNAL_DOMAIN
fi


# fix rights for productivity
set_rights.sh ${ocdir}

mkdir -p /run/nginx

# go RUN!
php-fpm7
nginx &
tail -f $ocdir/data/nextcloud.log
