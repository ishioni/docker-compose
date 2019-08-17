#!/bin/bash
source ./.env
echo "Stopping containers"
docker-compose down
echo "Spawning acme"
docker-compose up -d acmesh
echo "Issuing cert"
export HE_Username HE_Password
docker exec -e HE_Username -e HE_Password acmesh --issue \
--dns dns_he -d ${DOMAIN} -d *.${DOMAIN} -k 4096
echo "Installing cert"
docker exec acmesh --install-cert -d ${DOMAIN} \
--fullchain-file /certs/fullchain.pem \
--key-file /certs/key.pem
echo "Bringing up traefik"
docker-compose up -d
echo "Copying external config"
docker cp ./servers.toml traefik:/config/
