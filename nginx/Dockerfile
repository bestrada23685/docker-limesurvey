#
# Código: bestrada23685/nginx.
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
# Descripción: Dockerfile multi etapa para NGINX.
#
#   - Nginx version: nginx/1.22.0 (Monograph).
#   - built by gcc 10.2.1 20210110 (Debian 10.2.1-6).
#   - OpenSSL 3.0.5 5 Jul 2022.
#   - TLS SNI support enabled.
#   - ModSecurity v3.0.7.
#   - OWASP ModSecurity Core Rule Set (CRS) v3.3.2.
#   - NGINX module for Brotli compression v1.0.0rc.
#   - ModSecurity v3 Nginx Connector v1.0.3.
#
# GitHub URL: https://github.com/bestrada23685/docker-limesurvey/tree/master/nginx
# DockerHub URL: https://hub.docker.com/repository/docker/bestrada23685/nginx 
#

ARG TAG=11.4-slim

FROM  debian:$TAG AS stage001-download-dependencies

RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests \
    ca-certificates \
    wget \
    git \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

RUN wget --tries=10  --directory-prefix=/tmp/ https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.gz \
    && tar --gzip --extract --verbose --file=/tmp/pcre2-10.40.tar.gz --directory=/opt/ \
    && rm --force /tmp/pcre2-10.40.tar.gz

RUN wget --tries=10 --directory-prefix=/tmp/ https://zlib.net/zlib-1.2.12.tar.gz \
    && tar --gzip --extract --verbose --file=/tmp/zlib-1.2.12.tar.gz --directory=/opt/ \
    && rm --force /tmp/zlib-1.2.12.tar.gz

RUN wget --tries=10 --directory-prefix=/tmp/ https://www.openssl.org/source/openssl-3.0.5.tar.gz \
    && tar --gzip --extract --verbose --file=/tmp/openssl-3.0.5.tar.gz --directory=/opt/ \
    && rm --force /tmp/openssl-3.0.5.tar.gz

RUN wget --tries=10 --directory-prefix=/tmp/ https://nginx.org/download/nginx-1.22.0.tar.gz \
    && tar --gzip --extract --verbose --file=/tmp/nginx-1.22.0.tar.gz --directory=/opt/ \
    && rm --force /tmp/nginx-1.22.0.tar.gz

RUN git clone --progress --verbose --depth 1 https://github.com/google/ngx_brotli.git /opt/ngx_brotli/

RUN git clone --progress --verbose --depth 1 https://github.com/ssdeep-project/ssdeep.git /opt/ssdeep/

RUN git clone --progress --verbose --depth 1 --branch v3/master --single-branch https://github.com/SpiderLabs/ModSecurity.git /opt/ModSecurity/

RUN git clone --progress --verbose --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git /opt/ModSecurity-nginx

FROM stage001-download-dependencies AS stage002-install-development-tools

RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests \
    uuid-dev \
    g++ \
    autoconf \
    automake \
    libtool \
    pkgconf \
    doxygen \
    build-essential \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

FROM stage002-install-development-tools AS stage003-build-common-dependencies

RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests \
    libcurl4-openssl-dev \
    libgeoip-dev \
    liblmdb-dev \
    libpcre++-dev \
    libxml2-dev \ 
    libyajl-dev \
    liblua5.3-dev \
    libmaxminddb-dev \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

RUN cd /opt/pcre2-10.40 \
    && ./configure \
    --prefix=/usr/local \
    --enable-jit \
    && make -j$(nproc) clean \
    && make -j$(nproc) --debug \
    && make -j$(nproc) install

RUN cd /opt/zlib-1.2.12 \
    && ./configure \
    --prefix=/usr/local \
    && make -j$(nproc) clean \
    && make -j$(nproc) --debug \
    && make -j$(nproc) install

RUN cd /opt/openssl-3.0.5 \
    && ./Configure \
    enable-fips \
    linux-x86_64 \
    --prefix=/usr/local/ssl \
    --openssldir=/usr/local/ssl \
    '-Wl,--enable-new-dtags,-rpath,$(LIBRPATH)' \
    && make -j$(nproc) clean \
    && make -j$(nproc) --debug \
    && make -j$(nproc) install_sw

FROM stage003-build-common-dependencies AS stage004-build-libmodsecurity

RUN cd /opt/ssdeep/ \
    && ./bootstrap \
    && ./configure \
    && make -j$(nproc) clean \
    && make -j$(nproc) --debug \
    && make -j$(nproc) install

