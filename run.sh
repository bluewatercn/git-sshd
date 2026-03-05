#!/usr/bin/env bash
set -eu

docker build -t my .
docker run -d --name test --evn-file env.txt my
