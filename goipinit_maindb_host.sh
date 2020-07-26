#!/bin/bash

COMPOSEFILE="./docker-compose.yml"
GOIPSQLFILE="./goipinit.sql"

#README
#for new version of mysql set sql_mode='' in my.cnf conf after [mysqld] section
#В некоторых дистрах новый MySQL может быть в STRICT SQL mode.
#Это ознает, что при некоторых запросах, которые раньше вызывали в лучшем случае warning,
#но выполнялись, сейчас будет ошибка.
#Запросы гойпа не совсем соотвествуют структуре полей, некоторые колонки должны
# быть заполнены, но в запросах они не упоминаются. Это приводит к ошибкам
# при добавлении данных.
#Есть несколько способов отключить их. 
#Для нашего случая самый простой - в файле /etc/mysql/mysql.conf.d/mysqld.cnf
#в секции [mysqld]
#добавить строку 
#sql_mode=''
#(или отредактировать, если sql_mode уже указан в этой секции конфига)

#DB install RUN by root at host with DB!!!!

if [ `echo $1 |grep "^i_know_what_i_do$" | wc -l` -eq 0 ]; then
  echo "you don't know what are u doing (db will be droped)"; exit
fi
if [ ! -f $COMPOSEFILE ] || [ ! -f $GOIPSQLFILE ]; then
  echo "not all files exist"; exit
fi

MYSQL_MAIN_LOGIN=`cat $COMPOSEFILE | grep 'MYSQL_MAIN_LOGIN=' | awk -F'=' {'print $2'}`
MYSQL_MAIN_PASSWORD=`cat $COMPOSEFILE | grep 'MYSQL_MAIN_PASSWORD=' | awk -F'=' {'print $2'}`
MYSQL_MAIN_DB=`cat $COMPOSEFILE | grep 'MYSQL_MAIN_DB=' | awk -F'=' {'print $2'}`

cat $GOIPSQLFILE |
  sed "s/GRANT all ON goip.* TO goip@localhost IDENTIFIED BY 'goip'/GRANT all ON $MYSQL_MAIN_DB.* TO $MYSQL_MAIN_LOGIN@'%' IDENTIFIED BY '$MYSQL_MAIN_PASSWORD'/" |
  sed "s/DROP database IF EXISTS \`goip\`/DROP database IF EXISTS \`$MYSQL_MAIN_DB\`/" |
  sed "s/create database goip/create database $MYSQL_MAIN_DB/" |
  sed "s/use goip/use $MYSQL_MAIN_DB/" |
  sed '' | mysql
