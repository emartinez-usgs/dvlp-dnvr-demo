TRUTHY=${TRUTHY:-'true'};
FALSY=${FALSY:-''};
# Set to non-empty string to turn on debugging
DEBUG=${DEBUG:-${FALSY}};

##
# Prints the given message if debugging is currently turned on
#
# @param $1 message {String}
#     The message to print
##
debug () {
  if [ -n "${DEBUG}" ]; then
    # Log to stderr since stdout is gobbled up
    echo "[DEBUG $(date -u)] $1 " 1>&2;
  fi
}

##
# Checks if the named function exists in the current BASH context.
#
# @param $1 funcName {String}
#     The name of the function to check
#
# @return
#     ${TRUTHY} if the function exists, ${FALSY} otherwise.
##
functionExists () {
  local funcName=$1;
  local typeOf=$(type -t $funcName);
  local result=$?;

  if [[ $result -eq 0 && "${typeOf}" == 'function' ]]; then
    echo ${TRUTHY};
  else
    echo ${FALSY};
  fi
}

##
# @param $1 {String}
#     The action to perform. Either "--update", "--add", or "--remove".
# @param $@ {Mixed...}
#     Action-specific parameters to be passed to the underlying action.
#
##
if [ ! $(functionExists routerConfig) ]; then
routerConfig () {
  if [[ $1 == "--update" || "$1" == "--add" ]]; then
    GREP_FOR='router_update-config';
  elif [[ "$1" == "--remove" ]]; then
    GREP_FOR='router_remove-config';
  else
    echo "Usage: routerConfig [--add|--update|--remove] [args...]";
    exit -1;
  fi

  # Dump the first argument so we can pass everything else later
  shift;

  # Get the name of the configuration property containing the update code
  CONFIG_NAME=$(docker service inspect \
      --format '
        {{ range $i, $v := .Spec.TaskTemplate.ContainerSpec.Configs }}
          {{ println $v.ConfigName }}
        {{ end }}
      ' \
      router_nginx \
    | grep ${GREP_FOR}
  );

  # Get the configuration value
  CONFIG_SCRIPT=$(docker config inspect \
      --format '{{ json .Spec.Data }}' ${CONFIG_NAME} \
    | sed 's/"//g' \
    | base64 --decode
  );

  /bin/bash \
    -c "${CONFIG_SCRIPT}" \
    routerConfig \
    $@;
}
fi

##
# Updates the router project to point to the recently deployed stack
#
# @param $1 stackName {String}
#     The name of the stack to point to
##
if [ ! $(functionExists updateRouting) ]; then
updateRouting () {
  local stackName=$1; shift;
  local serviceMap=$@;

  local dir=$(dirname $0);
  local format='--format={{(index .Endpoint.Ports 0).PublishedPort}}';
  local stamp=$(date);

  local confFile="${dir}/${stackName}.conf";
  local serverFile="${dir}/${stackName}.server";

  debug "Re-routing traffic to ${stackName} stack.";
  echo "# Auto generated ${stamp} for ${stackName}" > $confFile;
  echo "# Auto generated ${stamp} for ${stackName}" > $serverFile;

  for service in ${serviceMap[@]}; do
    local name="${stackName}_$(echo $service | awk -F: '{print $2}')";
    local path="$(echo $service | awk -F: '{print $1}')";
    local port=$(docker service inspect "$format" $name 2> /dev/null);

    if [ -z "${port}" ]; then
      # No port exposed. Continue.
      debug "No port exposed for ${name}. Not routing. Moving on.";
      continue;
    fi

    echo "upstream ${name} {" >> $confFile;
    for host in ${TARGET_HOSTS[@]}; do
      echo "  server ${host}:${port};" >> $confFile;
    done
    echo "}" >> $confFile;

    cat <<- EO_SERVER_SNIP >> $serverFile
      location ${path}/ {
        proxy_pass http://${name};
        proxy_set_header Host localhost;
        proxy_set_header X-Client-IP \$remote_addr;
      }
		EO_SERVER_SNIP
    # ^^ Note: TAB indentation required

  done

  routerConfig --update ${stackName} ${confFile} ${serverFile};
  rm -f ${confFile} ${serverFile};
}
fi

##
# Waits for all stack services to become healthy after starting. This relies
# on each service replica to implement a meaningful HEALTHCHECK, otherwise
# "healthy" is equivalent to "running".
#
# @param $1 stackName {String}
#     The name of the stack that was removed.
#
##
if [ ! $(functionExists waitForStackHealthy) ]; then
waitForStackHealthy () {
  local stackName=$1;

  local complete=-1;
  local duration=0;
  local filter="--filter label=com.docker.stack.namespace=${stackName}";

  while [[ $complete -ne 0 && $duration -lt 60 ]]; do
    debug 'Waiting for services to become healthy...';
    sleep 5;
    let duration+=5;

    # Check each service in stack for health
    for status in $(docker service ls --format {{.Replicas}} ${filter}); do
      complete=$(echo $status | awk -F/ '{print $2 - $1}');

      if [ $complete -ne 0 ]; then
        # Found an unhealthy service, no need to keep checking. Keep waiting.
        break;
      fi
    done
  done

  # Show final service status(es)
  debug "$(docker service ls ${filter})";

  # Return the overall result
  if [ $complete -eq 0 ]; then
    echo ${TRUTHY};
  else
    echo ${FALSY};
  fi
}
fi

## ----------------------------------------------------------------------------
## Default lifecycle hooks. Only defined if not pre-defined by custom deploy
## pipeline scripts. These lifecycle hook functions each have full access
## to the current BASH execution context. Global variables, functions, etc...
## These lifecycle hooks should not expect any positional arguments.
## ----------------------------------------------------------------------------

##
# Lifecycle hook executed just prior to deploying the stack.
#
##
if [ ! $(functionExists preStackDeployHook) ]; then
  preStackDeployHook () {
    debug 'preStackDeployHook';
  };
fi

##
# Lifecycle hook executed after deploying the stack and it has become healthy.
#
##
if [ ! $(functionExists postStackDeployHook) ]; then
  postStackDeployHook () {
    debug 'postStackDeployHook';
  };
fi