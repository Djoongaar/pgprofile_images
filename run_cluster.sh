#!/bin/bash

docker compose up -d pg18 pg18_rep
docker exec pg18 bash -c "/var/lib/postgresql/src/replicate.sh"

docker cp pg18:data.tar data.tar
docker cp data.tar pg18_rep:/data.tar
rm data.tar

docker exec pg18_rep bash -c """
  mv data.tar /var/lib/postgresql/ &&
  ls -l /var/lib/postgresql/ &&
  rm -rf /var/lib/postgresql/data/* &&
  tar -xvf /var/lib/postgresql/data.tar -C /var/lib/postgresql/data --strip-components=1 &&
  rm /var/lib/postgresql/data.tar &&
  chown -R postgres:postgres /var/lib/postgresql/ &&
  chmod 0700 /var/lib/postgresql/data &&
  su postgres && pg_ctl -D /var/lib/postgresql/data start
  """

# docker compose down