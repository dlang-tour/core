#!/bin/bash
# remove old, untagged docker images
docker images --no-trunc | grep '<none>' | awk '{ print $3 }' | xargs -r docker rmi
# remove old containers
docker rm $(docker ps -q -f status=exited)
# update existing images
docker images |grep -v REPOSITORY|awk '{print $1":"$2"\n"}' | xargs -l docker pull
