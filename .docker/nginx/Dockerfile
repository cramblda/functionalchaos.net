# functionalchaos.net: build the Sculpin site, then serve the static output with unprivileged nginx.
#
# Content that is NOT in git (photos/, pe7700/, ~6.4 GB) is not baked in. It lives on a Longhorn
# volume mounted at /srv/content (see .k8s/fc-prod-nginx-deployment.yaml and README.md).

FROM php:8.3-cli-alpine AS builder

# GD is required by Imanee, which Sculpin uses to generate the _thumbs images.
RUN apk add --no-cache git unzip libpng libjpeg-turbo freetype \
 && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS libpng-dev libjpeg-turbo-dev freetype-dev \
 && docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install gd \
 && apk del .build-deps \
 && curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /build
# app/config/sculpin_site.yml is gitignored but required: it comes from the local working copy.
COPY . .
RUN composer install --no-interaction --no-dev --prefer-dist --optimize-autoloader
RUN vendor/bin/sculpin generate --env=prod

# Final image: static files only
FROM nginxinc/nginx-unprivileged:1.28-alpine

COPY .docker/nginx/conf.d/site.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /build/output_prod /usr/share/nginx/html

EXPOSE 8080
