ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
# php version arg/envvar inherited from alpine-php
# ARG PHPMAJMIN
# ENV \
#     PHPMAJMIN=${PHPMAJMIN}
#
ARG VERSION
#
ENV \
    LD_PRELOAD="/usr/lib/preloadable_libiconv.so php" \
    SYMFONY_ENV=prod \
    WALLABAG_SRC=/opt/wallabag/wallabag-${VERSION}.tar.gz
#
RUN set -xe \
    && apk add --no-cache --purge -uU \
        bash \
        curl \
        gnu-libiconv \
        libwebp \
        make \
        mariadb-client \
        postgresql-client\
        rabbitmq-c \
        sqlite \
        ssmtp \
        tar \
        tzdata \
#
        php${PHPMAJMIN}-bcmath \
        php${PHPMAJMIN}-ctype \
        php${PHPMAJMIN}-curl \
        php${PHPMAJMIN}-dom \
        php${PHPMAJMIN}-fpm \
        php${PHPMAJMIN}-gd \
        php${PHPMAJMIN}-gettext \
        php${PHPMAJMIN}-iconv \
        php${PHPMAJMIN}-intl \
        php${PHPMAJMIN}-json \
        php${PHPMAJMIN}-mbstring \
        php${PHPMAJMIN}-openssl \
        php${PHPMAJMIN}-pdo_mysql \
        php${PHPMAJMIN}-pdo_pgsql \
        php${PHPMAJMIN}-pdo_sqlite \
        php${PHPMAJMIN}-pecl-amqp \
        php${PHPMAJMIN}-pecl-imagick \
        php${PHPMAJMIN}-pecl-redis \
        php${PHPMAJMIN}-phar \
        php${PHPMAJMIN}-session \
        php${PHPMAJMIN}-simplexml \
        php${PHPMAJMIN}-sockets \
        php${PHPMAJMIN}-tidy \
        php${PHPMAJMIN}-tokenizer \
        php${PHPMAJMIN}-xml \
        php${PHPMAJMIN}-xmlreader \
        php${PHPMAJMIN}-zlib \
#
    && mkdir -p \
        /defaults \
        /opt/wallabag \
    && if [ -f "/etc/php${PHPMAJMIN}/php.ini" ]; then mv /etc/php${PHPMAJMIN}/php.ini /defaults/php.ini; fi \
    && if [ -f "/etc/php${PHPMAJMIN}/php-fpm.conf" ]; then mv /etc/php${PHPMAJMIN}/php-fpm.conf /defaults/php-fpm.conf; fi \
    && if [ -f "/etc/php${PHPMAJMIN}/php-fpm.d/www.conf" ]; then mv /etc/php${PHPMAJMIN}/php-fpm.d/www.conf /defaults/php-fpm-www.conf; fi \
#
    # # disable installing composer since using dist version
    # && curl -s https://getcomposer.org/installer | php \
    # && mv composer.phar /usr/local/bin/composer \
    # && composer selfupdate --2 \
#
    && echo "${VERSION}" > /opt/wallabag/version \
    && curl \
        -o ${WALLABAG_SRC} \
        -SL "https://github.com/wallabag/wallabag/releases/download/${VERSION}/wallabag-${VERSION}.tar.gz" \
#
    && rm -rf /var/cache/apk/* /tmp/*
#
# add local files
COPY root/ /
# ports, volumes etc from php
#
HEALTHCHECK \
    --interval=2m \
    --retries=5 \
    --start-period=5m \
    --timeout=10s \
    CMD \
    wget --quiet --tries=1 --no-check-certificate --spider ${HEALTHCHECK_URL:-"http://localhost:80/"} || exit 1
#
# ENTRYPOINT ["/init"]
