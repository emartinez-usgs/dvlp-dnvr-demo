#!/bin/bash


while [ 1 ]; do
  status=$(docker container ls \
    --filter 'Name=demo-healthcheck' \
    --format 'ID: {{.ID}}\nImage: {{.Image}}\nStatus: {{.Status}}\n'\
  );

  clear;
  printf "$status";
  sleep 1;
done

exit 0;
