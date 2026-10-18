# functionalchaos.net: build the Sculpin site, then serve the static output with unprivileged nginx.
#
# Content that is NOT in git (photos/, pe7700/, ~6.4 GB) is not baked in. It lives on a Longhorn
# volume mounted at /srv/content (see .k8s/fc-prod-nginx-deployment.yaml and README.md).

FROM php:8.5-cli-alpine AS builder

# Icelus (the thumbnail() Twig function that generates _thumbs/) uses Imagick when it's loaded, otherwise GD.
# Use Imagick: Icelus 4.0.0-alpha2's GD path leaves black bars on cropped thumbnails and mis-sizes fitted ones.
RUN apk add --no-cache git unzip imagemagick imagemagick-jpeg \
 && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS imagemagick-dev \
 && pecl install imagick \
 && docker-php-ext-enable imagick \
 && apk del .build-deps \
 && curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer \
 && echo 'date.timezone = America/Los_Angeles' > "$PHP_INI_DIR/conf.d/timezone.ini"

WORKDIR /build
COPY . .
RUN composer install --no-interaction --no-dev --prefer-dist --optimize-autoloader
RUN vendor/bin/sculpin generate --env=prod

# Final image: static files only
FROM nginxinc/nginx-unprivileged:1.28-alpine

COPY .docker/nginx/conf.d/site.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /build/output_prod /usr/share/nginx/html

EXPOSE 8080
