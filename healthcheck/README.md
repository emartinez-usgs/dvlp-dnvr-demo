# Healthcheck Demo

This demo shows how the default container health check (checking the
process PID=1 is running) is insufficient. This could be caused by the
processes needing some time to initialize, or it may depend on other
processes/services in order to be fully functional.

## Prerequisites

The system running the demo must have cURL and Docker installed.

The docker engine should have a `local/demo/healthcheck:disabled` and a
`local/demo/healthcheck:enabled` image. These can be built using the
`Dockerfile` in this directory. The `HEALTHCHECK` instruction in that file
should be commented out for the `:disabled` variant.

## Setup

Open three terminal windows and navigate to this directory. We will call these
the "Manager", "Service Polling", and "Container Inspector" windows.

In the Manager window, start the service using `./start-service.sh`. This
starts an NGINX server and exposes a port on the host OS. This port is echo'd
back for the next step.

In the Service Polling window, start the poller with `./poll-service.sh <PORT>`
where `<PORT>` is the exposed port number that was reported from the startup
script. This process will continually make HTTP requests to the service and
report success/error status.

In the Container Inspector window, start the container inspector with
`./watch-containers.sh`. This process will continually check for running
containers and report some status information.

With both the polling and inspecting processing running, back in the Manager
window, update the service using `./update-service.sh`. Note the docker engine
immediately thinks the new replica is healthy even though NGINX is not yet
serving responses. This results in the polling task reporting errors until
the NGINX actually becomes available.

In the Manager window, update the service again, but this time switch on
the healthcheck. This can be done with: `./update-service.sh enabled`. Note
the docker engine waits for the service to become healthy. The Container
Inspector window reports two containers running, one healthy and one starting.
Note the Service Polling window does not report any errors.

Stop the polling processes and close terminal windows to conclude the demo.
