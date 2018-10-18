FROM nginx

ARG APP_NAME='A'
ARG APP_VERSION='1'

COPY createIndex.sh /createIndex.sh
RUN /createIndex.sh ${APP_NAME} ${APP_VERSION}