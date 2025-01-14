#!/usr/bin/env bash

docker stack rm shadowswarm
sleep 10
docker ps -a | grep shadowswarm | awk '{print $1}' | xargs -r docker rm -f
docker images | grep shadowswarm | awk '{print $3}' | xargs -r docker rmi -f
docker network ls | grep shadowswarm | awk '{print $1}' | xargs -r docker network rm
docker volume ls | grep shadowswarm | awk '{print $2}' | xargs -r docker volume rm
docker swarm leave --force
