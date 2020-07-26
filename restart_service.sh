#!/bin/bash

docker-compose stop -t0
docker-compose down
./goipinit_update_maindb_password.sh
docker-compose up -d
