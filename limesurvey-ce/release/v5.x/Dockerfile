#
# Código: bestrada23685/limesurvey-ce.
# País: Nicaragua.
# Universidad: Universidad Nacional de Ingeniería (UNI).
# Recinto: Recinto Universitario Simón Bolivar (RUSB).
# Facultad: Facultad de Electrotecnia y Computación (FEC).
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
# Descripción: Dockerfile multi etapa para LimeSurvey Community Edition (CE).
#
#   - LimeSurvey Community Edition (CE): versión 5.4.7 release 221019 (latest-stable-release).
#
# GitHub URL: https://github.com/bestrada23685/docker-limesurvey/tree/master/limesurvey-ce
# DockerHub URL: https://hub.docker.com/repository/docker/bestrada23685/limesurvey-ce 
# 
ARG TAG=11.4-slim

FROM  debian:$TAG AS stage001

ARG VERSION=5.4.7

ARG BUILD=221019

ENV RELEASE=${VERSION}+${BUILD}

RUN set -eux; \
    apt-get update \
    && apt-get install --yes --no-install-recommends --show-progress \
    ca-certificates=20210119 \
    unzip=6.0-26+deb11u1 \
    wget=1.21-1+deb11u1 \
    && rm --recursive --force /var/lib/apt/lists/*

RUN set -eux; \
    wget --verbose --tries=30 --timeout=60 --wait=5 --continue  --progress=bar:force:noscroll \
    --show-progress --timestamping --directory=/tmp  https://download.limesurvey.org/latest-stable-release/limesurvey${RELEASE}.zip \
    && unzip /tmp/limesurvey${RELEASE}.zip -d /opt/ \
    && rm --force /tmp/limesurvey${RELEASE}.zip

FROM bestrada23685/webstack:81ac5c8 AS stage002

COPY --chmod=775 config/docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

COPY --from=stage001 --chown=www-data:www-data --chmod=750 /opt/limesurvey /var/www/html/default.uni.edu.ni/

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

CMD [ "/usr/bin/supervisord","-n", "-c", "/etc/supervisor/supervisord.conf" ]