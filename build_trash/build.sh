#!/bin/bash

#rm -r ./goip_install/
#exit

tar -xzf goip_install-v1.28.4.tar.gz
cp ./goip_install_no_promt.sh ./goip_install/goip_install_no_promt.sh
chmod +x ./goip_install/goip_install_no_promt.sh
cp ./goipinit_mod_fed.sql ./goip_install/goip/goipinit_mod_fed.sql
docker build -t goip-sms-server .
