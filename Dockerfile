ARG BASE_IMAGE=libops/omeka-s:4.2.1-php84@sha256:61ed832c3b64be071a33a4e42b2cf03826d930c70b05f710e7cb7381d6f1fa94
FROM ${BASE_IMAGE}

WORKDIR /var/www/omeka-s

# nginx:nginx in the base image.
COPY --link --chown=100:101 modules/ /var/www/omeka-s/modules/
COPY --link --chown=100:101 themes/ /var/www/omeka-s/themes/
