FROM debian:11.4-slim AS stage001-download-prerequisites

ARG VERSION=3.28.23
ARG BUILD=220809

ENV FILE_NAME=${VERSION}+${BUILD}

RUN apt-get update && \
    apt-get install --yes --no-install-recommends --no-install-suggests \
        ca-certificates \
        wget && \
    apt-get clean && \
    rm --recursive --force /var/lib/apt/lists/*

RUN wget --tries=10 --directory-prefix=/tmp/ https://github.com/LimeSurvey/LimeSurvey/archive/refs/tags/${FILE_NAME}.tar.gz && \
    tar --gzip --extract --verbose --file=/tmp/${FILE_NAME}.tar.gz --directory=/opt/ && \
    rm --force /tmp/${FILE_NAME}.tar.gz

FROM bestrada23685/php:7.4.30-nginx AS stage001-limesurvey-production

ARG VERSION=3.28.23
ARG BUILD=220809

ENV DIR_NAME=${VERSION}-${BUILD}

RUN apt-get update && \
    apt-get install --yes --no-install-recommends --no-install-suggests \
    netcat && \
    apt-get clean && \
    rm --recursive --force /var/lib/apt/lists/*

COPY --chmod=444 config/nginx /etc/nginx/

RUN unlink /etc/nginx/sites-enabled/default.conf  && \
    chmod 600 /var/www/html/default/

RUN ln -s /etc/nginx/sites-available/limesurvey.conf /etc/nginx/sites-enabled/

COPY --from=stage001-download-prerequisites --chown=www-data:www-data --chmod=750 /opt/LimeSurvey-${DIR_NAME}/ /var/www/html/limesurvey/

COPY --chmod=775 config/docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

CMD [ "/usr/bin/supervisord","-n", "-c", "/etc/supervisor/supervisord.conf" ]