ARG BASE_IMAGE=libops/omeka-s:4.2.1-php84
FROM ${BASE_IMAGE}

WORKDIR /var/www/omeka-s

# nginx:nginx in the base image.
COPY --link --chown=100:101 modules/ /var/www/omeka-s/modules/
COPY --link --chown=100:101 themes/ /var/www/omeka-s/themes/
