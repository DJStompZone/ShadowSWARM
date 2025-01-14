#!/usr/bin/env bash

# In theory, this should work identically as a powershell script or a bash script

docker build -t shadowswarm-app . ; docker push djstomp/shadowswarm-app:latest ; docker tag shadowswarm-app:latest djstomp/shadowswarm-app:latest
