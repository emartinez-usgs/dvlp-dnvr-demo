FROM nginx

RUN apt-get update && \
  apt-get install -y curl && \
  apt-get clean

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY healthcheck.sh /healthcheck.sh

# HEALTHCHECK \
#   --interval=1s \
#   --timeout=1s \
#   --start-period=15s \
#   --retries=1 \
#   CMD \
#   /healthcheck.sh

STOPSIGNAL SIGTERM
EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]