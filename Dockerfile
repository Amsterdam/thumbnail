FROM composer:2.2
FROM debian:buster

EXPOSE 80

RUN  apt-get -y update \
 && apt-get -y upgrade \
 && apt-get -y install nano curl bash wget \
 && apt-get -y install nginx \
 && apt-get -y install unzip \
 && apt-get -y install git \
 && apt-get -y install lsb-release apt-transport-https ca-certificates \
 && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
 && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
 && apt-get -y update \
 && apt-get -y install php7.4 php7.4-fpm php7.4-curl php7.4-intl php7.4-json php7.4-mbstring php7.4-opcache php7.4-zip php7.4-xml \
 && apt-get -y install libreoffice \
 && apt-get -y install imagemagick

COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

WORKDIR /
RUN mkdir /srv/app
COPY . /srv/app
WORKDIR /srv/app

ENV COMPOSER_ALLOW_SUPERUSER 1

RUN composer install --prefer-dist --no-progress --no-scripts
RUN composer dump-autoload --optimize --classmap-authoritative

RUN mkdir /var/run/php-fpm \
 && mkdir /run/php \
 && mkdir -p /var/www/.cache \
 && chown www-data:www-data /var/www/.cache \
 && chmod u+rwx /var/www/.cache \
 && mkdir /var/www/.config \
 && chown www-data:www-data /var/www/.config \
 && chmod u+rwx /var/www/.config

ENTRYPOINT /srv/app/docker-entrypoint.sh

