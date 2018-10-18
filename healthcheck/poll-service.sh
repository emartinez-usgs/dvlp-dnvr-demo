#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $0 port";
  exit -1;
fi

port=$1;

while [ 1 ]; do
  output=$(curl \
    -I -s \
    --max-time 1 \
    http://localhost:${port}/ \
  | egrep '(HTTP|Date)' \
  || (echo 'Request Failed' && date));

  printf "${output}\n\n";
  sleep 1;
done