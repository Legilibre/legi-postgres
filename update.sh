
#docker-compose up --force-recreate -d

docker-compose exec legi.py /usr/bin/update

docker-compose exec postgres createdb -U user legi

docker-compose run pgloader pgloader -v /scripts/legi.load

