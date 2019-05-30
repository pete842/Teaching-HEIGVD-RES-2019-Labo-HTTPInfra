docker run --rm -d --name res-php res/php
docker run -d --name res-express --rm res/express
docker run --rm -p 8080:80 --name res-reverse-proxy -d res/reverse-proxy