RUN cd /opt/ModSecurity/ \
    && git submodule init \
    && git submodule update \
    && ./build.sh \
    && ./configure \ 
    --with-yajl \
    --with-geoip \
    --with-maxmind \
    --with-lmdb \
    --with-lua \
    --with-ssdeep \
    --with-pcre2 \
    && make -j$(nproc) clean \
    && make -j$(nproc) --debug \
    && make -j$(nproc) install

FROM stage004-build-libmodsecurity AS stage005-build-nginx

RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests \
    libxml2-dev \
    libxslt1-dev \
    libgd-dev \
    libgoogle-perftools-dev \
    libatomic-ops-dev \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

RUN cd /opt/nginx-1.22.0 \
    && ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/etc/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --pid-path=/run/nginx.pid \
    --lock-path=/run/nginx.lock \
    --user=www-data \
    --group=www-data \
    --build="Monograph" \
    --builddir=nginx-1.22.0 \
    --with-select_module \
    --with-poll_module \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-openssl=/opt/openssl-3.0.5 \
    --with-openssl-opt=enable-ktls \
    --with-http_addition_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-http_sub_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --http-log-path=/var/log/nginx/access.log \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --with-mail=dynamic \
    --with-mail_ssl_module \
    --with-stream=dynamic \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_geoip_module=dynamic \
    --with-stream_ssl_preread_module \
    --with-google_perftools_module \
    --with-pcre-jit \
    --with-libatomic \
    --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' \
    --with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' \
    --with-compat \
    --add-dynamic-module=/opt/ModSecurity-nginx \
    --add-dynamic-module=/opt/ngx_brotli/ \
    --with-debug \
    && make -j$(nproc) --debug \
    && make -j$(nproc) install
 
FROM stage005-build-nginx AS stage006-nginx-tuneup

RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests \
    nano \
    procps \
    binutils \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

