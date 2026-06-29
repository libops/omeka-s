ARG BASE_IMAGE=libops/omeka-s:nginx-1.30.3-php84
FROM ${BASE_IMAGE}

ARG TARGETARCH

ARG \
    # renovate: datasource=repology depName=alpine_3_24/unzip
    UNZIP_VERSION=6.0-r16 \
    # renovate: datasource=github-releases depName=omeka-s packageName=omeka/omeka-s
    SOFTWARE_VERSION=4.2.0
ARG FILE=omeka-s-${SOFTWARE_VERSION}.zip
ARG URL=https://github.com/omeka/omeka-s/releases/download/v${SOFTWARE_VERSION}/${FILE}
ARG SHA256="1a62880df51d7f0c824bbfdcf8528bb1a1fc347cf01ca1fbdde8b5eeb76e4bdc"

ENV COMPOSER_ALLOW_SUPERUSER=1
WORKDIR /var/www/omeka-s

RUN --mount=type=cache,id=custom-omeka-s-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        unzip=="${UNZIP_VERSION}" \
    && \
    cleanup.sh

RUN --mount=type=cache,id=custom-omeka-s-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${URL}" \
        --sha256 "${SHA256}" \
        --strip \
        --dest "/var/www/omeka-s" \
    && \
    mkdir -p /var/www/omeka-s/files && \
    cleanup.sh

COPY --link composer.json composer.lock /var/www/omeka-s/

RUN --mount=type=cache,id=custom-omeka-s-composer-${TARGETARCH},sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/omeka-s --no-interaction --no-progress --prefer-dist --no-dev --optimize-autoloader && \
    cleanup.sh

COPY --link modules/ /var/www/omeka-s/modules/
COPY --link themes/ /var/www/omeka-s/themes/

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
    SMTP_FROM=

RUN chown -R nginx:nginx /var/www/omeka-s && \
    cleanup.sh
