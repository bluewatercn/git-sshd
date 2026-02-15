FROM hermsi/alpine-sshd:latest
RUN sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 30/g' /etc/ssh/sshd_config
RUN apk add --no-cache vim git
