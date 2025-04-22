#!/bin/bash

set -a && source .env && set +a

if [ -d dist ]; then
  rm -rf dist
fi

mkdir dist
mkdir dist/conf.d

sed "s/__DOMAIN__/$LEIHGUT_LETS_ENCRYPT_DOMAIN/g" proxy/nginx-80.conf.template > dist/conf.d/80.conf

docker compose -f docker-compose.prod.yml up --build -d

if [ ! -f certbot/conf/live/$LEIHGUT_LETS_ENCRYPT_DOMAIN/fullchain.pem ]; then
  docker compose -f docker-compose.prod.yml run --rm leihgut-certbot \
    sh -c "certbot certonly \
      --webroot \
      --webroot-path /var/www/certbot \
      --email $LEIHGUT_LETS_ENCRYPT_HTTPS_EMAIL \
      --agree-tos \
      --no-eff-email \
      -d $LEIHGUT_LETS_ENCRYPT_DOMAIN"
fi

sed "s/__DOMAIN__/$LEIHGUT_LETS_ENCRYPT_DOMAIN/g" proxy/nginx-443.conf.template > dist/conf.d/443.conf

docker compose -f docker-compose.prod.yml restart leihgut-proxy