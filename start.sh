#!/bin/sh

docker-compose up --build --force-recreate -d

docker-compose run legi.py /usr/bin/update

docker-compose exec postgres createdb -U user legi

docker-compose run pgloader pgloader -v /scripts/legi.load

