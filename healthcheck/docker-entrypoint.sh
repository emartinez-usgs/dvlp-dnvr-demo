#!/bin/bash -e

# Forward signals to child process
_term () {
  echo 'Caught SIGTERM';
  kill -TERM "$child";
}
trap _term SIGTERM;

# Simulate some startup time required for service to become healthy.
# This might be a dependent database starting up, or some other initialization
# process that takes some time. The service is not technically healthy
# until it can start properly responding to requests.
echo 'Initializing';
sleep 10;

# Start NGINX
nginx -g "daemon off;" &
echo 'NGINX Started';

# Block until NGINX stops
child=$!;
wait "${child}";

exit 0;