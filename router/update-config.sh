#!/bin/bash -e

if [ $# -ne 3 ]; then
  echo "Usage: $0 <APP_NAME> <CONF_FILE> <SERVER_FILE>";
  exit -1;
fi

APP_NAME=$1;
CONF_FILE=$2;
SERVER_FILE=$3;
UNIQUE_ID="$(date '+%s')-$$";
SERVICE_NAME='router_nginx';

if [ ! -f ${CONF_FILE} ]; then
  echo "No such file: '${CONF_FILE}'";
  exit -1;
fi

if [ ! -f ${SERVER_FILE} ]; then
  echo "No such file: '${SERVER_FILE}'";
  exit -1;
fi

# Get current configuration to be removed later
OLD_CONFIGS=$(docker config ls \
    --filter name="router-server--${APP_NAME}--" \
    --filter name="router-config--${APP_NAME}--" \
  | grep -v 'NAME' \
  | awk '{print $2}'
);

# Create new configurations
SERVER_CONFIG="router-server--${APP_NAME}--${UNIQUE_ID}";
CONFIG_CONFIG="router-config--${APP_NAME}--${UNIQUE_ID}";

docker config create ${SERVER_CONFIG} ${SERVER_FILE} > /dev/null 2>&1;
docker config create ${CONFIG_CONFIG} ${CONF_FILE} > /dev/null 2>&1;

# Update running service, remove old configs, add new configs
DETACH_CONFIGS=();
for old in ${OLD_CONFIGS}; do
  DETACH_CONFIGS+="--config-rm ${old} ";
done

docker service update \
  ${DETACH_CONFIGS[@]} \
  --config-add \
    source=${SERVER_CONFIG},target=/etc/nginx/conf.d/${APP_NAME}.server \
  --config-add \
    source=${CONFIG_CONFIG},target=/etc/nginx/conf.d/${APP_NAME}.conf \
  ${SERVICE_NAME};

# Previous command blocks until service converges, if this gets backgrounded,
# maybe we should wait here until done, but currently safe to move forward

# Remove old configs
if [ -n "${OLD_CONFIGS}" ]; then
  docker config rm ${OLD_CONFIGS};
fi

exit 0;