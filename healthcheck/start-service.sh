#!/bin/bash

serviceName='demo-healthcheck';

docker service create \
  --name ${serviceName} \
  --update-order start-first \
  --publish 80 \
  --update-monitor 1s \
  local/demo/healthcheck:disabled \
;

docker service ls \
  --filter "NAME=${serviceName}" \
  --format "PortMap = {{.Ports}}" \
;

exit 0;