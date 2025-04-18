#!/bin/bash

# turn on bash's job control
set -m

if [ ! -f "/opt/observium/discovery.php" ]; then
  echo "Checking out stable Observium susbcription version from SVN"
  svn co --username $SVN_USERNAME --password $SVN_PASSWORD https://svn.observium.org/svn/observium/branches/stable /opt/observium
else
  echo "Observium directory already exists, skipping SVN checkout"
fi

#######
# clean old pid and "fix" cron
find /var/run/ -type f -iname \*.pid -delete
touch /etc/crontab /etc/cron.d/observium /etc/cron.d/php

# observium data and logs
mkdir -p /config/logs && mkdir -p /config/rrd
rm -rf /opt/observium/logs /opt/observium/rrd
ln -s /config/logs /opt/observium/logs
ln -s /config/rrd /opt/observium/rrd
chown www-data:www-data /config/logs -R
chown www-data:www-data /config/rrd  -R
# cache
mkdir -p /tmp/observium_cache
chown www-data:www-data /tmp/observium_cache -R

# move voltagepark customizations
if [ ! -d "/opt/observium/includes/definitions/mibs/voltagepark/" ]; then
  mkdir /opt/observium/includes/definitions/mibs/voltagepark/
fi
if find /opt/observium-voltagepark/includes/definitions/mibs -mindepth 1 -maxdepth 1 | read; then
  mv /opt/observium-voltagepark/includes/definitions/mibs/* /opt/observium/includes/definitions/mibs/voltagepark/
fi

if [ ! -d "/opt/observium/mibs/voltagepark/" ]; then
  mkdir /opt/observium/mibs/voltagepark/
fi
if find /opt/observium-voltagepark/mibs -mindepth 1 -maxdepth 1 | read; then
  mv /opt/observium-voltagepark/mibs/* /opt/observium/mibs/voltagepark/
fi


if test -v OBSERVIUM_ALLCONFIG; then
  echo "<?php" > /opt/observium/config.php
  echo $OBSERVIUM_ALLCONFIG | base64 -d >> /opt/observium/config.php
  echo "?>" >> /opt/observium/config.php
else
  #######
  # ENVIRONMENT to CONFIG
  echo "<?php" > /opt/observium/config.php
  while IFS= read -r line
  do
    var=`echo $line | cut -d = -f 1 |sed "s/OBSERVIUM_/['/g" | sed "s/__/']['/g" | sed "s/$/']/g" `
    value=`echo $line | cut -d = -f 2- `
    case $value in
      1|0|TRUE|FALSE|\"*|\'*) echo "\$config$var=$value;" >> /opt/observium/config.php ;;
      *) echo "\$config$var=\"$value\";" >> /opt/observium/config.php ;;
    esac
  done < <(printenv | egrep ^OBSERVIUM_ | sort -u)
  echo "?>" >> /opt/observium/config.php
fi

#######
if test -v OBSERVIUM_db_host; then
  while ! mysqladmin ping -h"$OBSERVIUM_db_host" --silent; do
  	echo "Waiting... $OBSERVIUM_db_host not is alive..."
      sleep 5
  done
fi

# Initial Setup
cd /opt/observium
# Setup the MySQL database and insert the default schema
./discovery.php -u

if test -v OBSERVIUM_ADMIN_USER; then
  # add user
  ./adduser.php $OBSERVIUM_ADMIN_USER $OBSERVIUM_ADMIN_PASS 10
  #####
fi

# import devices
if [ -e /config/hosts  ]; then
	cat /config/hosts >> /etc/hosts
	while read -r line; do
		device=`echo $line | awk '{ print $2 }'`
		./add_device.php $device
	done < /config/hosts
fi

if [ -e /config/devices  ]; then
 	./add_device.php /config/devices
fi

#######
# timezone
if test -v TZ && [ `readlink /etc/localtime` != "/usr/share/zoneinfo/$TZ" ]; then
  if [ -f /usr/share/zoneinfo/$TZ ]; then
    echo $TZ > /etc/timezone
    rm /etc/localtime
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
    dpkg-reconfigure -f noninteractive tzdata
    echo "date.timezone=$TZ" > /etc/php/8.3/apache2/conf.d/99_datatime.ini
  fi
fi

#you can run cron in another container
if test -v OBSERVIUM_DISABLECRON; then
  # disable cron in supervisor
  sed -i 's/autostart=true/autostart=false/g' /etc/supervisord.conf
  #####
fi

####################################3
supervisord -c /etc/supervisord.conf