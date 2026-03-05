#!/usr/bin/env bash
set -eu

docker build -t my .
docker run -d --name test --env-file env.txt my