RUN strip --verbose --strip-unneeded /usr/local/lib/*.so.* \
    /usr/lib/x86_64-linux-gnu/*.so.* \
    /etc/nginx/modules/*.so \
    /lib/x86_64-linux-gnu/libexpat.so.1 \
    /usr/local/modsecurity/lib/libmodsecurity.so.3

FROM  debian:$TAG AS stage007-nginx-production

COPY --from=stage006-nginx-tuneup   /usr/local/lib/libpcre2-8.so.0	/usr/local/lib/libpcre2-8.so.0
COPY --from=stage006-nginx-tuneup	/usr/local/lib/libz.so.1	/usr/local/lib/libz.so.1
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libprofiler.so.0	/usr/lib/x86_64-linux-gnu/libprofiler.so.0 
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libunwind.so.8	/usr/lib/x86_64-linux-gnu/libunwind.so.8

COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libbrotlienc.so.1	/usr/lib/x86_64-linux-gnu/libbrotlienc.so.1
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libbrotlicommon.so.1	/usr/lib/x86_64-linux-gnu/libbrotlicommon.so.1

COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libGeoIP.so.1	/usr/lib/x86_64-linux-gnu/libGeoIP.so.1

COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libgd.so.3	/usr/lib/x86_64-linux-gnu/libgd.so.3
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libpng16.so.16	/usr/lib/x86_64-linux-gnu/libpng16.so.16
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libfontconfig.so.1	/usr/lib/x86_64-linux-gnu/libfontconfig.so.1
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libfreetype.so.6	/usr/lib/x86_64-linux-gnu/libfreetype.so.6
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libjpeg.so.62	/usr/lib/x86_64-linux-gnu/libjpeg.so.62
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libXpm.so.4	/usr/lib/x86_64-linux-gnu/libXpm.so.4
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libtiff.so.5	/usr/lib/x86_64-linux-gnu/libtiff.so.5
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libwebp.so.6	/usr/lib/x86_64-linux-gnu/libwebp.so.6
COPY --from=stage006-nginx-tuneup	/lib/x86_64-linux-gnu/libexpat.so.1	/lib/x86_64-linux-gnu/libexpat.so.1
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libbrotlidec.so.1	/usr/lib/x86_64-linux-gnu/libbrotlidec.so.1
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libX11.so.6	/usr/lib/x86_64-linux-gnu/libX11.so.6	
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libjbig.so.0	/usr/lib/x86_64-linux-gnu/libjbig.so.0
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libdeflate.so.0	/usr/lib/x86_64-linux-gnu/libdeflate.so.0
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libxcb.so.1	/usr/lib/x86_64-linux-gnu/libxcb.so.1
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libXau.so.6	/usr/lib/x86_64-linux-gnu/libXau.so.6
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libXdmcp.so.6	/usr/lib/x86_64-linux-gnu/libXdmcp.so.6
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libbsd.so.0	/usr/lib/x86_64-linux-gnu/libbsd.so.0
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libmd.so.0	/usr/lib/x86_64-linux-gnu/libmd.so.0

COPY --from=stage006-nginx-tuneup	/usr/local/modsecurity/bin/modsec-rules-check	/usr/local/modsecurity/bin/modsec-rules-check
COPY --from=stage006-nginx-tuneup	/usr/local/modsecurity/lib/libmodsecurity.so.3	/usr/local/modsecurity/lib/libmodsecurity.so.3
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libcurl.so.4	/usr/lib/x86_64-linux-gnu/libcurl.so.4
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libxml2.so.2	/usr/lib/x86_64-linux-gnu/libxml2.so.2
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/liblmdb.so.0	/usr/lib/x86_64-linux-gnu/liblmdb.so.0
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/liblua5.3.so.0	/usr/lib/x86_64-linux-gnu/liblua5.3.so.0
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libmaxminddb.so.0	/usr/lib/x86_64-linux-gnu/libmaxminddb.so.0
COPY --from=stage006-nginx-tuneup	/usr/local/lib/libfuzzy.so.2	/usr/local/lib/libfuzzy.so.2
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libyajl.so.2	/usr/lib/x86_64-linux-gnu/libyajl.so.2
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libnghttp2.so.14	/usr/lib/x86_64-linux-gnu/libnghttp2.so.14
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/librtmp.so.1	/usr/lib/x86_64-linux-gnu/librtmp.so.1
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libssh2.so.1	/usr/lib/x86_64-linux-gnu/libssh2.so.1
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libpsl.so.5	/usr/lib/x86_64-linux-gnu/libpsl.so.5
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2	/usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/liblber-2.4.so.2	/usr/lib/x86_64-linux-gnu/liblber-2.4.so.2
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libicuuc.so.67	/usr/lib/x86_64-linux-gnu/libicuuc.so.67
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libsasl2.so.2	/usr/lib/x86_64-linux-gnu/libsasl2.so.2
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libicudata.so.67	/usr/lib/x86_64-linux-gnu/libicudata.so.67

COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libxslt.so.1	/usr/lib/x86_64-linux-gnu/libxslt.so.1
COPY --from=stage006-nginx-tuneup	/usr/lib/x86_64-linux-gnu/libexslt.so.0	/usr/lib/x86_64-linux-gnu/libexslt.so.0

COPY --from=stage006-nginx-tuneup	/usr/sbin/nginx /usr/sbin/nginx
COPY --from=stage006-nginx-tuneup	/etc/nginx/modules/ /etc/nginx/modules/

COPY --chmod=444 config/nginx/ /etc/nginx/

RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/

RUN ldconfig -v

RUN mkdir --parents --verbose --mode=750 /var/www/html/default/ \
    && chown -R www-data:www-data /var/www/html/default/

RUN mkdir --parents --verbose --mode=640 /var/log/nginx/ \
    && chown -R root:root /var/log/nginx/

RUN mkdir --parents --verbose --mode=750 /var/cache/nginx/client_temp/ \
    /var/cache/nginx/proxy_temp/ \
    /var/cache/nginx/fastcgi_temp/ \
    /var/cache/nginx/uwsgi_temp/ \
    /var/cache/nginx/scgi_temp/ \
    && chown -R www-data:www-data /var/cache/nginx/

RUN mkdir --parents --verbose --mode=750 /opt/modsecurity/var \
    /opt/modsecurity/var/tmp

RUN mkdir --verbose --mode=700  /opt/modsecurity/var/audit \
    /opt/modsecurity/var/data \
    /opt/modsecurity/var/log \
    /opt/modsecurity/var/upload	

RUN chown root:www-data /opt/modsecurity/var \
    && chown www-data:root /opt/modsecurity/var/audit \
    && chown www-data:root /opt/modsecurity/var/data \
    && chown root:root /opt/modsecurity/var/log \
    && chown www-data:www-data /opt/modsecurity/var/tmp \
    && chown www-data:root /opt/modsecurity/var/upload

RUN touch /var/log/nginx/access.log \
    /var/log/nginx/error.log \ 
    /var/run/nginx.pid \ 
    /var/run/nginx.lock \
    /var/log/modsec_audit.log \
    /opt/modsecurity/var/log/debug.log

COPY --chown=www-data:www-data --chmod=750 /config/assets/ /var/www/html/default/

EXPOSE 80/tcp 443/tcp

STOPSIGNAL SIGTERM

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]