FROM php:7.3-cli-alpine as php73

ARG APCU_VERSION=5.1.22
ARG XDEBUG_VERSION=3.1.0

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		libzip-dev \
		zlib-dev \
	; \
	\
	docker-php-ext-configure zip; \
	docker-php-ext-install -j$(nproc) \
		zip \
	; \
	pecl install \
        apcu-${APCU_VERSION} \
        xdebug-${XDEBUG_VERSION} \
    ; \
	pecl clear-cache; \
	docker-php-ext-enable \
		apcu \
        xdebug \
	; \
    \
	echo "xdebug.client_host=docker.for.mac.localhost" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
		&& echo "xdebug.start_with_request=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
		&& echo "xdebug.mode=develop,debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .api-phpexts-rundeps $runDeps; \
	\
	apk del .build-deps

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

WORKDIR /srv

# prevent the reinstallation of vendors at every changes in the source code
COPY composer.json ./
# Composer install & clear cache… but without Xdebug enabled
RUN set -eux; \
	php -d xdebug.start_with_request=0 /usr/bin/composer install --prefer-dist --no-scripts --no-progress; \
	php -d xdebug.start_with_request=0 /usr/bin/composer clear-cache

RUN ls -als /srv
RUN ls -als /srv

COPY spec spec/
COPY src src/
COPY tests tests/

RUN ls -als /srv

COPY docker/php/common/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["php", "-a"]


FROM php:7.4-cli-alpine as php74

ARG APCU_VERSION=5.1.22
ARG XDEBUG_VERSION=3.1.0

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		libzip-dev \
		zlib-dev \
	; \
	\
	docker-php-ext-configure zip; \
	docker-php-ext-install -j$(nproc) \
		zip \
	; \
	pecl install \
		apcu-${APCU_VERSION} \
        xdebug-${XDEBUG_VERSION} \
	; \
	pecl clear-cache; \
	docker-php-ext-enable \
		apcu \
	; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .api-phpexts-rundeps $runDeps; \
	\
	apk del .build-deps

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

WORKDIR /srv

# prevent the reinstallation of vendors at every changes in the source code
COPY composer.json ./
RUN set -eux; \
	composer install --prefer-dist --no-scripts --no-progress; \
	composer clear-cache

RUN ls -als /srv
RUN ls -als /srv

COPY spec spec/
COPY src src/
COPY tests tests/

RUN ls -als /srv

COPY docker/php/common/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["php", "-a"]


FROM php:8.0-cli-alpine as php80

ARG APCU_VERSION=5.1.22
ARG XDEBUG_VERSION=3.2.0

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
        linux-headers \
		libzip-dev \
		zlib-dev \
	; \
	\
	docker-php-ext-configure zip; \
	docker-php-ext-install -j$(nproc) \
		zip \
	; \
	pecl install \
		apcu-${APCU_VERSION} \
        xdebug-${XDEBUG_VERSION} \
	; \
	pecl clear-cache; \
	docker-php-ext-enable \
		apcu \
	; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .api-phpexts-rundeps $runDeps; \
	\
	apk del .build-deps

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

WORKDIR /srv

# prevent the reinstallation of vendors at every changes in the source code
COPY composer.json ./
RUN set -eux; \
	composer install --prefer-dist --no-scripts --no-progress; \
	composer clear-cache

RUN ls -als /srv
RUN ls -als /srv

COPY spec spec/
COPY src src/
COPY tests tests/

RUN ls -als /srv

COPY docker/php/common/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["php", "-a"]


FROM php:8.1-cli-alpine as php81

ARG APCU_VERSION=5.1.22
ARG XDEBUG_VERSION=3.2.0

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
        linux-headers \
		libzip-dev \
		zlib-dev \
	; \
	\
	docker-php-ext-configure zip; \
	docker-php-ext-install -j$(nproc) \
		zip \
	; \
	pecl install \
		apcu-${APCU_VERSION} \
        xdebug-${XDEBUG_VERSION} \
	; \
	pecl clear-cache; \
	docker-php-ext-enable \
		apcu \
	; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .api-phpexts-rundeps $runDeps; \
	\
	apk del .build-deps

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

WORKDIR /srv

# prevent the reinstallation of vendors at every changes in the source code
COPY composer.json ./
RUN set -eux; \
	composer install --prefer-dist --no-scripts --no-progress; \
	composer clear-cache

RUN ls -als /srv
RUN ls -als /srv

COPY spec spec/
COPY src src/
COPY tests tests/

RUN ls -als /srv

COPY docker/php/common/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["php", "-a"]


FROM php:8.2-cli-alpine as php82

ARG APCU_VERSION=5.1.22
ARG XDEBUG_VERSION=3.2.0

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
        linux-headers \
		libzip-dev \
		zlib-dev \
	; \
	\
	docker-php-ext-configure zip; \
	docker-php-ext-install -j$(nproc) \
		zip \
	; \
	pecl install \
		apcu-${APCU_VERSION} \
        xdebug-${XDEBUG_VERSION} \
	; \
	pecl clear-cache; \
	docker-php-ext-enable \
		apcu \
	; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .api-phpexts-rundeps $runDeps; \
	\
	apk del .build-deps

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

WORKDIR /srv

# prevent the reinstallation of vendors at every changes in the source code
COPY composer.json ./
RUN set -eux; \
	composer install --prefer-dist --no-scripts --no-progress; \
	composer clear-cache

RUN ls -als /srv
RUN ls -als /srv

COPY spec spec/
COPY src src/
COPY tests tests/

RUN ls -als /srv

COPY docker/php/common/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["php", "-a"]
