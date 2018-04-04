#!/bin/sh

docker run --network legipydocker_legi  \
  -v $PWD/tarballs:/tarballs \
  -v $PWD/scripts:/scripts \
  dimitri/pgloader:latest pgloader -v --cast "type day to varchar" \
  --set "work_mem='512MB'" \
  --set "maintenance_work_mem='1024MB'" \
  --before /scripts/pgloader-before.sql \
  --after /scripts/pgloader-after.sql \
  /tarballs/legilibre.sqlite "postgresql://user:pass@postgres/legi"
