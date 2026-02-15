FROM alpine:latest
COPY entrypoint.sh /
RUN chmod 777 /entrypoint.sh
RUN apk update && apk upgrade && apk add --no-cache bash vim git openssh-client openssh-server
ENTRYPOINT ["/entrypoint.sh"]
