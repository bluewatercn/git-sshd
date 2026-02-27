FROM alpine:latest
COPY entrypoint.sh /
RUN chmod 777 /entrypoint.sh
RUN apk update && apk upgrade && apk add --no-cache curl bash vim git openssh-client openssh-server github-cli
ENV GITHUBTOKEN=''
ENV GITHUBEMAIL=''
ENV ROOT_PASSWORD=''
ENV SECRETPASSPHRASE=''
ENTRYPOINT ["/entrypoint.sh"]
