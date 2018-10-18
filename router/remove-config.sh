#!/bin/bash -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 <APP_NAME>";
  exit -1;
fi

APP_NAME=$1;
SERVICE_NAME='router_nginx';

# Get configuration to be removed
CONFIGS=$(docker config ls \
    --filter name="router-server--${APP_NAME}--" \
    --filter name="router-config--${APP_NAME}--" \
  | grep -v 'NAME' \
  | awk '{print $2}'
);

# Detach configuration from service
DETACH_CONFIGS=();
for config in ${CONFIGS}; do
  DETACH_CONFIGS+="--config-rm ${config} ";
done

docker service update ${DETACH_CONFIGS[@]} ${SERVICE_NAME};

# Remove the configurations from server
docker config rm ${CONFIGS};

exit 0;
