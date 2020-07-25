echo "!!!!!prepare mysql config"
service mysqld start
sleep 1
mysql -e "install plugin federated soname 'ha_federated.so'"
sed -i '/\[mysqld\]/a federated' /etc/my.cnf
service mysqld restart

echo "!!!!!this is modify standart sh goip_install_no_promt.sh (no confirm for install)"
cd /goip_install
./goip_install_no_promt.sh

echo "!!!!!this is modify standart sql-schema for sms-server with federated tables of database at host with main sql-server"
cat /goip_install/goip/goipinit_mod_fed.sql |
  sed "s/ChangeItMYSQL_MAIN_LOGIN/$MYSQL_MAIN_LOGIN/g" |
  sed "s/ChangeItMYSQL_MAIN_PASSWORD/$MYSQL_MAIN_PASSWORD/g" |
  sed "s/ChangeItMYSQL_MAIN_HOST/$MYSQL_MAIN_HOST/g" |
  sed "s/ChangeItMYSQL_MAIN_PORT/$MYSQL_MAIN_PORT/g" |
  sed "s/ChangeItMYSQL_MAIN_DB/$MYSQL_MAIN_DB/g" |
  sed '' > /goip_install/goip/goipinit_mod_fed_final.sql
mysql < /goip_install/goip/goipinit_mod_fed_final.sql

echo "!!!!!set our login and password for goip web admin"
GOIP_WEB_PASSWORD_MD5=`php -r "print(md5($GOIP_WEB_PASSWORD));"`
mysql -u$MYSQL_MAIN_LOGIN -p$MYSQL_MAIN_PASSWORD -h$MYSQL_MAIN_HOST --port=$MYSQL_MAIN_PORT --database $MYSQL_MAIN_DB -e "UPDATE user SET password=\"$GOIP_WEB_PASSWORD_MD5\" WHERE username='root'"
mysql --database goip -e "UPDATE user SET username=\"$GOIP_WEB_LOGIN\" WHERE username='root'"

echo "!!!!!run"
/usr/local/goip/run_goipcron

service httpd start
tail -f /dev/null
