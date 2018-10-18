#!/bin/bash

docker stack deploy -c router.yml router;

cat <<- EO_STEP_ONE

The router stack has been deployed. Check http://localhost/ to verify a
simple NGINX service is running. Note that neither app-a
(http://localhost/app-a/) nor app-b (http://localhost/app-b/) is currently
serving any content.

The next step will deploy app-a version 1. Press <enter> to continue...
EO_STEP_ONE


read;
clear;

./deploy.sh app-a 1;

cat <<- EO_STEP_TWO

Application A version 1 is now deployed. Verify http://localhost/app-a/ now
serves responses successfully. Note this is the same as
http://localhost:SERVICE_PORT/app-a/, but in production, th SERVICE_PORT is
likely not publicly exposed. Take a look at "docker config ls" to see that
configuration has been added to the swarm in order to make the router aware
of the new application.

The next step will deploy app-b version 1. Press <enter> to continue...
EO_STEP_TWO

read;
clear;


./deploy.sh app-b 1;

cat <<- EO_STEP_THREE

Application B version 1 is now deployed. Verify http://localhost/app-b/ now
serves responses successfully. Note this is very similar to app-a but simply
shows that multiple applications can be deployed to a single router as expected.

THe next step will upgrade app-a to version 2. Press <enter> to continue...
EO_STEP_THREE

read;
clear;

./deploy.sh app-a 2;

cat <<- EO_STEP_FOUR
Application A has been upgraded to version 2. Verify this in the browser. This
concludes the demonstration. Press <enter> to remove deployed applications and
the router itself...
EO_STEP_FOUR

read;
clear;

./remove.sh app-a;
./remove.sh app-b;

docker stack rm router;

echo 'Demo complete. Normal exit.';
exit 0;