#!/bin/bash

APP_NAME="${1:-app-a}";

source './functions.sh';

routerConfig --remove ${APP_NAME};
docker stack rm ${APP_NAME};

exit 0;