#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

echo ""
echo ""
echo "Starting GoIP SMS System install "
echo ""
echo ""

if id | grep root > /dev/null
then
        :
else
        echo "You must be root to install these tools."
        exit 1
fi

if [ ! -d goip ]
then
    echo "Please change goip_install directory "
    exit 1
fi
######Identify if this is a Ubuntu/Debian system##########
if grep -i -E 'ubuntu|debian' /etc/*release* > /dev/null
then 
    DISTRIBUTION=DEB
    APACHE_PATH="/etc/apache2/sites-enabled"
    [ ! -L /var/lib/mysql/mysql.sock ] && ln -s /var/run/mysqld/mysqld.sock /var/lib/mysql/mysql.sock  
elif grep -i -E 'CentOS Linux release 7' /etc/*release* > /dev/null
then 
    DISTRIBUTION=centos7
    APACHE_PATH="/etc/httpd/conf.d"
    chmod +x /etc/rc.d/rc.local
else
    APACHE_PATH="/etc/httpd/conf.d"
fi
########################################################
HTTP_PATH=$APACHE_PATH

if [ ! -d ${HTTP_PATH} ]
then
    echo "${HTTP_PATH} do not exist"
    exit 1
fi

MYSQL_PATH="/usr/bin/mysql"
################ Detect if the DATABASE goip exits already ###########
if ${MYSQL_PATH} -u root $MY_PRA -e "show databases;" | grep goip > /dev/null
then
    echo -e "\033[31mthe SMS SERVER's DATABASE \"goip\" already exists.\033[0m"
    echo -e "\033[31mAre you sure to override the DATABASE? !!! All data of this DATABASE \"goip\" will be erasured if you do this !!!\033[0m"
    echo "Enter \"yes\" or \"no\":"
    read OVERRIDE
    case "$OVERRIDE" in
    [Yy][Ee][Ss]) ${MYSQL_PATH} -u root $MY_PRA < goip/goipinit.sql;;
    [Nn][Oo])  echo "exit." && exit;;
    *)   echo "Please enter \"yes\" or \"no\"." && exit;;
    esac
else
    mysql < goip/goipinit.sql
fi
###################################################################### 


if [ $? = "0" ]
then
    :
else
    echo "Mysql Database error"	
    exit 1
fi


echo '
Alias /goip "/var/www/goip"
<Directory "/var/www/goip">
    Options FollowSymLinks Indexes MultiViews
    AllowOverride None
    Order allow,deny
    Allow from all
</Directory>
' > $HTTP_PATH/goip.conf
echo "Copying file to /usr/local/goip"
if ps aux | grep "goipcron" | grep -v "grep" > /dev/null
then
    killall goipcron
fi
cp -r goip /usr/local/
chmod -R 777 /usr/local/goip
[ ! -L "/var/www/goip" ] && ln -s /usr/local/goip /var/www/goip

[ -f "/etc/conf.d/local.start" ] && local="/etc/conf.d/local.start";
[ -f "/etc/rc.d/rc.local" ] && local="/etc/rc.d/rc.local"
[ -f "/etc/rc.local" ] && local="/etc/rc.local"


rclocaltmp=`mktemp /tmp/rclocal.XXXXXXXXXX`

if grep -q "goipcron" $local
then
        sed /goip/d $local > $rclocaltmp
        cat $rclocaltmp > $local
        rm -f $rclocaltmp
fi

if grep -q "^exit 0$" $local
then
    sed -i '/exit\ 0/i\/usr\/local\/goip\/run_goipcron' /etc/rc.local
else
    echo "/usr/local/goip/run_goipcron" >>$local
fi
#/usr/local/goip/run_goipcron

echo "Install finished."
echo "Please restart your httpd"
echo "SMS SERVER management URL: http://your_ip/goip"
