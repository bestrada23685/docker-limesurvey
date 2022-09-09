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

FROM  debian:$TAG AS stage001-download-dependencies

ARG PHP_BRANCH=PHP-7.4.30

RUN apt-get update \
    &&  apt-get install --yes --no-install-recommends --no-install-suggests \
    ca-certificates \
    wget \
    git \
    && apt-get clean \
    &&  rm --recursive --force /var/lib/apt/lists/*

RUN wget --tries=10  --directory-prefix=/tmp/ https://pecl.php.net/get/memcached-3.2.0.tgz \
    && tar --gzip --extract --verbose --file=/tmp/memcached-3.2.0.tgz --directory=/opt/ \
    && rm --force /tmp/memcached-3.2.0.tgz

RUN git clone --progress --verbose --branch=$PHP_BRANCH --depth=1 https://github.com/php/php-src.git /opt/php-src/

RUN git clone --progress --verbose --depth=1 https://github.com/Imagick/imagick /opt/Imagick/

FROM stage001-download-dependencies AS stage002-install-development-tools

RUN apt-get update \
    &&  apt-get install --yes --no-install-recommends --no-install-suggests \
    autoconf \
    automake \
    libtool \
    re2c \
    bison \
    pkg-config \
    make \
    g++ \
    && apt-get clean \
    &&  rm --recursive --force /var/lib/apt/lists/*

FROM stage002-install-development-tools AS stage003-build-php

RUN apt-get update \
    &&  apt-get install --yes --no-install-recommends --no-install-suggests \
    libxml2-dev \
    libcurl4-openssl-dev \
    libonig-dev \
    zlib1g-dev \
    libpng-dev \
    libwebp-dev \
    libjpeg-dev \
    libxpm-dev \
    libfreetype-dev \
    libc-client-dev \
    libgssapi-krb5-2 \
    libkrb5-dev \
    libldap2-dev \
    libzip-dev \
    libpq-dev \
    libmagickwand-dev \
    libmagickcore-dev \
    libmemcached-dev \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

RUN cd /opt/php-src/ \
    && ./buildconf \
    && ./configure \
    --with-config-file-path=/etc/php/7.4/fpm \
    --with-config-file-scan-dir=/etc/php/7.4/fpm/conf.d \
    --enable-fpm \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data \
    --disable-phpdbg \
    --disable-phpdbg-webhelper \
    --disable-phpdbg-debug \
    --disable-phpdbg-readline \
    --disable-cgi \
    --disable-debug \
    --with-curl=shared \
    --enable-mbstring=shared \
    --enable-gd=shared \
    --with-webp \
    --with-jpeg \
    --with-xpm \
    --with-freetype \
    --with-imap=shared \
    --with-kerberos \
    --with-imap-ssl \
    --with-ldap=shared \
    --with-zip=shared \
    --with-zlib=shared \
    --enable-pdo=shared \
    --with-pgsql=shared \
    --with-pdo-pgsql=shared \
    --without-pdo-sqlite \
    --without-sqlite3 \
    --disable-phar \
    --without-pear \
    && make -j$(nproc) clean \
    && make -j$(nproc) \
    && make -j$(nproc) install

RUN cd /opt/Imagick/ \
    && phpize \
    && ./configure \ 
    && make -j$(nproc) clean \
    && make -j$(nproc) \
    && make -j$(nproc) install

RUN cd /opt/memcached-3.2.0 \
    && phpize \
    && ./configure \
    && make -j$(nproc) clean \
    && make -j$(nproc) \
    && make -j$(nproc) install

RUN mkdir --parents /etc/php/7.4/fpm/conf.d \
    && cp /opt/php-src/php.ini-development /etc/php/7.4/fpm/php.ini \
    && mv /usr/local/etc/php-fpm.conf.default /usr/local/etc/php-fpm.conf \
    && mv /usr/local/etc/php-fpm.d/www.conf.default /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's|NONE|/usr/local|g' /usr/local/etc/php-fpm.conf \
    && sed -i 's|;cgi.fix_pathinfo=1|cgi.fix_pathinfo=0|g' /etc/php/7.4/fpm/php.ini \
    && sed -i 's|memory_limit = 128M|memory_limit = 512M|g' /etc/php/7.4/fpm/php.ini \
    && sed -i 's|upload_max_filesize = 2M|upload_max_filesize = 50M|g' /etc/php/7.4/fpm/php.ini \
    && sed -i 's|post_max_size = 8M|post_max_size = 50M|g' /etc/php/7.4/fpm/php.ini \
    && sed -i 's|max_execution_time = 30|max_execution_time = 60|g' /etc/php/7.4/fpm/php.ini \
    && sed -i 's|;max_input_vars = 1000|max_input_vars = 10000|g' /etc/php/7.4/fpm/php.ini

FROM stage003-build-php AS stage004-tuneup-php

RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests \
    nano \
    procps \
    binutils \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

RUN strip --verbose --strip-unneeded /usr/local/lib/php/extensions/no-debug-non-zts-20190902/*.so \
    /usr/local/lib/php/extensions/no-debug-non-zts-20190902/*.a \
    /usr/lib/x86_64-linux-gnu/*.so.* \
    /usr/lib/libc-client.so.2007e

FROM bestrada23685/nginx:1.22.0 AS stage006-php-production 

RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests \
    supervisor \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

COPY --from=stage004-tuneup-php /usr/local/bin/php /usr/local/bin/php
COPY --from=stage004-tuneup-php /usr/local/sbin/php-fpm /usr/local/sbin/php-fpm
COPY --from=stage004-tuneup-php /usr/local/lib/php/extensions/no-debug-non-zts-20190902/*.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902/

COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libcurl.so.4 /usr/lib/x86_64-linux-gnu/libcurl.so.4
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/librtmp.so.1 /usr/lib/x86_64-linux-gnu/librtmp.so.1
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libssh2.so.1 /usr/lib/x86_64-linux-gnu/libssh2.so.1
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libpsl.so.5 /usr/lib/x86_64-linux-gnu/libpsl.so.5
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libnghttp2.so.14 /usr/lib/x86_64-linux-gnu/libnghttp2.so.14
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libpq.so.5 /usr/lib/x86_64-linux-gnu/libpq.so.5
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libxml2.so.2 /usr/lib/x86_64-linux-gnu/libxml2.so.2
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2 /usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libicuuc.so.67 /usr/lib/x86_64-linux-gnu/libicuuc.so.67
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/liblber-2.4.so.2 /usr/lib/x86_64-linux-gnu/liblber-2.4.so.2
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libsasl2.so.2 /usr/lib/x86_64-linux-gnu/libsasl2.so.2
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libicudata.so.67 /usr/lib/x86_64-linux-gnu/libicudata.so.67
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libpng16.so.16 /usr/lib/x86_64-linux-gnu/libpng16.so.16
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libwebp.so.6 /usr/lib/x86_64-linux-gnu/libwebp.so.6
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libjpeg.so.62 /usr/lib/x86_64-linux-gnu/libjpeg.so.62
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libXpm.so.4 /usr/lib/x86_64-linux-gnu/libXpm.so.4
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libfreetype.so.6 /usr/lib/x86_64-linux-gnu/libfreetype.so.6
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libX11.so.6 /usr/lib/x86_64-linux-gnu/libX11.so.6
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libbrotlidec.so.1 /usr/lib/x86_64-linux-gnu/libbrotlidec.so.1
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libxcb.so.1 /usr/lib/x86_64-linux-gnu/libxcb.so.1
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libbrotlicommon.so.1 /usr/lib/x86_64-linux-gnu/libbrotlicommon.so.1
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libXau.so.6 /usr/lib/x86_64-linux-gnu/libXau.so.6
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libXdmcp.so.6 /usr/lib/x86_64-linux-gnu/libXdmcp.so.6
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libbsd.so.0 /usr/lib/x86_64-linux-gnu/libbsd.so.0
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libmd.so.0 /usr/lib/x86_64-linux-gnu/libmd.so.0
COPY --from=stage004-tuneup-php /usr/lib/libc-client.so.2007e /usr/lib/libc-client.so.2007e
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libonig.so.5 /usr/lib/x86_64-linux-gnu/libonig.so.5
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libzip.so.4 /usr/lib/x86_64-linux-gnu/libzip.so.4

COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libgomp.so.1 /usr/lib/x86_64-linux-gnu/libgomp.so.1
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libMagickWand-6.Q16.so.6 /usr/lib/x86_64-linux-gnu/libMagickWand-6.Q16.so.6
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libMagickCore-6.Q16.so.6 /usr/lib/x86_64-linux-gnu/libMagickCore-6.Q16.so.6
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/liblcms2.so.2 /usr/lib/x86_64-linux-gnu/liblcms2.so.2
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/liblqr-1.so.0 /usr/lib/x86_64-linux-gnu/liblqr-1.so.0
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libfftw3.so.3 /usr/lib/x86_64-linux-gnu/libfftw3.so.3
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libXext.so.6 /usr/lib/x86_64-linux-gnu/libXext.so.6
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libltdl.so.7 /usr/lib/x86_64-linux-gnu/libltdl.so.7
COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libglib-2.0.so.0 /usr/lib/x86_64-linux-gnu/libglib-2.0.so.0

COPY --from=stage004-tuneup-php /usr/lib/x86_64-linux-gnu/libmemcached.so.11 /usr/lib/x86_64-linux-gnu/libmemcached.so.11

COPY --from=stage004-tuneup-php /usr/local/php/php/fpm/status.html /usr/local/php/php/fpm/status.html

COPY --chmod=444 --from=stage004-tuneup-php /etc/php/7.4/fpm/php.ini /etc/php/7.4/fpm/php.ini
COPY --chmod=444 --from=stage004-tuneup-php /usr/local/etc/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY --chmod=444 --from=stage004-tuneup-php /usr/local/etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf

COPY --chmod=444 config/php-fpm/conf.d/ /etc/php/7.4/fpm/conf.d/

COPY --chmod=444 config/supervisor /etc/supervisor/
COPY --chmod=444 config/nginx/ /etc/nginx/

RUN ldconfig --verbose

RUN mkdir --parents --verbose /usr/local/var/log \
    && touch /usr/local/var/log/php-fpm.log

CMD [ "/usr/bin/supervisord","-n", "-c", "/etc/supervisor/supervisord.conf" ]