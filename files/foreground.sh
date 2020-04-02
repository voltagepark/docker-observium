#!/bin/bash

# 
[ -z $OBSERVIUM_DB_HOST ] && OBSERVIUM_DB_HOST=localhost
[ -z $OBSERVIUM_DB_USER ] && OBSERVIUM_DB_USER=observium
[ -z $OBSERVIUM_DB_PASS ] && OBSERVIUM_DB_PASS=observium
[ -z $OBSERVIUM_DB_DB ] && OBSERVIUM_DB_DB=observium
[ -z $OBSERVIUM_ADMIN_USER ] && OBSERVIUM_ADMIN_USER=admin
[ -z $OBSERVIUM_ADMIN_PASS ] && OBSERVIUM_ADMIN_PASS=admin

#
mkdir -p /config/logs && mkdir -p /config/rrd 
rm -rf /opt/observium/logs /opt/observium/rrd 
ln -s /config/logs /opt/observium/logs 
ln -s /config/rrd /opt/observium/rrd 
chown www-data:www-data /config/logs 
chown www-data:www-data /config/rrd 

#
if [ ! -e /config/config.php  ]; then 
	cp /opt/observium/config.php.* /config/config.php 
	rm -rf /opt/observium/config.php
	ln -s /config/config.php /opt/observium/config.php 
	sed -i "s/'localhost'/getenv\('OBSERVIUM_DB_HOST'\)/g" /config/config.php 
	sed -i "s/'USERNAME'/getenv\('OBSERVIUM_DB_USER'\)/g" /config/config.php 
	sed -i "s/'PASSWORD'/getenv\('OBSERVIUM_DB_PASS'\)/g" /config/config.php 
	sed -i "s/'observium'/getenv\('OBSERVIUM_DB_DB'\)/g" /config/config.php 
fi

while ! mysqladmin ping -h"$OBSERVIUM_DB_HOST" --silent; do
	echo "$OBSERVIUM_DB_HOST not is alive... "
    sleep 1
done

cd /opt/observium 
# Setup the MySQL database and insert the default schema
./discovery.php -u
# add user
./adduser.php $OBSERVIUM_ADMIN_USER $OBSERVIUM_ADMIN_PASS 10
# Perform Initial Discovery and Poll
./discovery.php -h all
./poller.php -h all

#
read pid cmd state ppid pgrp session tty_nr tpgid rest < /proc/self/stat
trap "kill -TERM -$pgrp; exit" EXIT TERM KILL SIGKILL SIGTERM SIGQUIT
# cron
# export env 
printenv | egrep OBSERVIUM | sed 's/^\(.*\)$/export \1/g' > /etc/cron.env
chmod 500 /etc/cron.env
# start up cron
/usr/sbin/cron 
# start up apache
source /etc/apache2/envvars
exec apache2 -D FOREGROUND
