#
# Código: bestrada23685/php.
# País: Nicaragua.
# Universidad: Universidad Nacional de Ingeniería (UNI).
# Recinto: Recinto Universitario Simón Bolivar (RUSB).
# Facultad: Facultad de Electrotecnia y Computación.
# Carrera: Ingeniería en Computación.
# Proyecto: Monografía / Análisis de competencias de investigación en universitarios del Programa Delfín - Capítulo Nicaragua.
# Tutor: Will Johnny Flores Delgadillo.
# Autor: Bakneer Nahúm Estrada Gutiérrez.
# Carnet: 2006-23685.
# Correo: bakneer.estrada623@std.uni.edu.ni 
# Fecha: 01/09/2022.
# URL: https://www.uni.edu.ni/#/somos 
#      https://uol.uni.edu.ni/
#
# Descripción: Dockerfile multi etapa para PHP-FPM.
#
#   - PHP-FPM: 7.4.30.
#
# GitHub URL: https://github.com/bestrada23685/docker-limesurvey/tree/master/php-fpm
# DockerHub URL: https://hub.docker.com/repository/docker/bestrada23685/php
#

ARG TAG=11.4-slim

FROM debian:$TAG AS stage001-download-dependencies

RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests \
    ca-certificates \
    wget \
    git \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

RUN wget --tries=10 --directory-prefix=/tmp/ https://www.php.net/distributions/php-7.4.30.tar.gz \
    && tar --gzip --extract --verbose --file=/tmp/php-7.4.30.tar.gz --directory=/opt/ \
    && rm --force /tmp/php-7.4.30.tar.gz

FROM stage001-download-dependencies AS stage002-install-development-tools

RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests \
    gcc \
    libc-dev \
    pkg-config \
    autoconf \
    make \
    automake \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

FROM stage002-install-development-tools AS stage003-build-php

RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests \
    libxml2-dev \
    libsqlite3-dev \
    libzip-dev \
    libpng-dev \
    libwebp-dev \
    libjpeg-dev \
    libxpm-dev \
    libfreetype6-dev \
    libonig-dev \
    libldap2-dev \
    libsasl2-dev \
    libc-client-dev \
    libgssapi-krb5-2 \
    libkrb5-dev \
    libcurl4-openssl-dev \
    libpq-dev \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

RUN cd /opt/php-7.4.30/ \
    && ./configure \
    --prefix=/usr/local/ \
    --with-config-file-path=/usr/local/etc \
    --enable-zts \
    --enable-fpm \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data \
    --with-zlib \
    --enable-gd \
    --with-webp \
    --with-jpeg \
    --with-xpm \ 
    --with-freetype \
    --enable-mbstring \
    --with-ldap \
    --with-ldap-sasl \
    --with-zip \
    --with-imap \
    --with-kerberos \
    --with-imap-ssl \
    --with-curl \
    --enable-pdo \
    --with-pdo-pgsql \
    && make -j$(nproc) clean \
    && make -j$(nproc) --debug \
    && make -j$(nproc) install
    
FROM stage003-build-php AS stage004-php-tuneup
    
RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests \
    procps \
    binutils \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

RUN strip --verbose --strip-unneeded /usr/lib/libc-client.so.2007e \
    /usr/lib/x86_64-linux-gnu/*.so.*
  
FROM bestrada23685/nginx:1.22.0 AS stage005-php-production  

RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests \
    supervisor \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

COPY --chmod=444 config/supervisor /etc/supervisor/
COPY --chmod=444 config/php-fpm/ /usr/local/etc/
COPY --chmod=444 config/nginx/ /etc/nginx/

COPY --from=stage004-php-tuneup /usr/lib/libc-client.so.2007e /usr/lib/libc-client.so.2007e
COPY --from=stage004-php-tuneup /usr/lib/x86_64-linux-gnu/libonig.so.5 /usr/lib/x86_64-linux-gnu/libonig.so.5
COPY --from=stage004-php-tuneup /usr/lib/x86_64-linux-gnu/libpq.so.5 /usr/lib/x86_64-linux-gnu/libpq.so.5
COPY --from=stage004-php-tuneup /usr/lib/x86_64-linux-gnu/libsqlite3.so.0 /usr/lib/x86_64-linux-gnu/libsqlite3.so.0
COPY --from=stage004-php-tuneup /usr/lib/x86_64-linux-gnu/libzip.so.4 /usr/lib/x86_64-linux-gnu/libzip.so.4

COPY --from=stage004-php-tuneup /usr/local/bin/phar /usr/local/bin/phar
COPY --from=stage004-php-tuneup /usr/local/bin/phar.phar /usr/local/bin/phar.phar
COPY --from=stage004-php-tuneup /usr/local/bin/php /usr/local/bin/php
COPY --from=stage004-php-tuneup /usr/local/bin/php-cgi /usr/local/bin/php-cgi
COPY --from=stage004-php-tuneup /usr/local/bin/php-config /usr/local/bin/php-config
COPY --from=stage004-php-tuneup /usr/local/bin/phpdbg /usr/local/bin/phpdbg
COPY --from=stage004-php-tuneup /usr/local/bin/phpize /usr/local/bin/phpize
COPY --from=stage004-php-tuneup /usr/local/sbin/php-fpm /usr/local/sbin/php-fpm

COPY --from=stage004-php-tuneup /usr/local/php/php/fpm/status.html /usr/local/php/php/fpm/status.html

COPY --from=stage004-php-tuneup /usr/local/lib/php/extensions/no-debug-non-zts-20190902/ /usr/local/lib/php/extensions/no-debug-non-zts-20190902/

RUN ldconfig -v

RUN mkdir --parents --verbose --mode=640 /usr/local/var/log/ \
    && touch /usr/local/var/log/php-fpm.log

CMD [ "/usr/bin/supervisord","-n", "-c", "/etc/supervisor/supervisord.conf" ]