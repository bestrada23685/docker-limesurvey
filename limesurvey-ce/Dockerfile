FROM debian:11.4-slim AS stage001-download-prerequisites

RUN apt-get update && \
    apt-get install --yes --no-install-recommends --no-install-suggests \
        ca-certificates \
        wget && \
    apt-get clean && \
    rm --recursive --force /var/lib/apt/lists/*

RUN wget --tries=10 --directory-prefix=/tmp/ https://github.com/LimeSurvey/LimeSurvey/archive/refs/tags/3.28.23+220809.tar.gz && \
    tar --gzip --extract --verbose --file=/tmp/3.28.23+220809.tar.gz --directory=/opt/ && \
    rm --force /tmp/3.28.23+220809.tar.gz

FROM bestrada23685/php:7.4.30-nginx AS stage001-limesurvey-production

RUN apt-get update && \
    apt-get install --yes --no-install-recommends --no-install-suggests \
    netcat && \
    apt-get clean && \
    rm --recursive --force /var/lib/apt/lists/*

COPY --chmod=444 config/nginx /etc/nginx/

RUN cd /etc/nginx/sites-enabled && \
    ln -s ../sites-available/limesurvey.conf

RUN rm --force /etc/nginx/sites-enabled/default.conf && \
    rm --recursive --force  /var/www/html/default/

COPY --from=stage001-download-prerequisites --chown=www-data:www-data --chmod=750 /opt/LimeSurvey-3.28.23-220809/ /var/www/html/limesurvey/

COPY --chmod=775 config/docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

CMD [ "/usr/bin/supervisord","-n", "-c", "/etc/supervisor/supervisord.conf" ]