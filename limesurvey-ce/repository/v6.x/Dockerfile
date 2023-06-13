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
# Fecha: 12/06/2023.
# URL: https://www.uni.edu.ni/#/somos 
#      https://uol.uni.edu.ni/
#
# Descripción: Dockerfile multi etapa para LimeSurvey Community Edition (CE).
#
#   - LimeSurvey Community Edition (CE): versión 6.1.2 release 230606 - From GitHub.
#
# GitHub URL: https://github.com/bestrada23685/docker-limesurvey/tree/master/limesurvey-ce
# DockerHub URL: https://hub.docker.com/repository/docker/bestrada23685/limesurvey-ce 
# 
ARG TAG=11.7-slim

FROM debian:$TAG AS stage001

ARG VERSION=6.1.2

ARG BUILD=230606

ENV FILE_NAME=${VERSION}+${BUILD}

RUN set -eux; \
    apt-get update \
    && apt-get install --yes --no-install-recommends --show-progress \
    ca-certificates=20210119 \
    wget=1.21-1+deb11u1 \
    && rm --recursive --force /var/lib/apt/lists/*

RUN set -eux; \
    wget --verbose --tries=30 --timeout=60 --wait=5 --continue  --progress=bar:force:noscroll \
    --show-progress --timestamping --directory=/tmp  "https://github.com/LimeSurvey/LimeSurvey/archive/refs/tags/${FILE_NAME}.tar.gz" \
    && tar --gzip --extract --verbose --file="/tmp/${FILE_NAME}.tar.gz" --directory=/opt/ \
    && rm --force "/tmp/${FILE_NAME}.tar.gz"

FROM bestrada23685/phpstack:8.1.13 AS stage002

ARG VERSION=6.1.2

ARG BUILD=230606

ENV DIR_NAME=${VERSION}-${BUILD}

COPY --chmod=775 config/docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

COPY --from=stage001 --chown=www-data:www-data --chmod=750 /opt/LimeSurvey-${DIR_NAME}/ /var/www/html/default.uni.edu.ni/

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

CMD [ "/usr/bin/supervisord","-n", "-c", "/etc/supervisor/supervisord.conf" ]