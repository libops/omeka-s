FROM islandora/nginx:6.2.3@sha256:1e85a1f0a222289a3079d5740ce8156d36c325c1f8477fb96806fa157cfb666b

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

EXPOSE 80

WORKDIR /var/www/omeka-s

ARG \
    # renovate: datasource=github-releases depName=omeka-s packageName=omeka/omeka-s
    OMEKA_S_VERSION=4.2.0 \
    # renovate: datasource=repology depName=alpine_3_22/php83
    PHP_VERSION=8.3.29-r0

RUN apk add --no-cache \
    curl \
    imagemagick \
    msmtp \
    php83-gd=="${PHP_VERSION}" \
    php83-mysqli=="${PHP_VERSION}" \
    php83-pdo=="${PHP_VERSION}" \
    php83-pdo_mysql=="${PHP_VERSION}" \
    php83-xml=="${PHP_VERSION}" \
    unzip \
    && curl -fsSL "https://github.com/omeka/omeka-s/releases/download/v${OMEKA_S_VERSION}/omeka-s-${OMEKA_S_VERSION}.zip" -o /tmp/omeka-s.zip \
    && unzip /tmp/omeka-s.zip -d /tmp \
    && cp -a /tmp/omeka-s/. /var/www/omeka-s/ \
    && rm -rf /tmp/omeka-s.zip /tmp/omeka-s \
    && mkdir -p /var/www/omeka-s/files \
    && chown -R nginx:nginx /var/www/omeka-s \
    && cleanup.sh

ENV \
    DB_HOST=mariadb \
    DB_PORT=3306 \
    DB_NAME=omeka_s \
    DB_USER=omeka_s \
    DB_PASSWORD=changeme \
    OMEKA_S_ADMIN_EMAIL=admin@example.com \
    OMEKA_S_ADMIN_NAME=Administrator \
    OMEKA_S_ADMIN_PASSWORD=changeme \
    OMEKA_S_SITE_TITLE="Omeka S" \
    OMEKA_S_TIME_ZONE=UTC \
    OMEKA_S_LOCALE=en_US \
    OMEKA_S_ENABLE_HTTPS=false \
    LIBOPS_SMTP_HOST=host.docker.internal \
    LIBOPS_SMTP_PORT=25 \
    SMTP_FROM= \
    PHP_MAX_EXECUTION_TIME=300 \
    PHP_MAX_INPUT_TIME=300 \
    PHP_DEFAULT_SOCKET_TIMEOUT=300 \
    PHP_REQUEST_TERMINATE_TIMEOUT=300 \
    PHP_MEMORY_LIMIT=256M \
    NGINX_FASTCGI_READ_TIMEOUT=300s \
    NGINX_FASTCGI_SEND_TIMEOUT=300s \
    NGINX_FASTCGI_CONNECT_TIMEOUT=300s

COPY --link rootfs /
