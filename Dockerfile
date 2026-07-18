ARG BASE_IMAGE=libops/omeka-s:4.2.1-php84@sha256:bd5811eb21a7f56f92ce31ab47c78c5f7870918555ff99a45938befd6b080b22
FROM ${BASE_IMAGE}

WORKDIR /var/www/omeka-s

# nginx:nginx in the base image.
COPY --link --chown=100:101 modules/ /var/www/omeka-s/modules/
COPY --link --chown=100:101 themes/ /var/www/omeka-s/themes/
