FROM php:7.3.5-apache-stretch

COPY 001-reverse-proxy.conf /etc/apache2/sites-available

RUN a2dissite 000* && \
    a2ensite 001* && \
    a2enmod proxy && \
    a2enmod proxy_http
