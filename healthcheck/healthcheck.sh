#!/bin/bash -e

host=$(hostname -i || echo 'localhost');
port="${port:-80}";

args=(
  -s
  -o /dev/null
  -w '%{http_code}'
  -A 'Internal Healthcheck'
  "http://${host}:${port}/"
);

http_code=$(curl "${args[@]}");
result=$?;

if [[ $result -eq 0 && $http_code -eq 200 ]]; then
  echo '[HEALTHCHECK] Webserver up and healthy.';
  exit 0;
else
  echo '[HEALTHCHECK] Webserver not healthy.';
  exit -1;
fi