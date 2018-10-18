#!/bin/bash

APP_NAME="${1:-A}";
APP_VERSION="${2:-1}";

mkdir -p /usr/share/nginx/html/${APP_NAME};

cat <<- EO_INDEX > /usr/share/nginx/html/${APP_NAME}/index.html
<!doctype html>
<html lang="en">

  <head>
    <title>${APP_NAME}: Version ${APP_VERSION}</title>
  </head>

  <body>
    <h1>${APP_NAME}: Version ${APP_VERSION}</h1>
  </body>

</html>
EO_INDEX