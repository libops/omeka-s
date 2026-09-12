ARG BASE_IMAGE=libops/omeka-s:4.2.1-php84@sha256:4fe4e594c3e2fc9c26a64a02dbec88e6a38752fdd2072650fbb7edd47a27b0e0
FROM ${BASE_IMAGE}

WORKDIR /var/www/omeka-s

# nginx:nginx in the base image.
COPY --link --chown=100:101 modules/ /var/www/omeka-s/modules/
COPY --link --chown=100:101 themes/ /var/www/omeka-s/themes/
