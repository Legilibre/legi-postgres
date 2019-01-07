#!/bin/sh

docker-compose up --build --force-recreate -d

docker-compose run --rm legi.py /usr/bin/update

docker-compose exec postgres createdb -U user legi

docker-compose run --rm pgloader pgloader -v /scripts/legi.load

