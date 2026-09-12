#!/bin/bash
URL1="${SERVER1}"
PORT="${PORT}"
rcp -P $PORT -i ~/.ssh/router_key $1 root@$URL1:/mnt/data/tmp_upload/

