#!/bin/bash -e

export APP_NAME="${1:-app-a}";
export APP_VERSION="${2:-1}";

SERVICE_MAP=(
  "/${APP_NAME}:nginx"
);

TARGET_HOSTS=(
  $(ifconfig en0 inet | grep inet | awk '{print $2}')
);

pushd $(dirname $0) > /dev/null 2>&1;

# Include functions
source './functions.sh';

# Deploy the stack
preStackDeployHook;

docker stack deploy \
  --prune \
  --with-registry-auth \
  --resolve-image always \
  -c app.yml \
  ${APP_NAME};

deployed=$(waitForStackHealthy $APP_NAME);

if [ $deployed ]; then
  echo "## The ${APP_NAME} stack is healthy!";
else
  echo "## The ${APP_NAME} stack failed to deploy. Failing.";
  exit -1;
fi

postStackDeployHook;

# Service discovery
updateRouting $APP_NAME "${SERVICE_MAP[@]}";


popd > /dev/null 2>&1;
exit 0;
