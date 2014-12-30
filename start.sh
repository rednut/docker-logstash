#!/usr/bin/env bash
set -e
set -x


NAME=logstash
IMAGE=rednut/logstash
DATA_VOLUME=/docker/logstash:/data

docker stop $NAME || echo "not started yet"
docker rm -f $NAME || echo "not a container"

#	--link redis:REDIS \


LOGSTASH_CONTAINER=$(docker \
	run \
	-d \
	--name="$NAME" \
	--link elasticsearch-direct:ES \
	-e ES_HOST=es \
	-e ES_CLUSTER_NAME=rednut-dev \
	-e ES_WORKERS=2 \
	-e RAM=768M \
	-v `pwd`/conf.d:/data/logstash/conf.d \
	-p 5043:5043 \
	-p 5514:514 \
	-p 127.0.0.1:9292:9292 \
	-p 25826:25826 \
	-e LS_CONFIG='/data/logstash/conf.d/*.conf' \
	$IMAGE)

echo CID=$LOGSTASH_CONTAINER
docker inspect $LOGSTASH_CONTAINER
docker logs -f $LOGSTASH_CONTAINER



	
