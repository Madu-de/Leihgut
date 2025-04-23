#!/bin/bash

Color_Off='\033[0m'
Purple='\033[0;35m'
Cyan='\033[0;36m'
Green='\033[0;32m'

echo -e "${Cyan}LEIHGUT ${Green}[INFO]${Color_Off} | ${Purple}Load env variables out of .env${Color_Off}"

set -a && source .env && set +a

echo -e "LEIHGUT ${Green}[INFO]${Color_Off} | ${Purple}Delete /dist if exists${Color_Off}"

if [ -d dist ]; then
  rm -rf dist
fi

echo -e "${Cyan}LEIHGUT ${Green}[INFO]${Color_Off} | ${Purple}Create /dist and child directories${Color_Off}"

mkdir dist
mkdir dist/conf.d

echo -e "${Cyan}LEIHGUT ${Green}[INFO]${Color_Off} | ${Purple}Create 80.conf out of nginx-80-template.conf${Color_Off}"

sed "s/__DOMAIN__/$LEIHGUT_LETS_ENCRYPT_DOMAIN/g" proxy/nginx-80-template.conf > dist/conf.d/80.conf

echo -e "${Cyan}LEIHUGT ${Green}[INFO]${Color_Off} | ${Purple}Start application${Color_Off}"

docker compose -f docker-compose.prod.yml up --build -d

echo -e "${Cyan}LEIHGUT ${Green}[INFO]${Color_Off} | ${Purple}Now lets get us the certificate with certbot!${Color_Off}"

if [ ! -f certbot/conf/live/$LEIHGUT_LETS_ENCRYPT_DOMAIN/fullchain.pem ]; then
  docker compose -f docker-compose.prod.yml run --rm leihgut-certbot certonly \
      --webroot \
      --webroot-path /var/www/certbot \
      --email $LEIHGUT_LETS_ENCRYPT_HTTPS_EMAIL \
      --agree-tos \
      --no-eff-email \
      -d $LEIHGUT_LETS_ENCRYPT_DOMAIN
fi

echo -e "${Cyan}LEIHGUT ${Green}[INFO]${Color_Off} | ${Purple}Create 443.conf out of nginx-443-template.conf${Color_Off}"

sed "s/__DOMAIN__/$LEIHGUT_LETS_ENCRYPT_DOMAIN/g" proxy/nginx-443-template.conf > dist/conf.d/443.conf

echo -e "${Cyan}LEIHGUT ${Green}[INFO]${Color_Off} | ${Purple}Restart proxy to use 443 server too${Color_Off}"

docker compose -f docker-compose.prod.yml restart leihgut-proxy

echo -e "${Cyan}LEIHGUT ${Green}[INFO]${Color_Off} | ${Purple}Create cronjob for renew certificate${Color_Off}"

echo "0 3 */2 * * root docker compose -f $(pwd)/docker-compose.prod.yml run --rm leihgut-certbot sh -c 'certbot renew --webroot -w /var/www/certbot --quiet' && docker compose -f $(pwd)/docker-compose.prod.yml exec -T leihgut-proxy nginx -s reload" > /etc/cron.d/leihgut-certbot-renew
chmod 644 /etc/cron.d/leihgut-certbot-renew

echo -e "${Cyan}
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
${Color_Off}"