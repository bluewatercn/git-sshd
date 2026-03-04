FROM alpine:latest
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
RUN apk update && apk add --no-cache curl bash vim git openssh-client openssh-server github-cli  glab
WORKDIR /root
ENTRYPOINT ["/entrypoint.sh"]
