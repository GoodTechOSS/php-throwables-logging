#!/bin/sh
set -e

echo 123;

php -d xdebug.start_with_request=0 /usr/bin/composer install --prefer-dist --no-progress --no-interaction

exec docker-php-entrypoint "$@"
