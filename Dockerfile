ARG BASE_IMAGE=libops/omeka-s:4.2.1-php84@sha256:3c9d1a0558b705235104998d260dfe916b156fed21b8c34ca0aa5e9bd33bfbee
FROM ${BASE_IMAGE}

WORKDIR /var/www/omeka-s

# nginx:nginx in the base image.
COPY --link --chown=100:101 modules/ /var/www/omeka-s/modules/
COPY --link --chown=100:101 themes/ /var/www/omeka-s/themes/
