#!/bin/bash

imageTag="${1:-disabled}";
serviceName='demo-healthcheck';

docker service update --force \
  --image local/demo/healthcheck:${imageTag} \
  ${serviceName} \
;

exit 0;
