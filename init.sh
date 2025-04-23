#!/bin/bash

set -a && source .env && set +a

if [ -d dist ]; then
  rm -rf dist
fi

mkdir dist
mkdir dist/conf.d

sed "s/__DOMAIN__/$LEIHGUT_LETS_ENCRYPT_DOMAIN/g" proxy/nginx-80-template.conf > dist/conf.d/80.conf

docker compose -f docker-compose.prod.yml up --build -d

echo "LEIHGUT | Now lets get us the certificate with certbot!"

if [ ! -f certbot/conf/live/$LEIHGUT_LETS_ENCRYPT_DOMAIN/fullchain.pem ]; then
  docker compose -f docker-compose.prod.yml run --rm leihgut-certbot certonly \
      --webroot \
      --webroot-path /var/www/certbot \
      --email $LEIHGUT_LETS_ENCRYPT_HTTPS_EMAIL \
      --agree-tos \
      --no-eff-email \
      -d $LEIHGUT_LETS_ENCRYPT_DOMAIN
fi

echo "LEIHGUT | Now lets add the 443 proxy routes!"

sed "s/__DOMAIN__/$LEIHGUT_LETS_ENCRYPT_DOMAIN/g" proxy/nginx-443-template.conf > dist/conf.d/443.conf

echo "0 3 */2 * * root docker compose -f $(pwd)/docker-compose.prod.yml run --rm leihgut-certbot sh -c 'certbot renew --webroot -w /var/www/certbot --quiet' && docker compose -f $(pwd)/docker-compose.prod.yml exec -T leihgut-proxy nginx -s reload" > /etc/cron.d/leihgut-certbot-renew
chmod 644 /etc/cron.d/leihgut-certbot-renew

docker compose -f docker-compose.prod.yml restart leihgut-proxy

echo "
       o                 o
                  o
         o   ______      o
           _/  (   \_
 _       _/  (       \_  O
| \_   _/  (   (    0  \\
|== \_/  (   (          |
|=== _ (   (   (        |
|==_/ \_ (   (          |
|_/     \_ (   (    \__/
          \_ (      _/
            |  |___/
           /__/

   Blub blub! It worked!
"