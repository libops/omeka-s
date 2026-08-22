ARG BASE_IMAGE=libops/omeka-s:4.2.1-php84@sha256:5cc879c793709c092182c790148b0a7352eee2b7c506a6ab3f8074b278849582
FROM ${BASE_IMAGE}

WORKDIR /var/www/omeka-s

# nginx:nginx in the base image.
COPY --link --chown=100:101 modules/ /var/www/omeka-s/modules/
COPY --link --chown=100:101 themes/ /var/www/omeka-s/themes/
