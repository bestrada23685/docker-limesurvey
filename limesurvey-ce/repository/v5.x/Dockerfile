#
# Código: bestrada23685/limesurvey-ce.
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
# Descripción: Dockerfile multi etapa para LimeSurvey Community Edition (CE).
#
#   - LimeSurvey Community Edition (CE): versión 5.3.32 release 220817 - From GitHub.
#
# GitHub URL: https://github.com/bestrada23685/docker-limesurvey/tree/master/limesurvey-ce
# DockerHub URL: https://hub.docker.com/repository/docker/bestrada23685/limesurvey-ce 
# 

# >> Argumentos para la construcción de la imagen base.

# 
# Etiqueta de la imagen base Debian.
#
ARG TAG=11.4-slim

#
# [[FASE 1]]: Descargar fuentes de LimeSurvey Community Edition (CE).
#
FROM debian:$TAG AS stage001-download-dependencies

# >> Argumento de construcción de la imagen.

#
# Versión de LimeSurvey Community Edition (CE).
#
ARG VERSION=5.3.32

#
# Release de LimeSurvey Community Edition (CE).
#
ARG BUILD=220817

# >> Variables de entorno.

#
# Nombre del archivo comprimido de LimeSurvey Community Edition (CE).
#
ENV FILE_NAME=${VERSION}+${BUILD}

RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests \
    ca-certificates \
    wget \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

RUN wget --tries=10 --directory-prefix=/tmp/ https://github.com/LimeSurvey/LimeSurvey/archive/refs/tags/${FILE_NAME}.tar.gz \
    && tar --gzip --extract --verbose --file=/tmp/${FILE_NAME}.tar.gz --directory=/opt/ \
    && rm --force /tmp/${FILE_NAME}.tar.gz

#
# [[FASE 2]]: Imagen de producción para LimeSurvey Community Edition (CE).
#  
FROM bestrada23685/php:7.4.30-nginx AS stage001-limesurvey-production

# >> Argumento de construcción de la imagen.

#
# Versión de LimeSurvey Community Edition (CE).
#
ARG VERSION=3.28.23

#
# Release de  LimeSurvey Community Edition (CE).
#
ARG BUILD=220809

# >> Variable de entorno.

#
# Directorio de LimeSurvey Community Edition (CE).
#
ENV DIR_NAME=${VERSION}-${BUILD}

RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests \
    netcat \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

COPY --chmod=444 config/nginx /etc/nginx/

RUN unlink /etc/nginx/sites-enabled/default.conf \
    && chmod 600 /var/www/html/default/

RUN ln -s /etc/nginx/sites-available/limesurvey.conf /etc/nginx/sites-enabled/

COPY --from=stage001-download-dependencies --chown=www-data:www-data --chmod=750 /opt/LimeSurvey-${DIR_NAME}/ /var/www/html/limesurvey/

COPY --chmod=775 config/docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

CMD [ "/usr/bin/supervisord","-n", "-c", "/etc/supervisor/supervisord.conf" ]