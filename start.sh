#!/usr/bin/env bash
set -e
set -x


NAME=logstash
IMAGE=rednut/logstash
DATA_VOLUME=/docker/logstash:/data

docker stop $NAME || echo "not started yet"
docker rm -f $NAME || echo "not a container"


# #sudo docker rm -f logstash;
# docker run --name=logstash --link elasticsearch:ES -d -t -p 5043:5043 -p 10.9.1.9:514:514 -p 9292:9292 -p 25826:25826  rednut/logstash; docker logs -f logstash

LOGSTASH_CONTAINER=$(docker \
	run \
	-d \
	--name="$NAME" \
	--link elasticsearch-1:ES \
	--link redis:REDIS \
	-v $DATA_VOLUME \
	-p 5043:5043 \
	-p 5514:514 \
	-p 127.0.0.1:9292:9292 \
	-p 25826:25826 \
	-e LS_CONFIG_FILE='/data/config_server.d/*.conf' \
	$IMAGE)

echo CID=$LOGSTASH_CONTAINER
docker inspect $LOGSTASH_CONTAINER
docker logs -f $LOGSTASH_CONTAINER



	
