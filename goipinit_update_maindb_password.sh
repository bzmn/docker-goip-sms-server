#!/bin/bash

COMPOSEFILE="./docker-compose.yml"
GOIPSQLFILE="./goipinit.sql"
PASSWORD=$1

if [ ! -f $COMPOSEFILE ] || [ ! -f $GOIPSQLFILE ]; then
  echo "not all files exist"; exit
fi

MYSQL_MAIN_LOGIN=`cat $COMPOSEFILE | grep 'MYSQL_MAIN_LOGIN=' | awk -F'=' {'print $2'}`
MYSQL_MAIN_PASSWORD=`cat $COMPOSEFILE | grep 'MYSQL_MAIN_PASSWORD=' | awk -F'=' {'print $2'}`
MYSQL_MAIN_DB=`cat $COMPOSEFILE | grep 'MYSQL_MAIN_DB=' | awk -F'=' {'print $2'}`

cat $GOIPSQLFILE | grep "IDENTIFIED BY" |
  sed "s/GRANT all ON goip.* TO goip@localhost IDENTIFIED BY 'goip'/GRANT all ON $MYSQL_MAIN_DB.* TO $MYSQL_MAIN_LOGIN@'%' IDENTIFIED BY '$MYSQL_MAIN_PASSWORD'/" |
  sed '' | mysql
