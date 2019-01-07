#!/bin/sh

docker-compose run --rm legi.py /usr/bin/update

docker-compose run --rm pgloader pgloader -v /scripts/legi.load

