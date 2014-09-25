#!/usr/bin/env bash


TAG=rednut/logstash
NOCACHE=

docker build $NOCACHE -t $TAG .


