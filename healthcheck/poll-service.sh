#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $0 port";
  exit -1;
fi

port=$1;

while [ 1 ]; do
  curl \
    -I -s \
    --max-time 1 \
    http://localhost:${port}/ \
  | egrep '(HTTP|Date)' \
  || (echo 'Request Failed' && date);

  echo '';
  sleep 1;
done