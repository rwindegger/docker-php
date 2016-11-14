FROM php:fpm

MAINTAINER rene@windegger.wtf

# install the PHP extensions we need
RUN apt-get update \
	&& apt-get install -y \
		mysql-client \
		libmysqlclient-dev \
		libpng12-dev \
		libjpeg-dev \
		libmemcached-dev \
		libfreetype6-dev \
		libmagickwand-dev \
		libxml2-dev \
		ssmtp \
		zip \
		libgeoip-dev \
    		--no-install-recommends \
  	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mysqli opcache soap mbstring pdo_mysql zip \
	&& docker-php-ext-enable gd \
	&& docker-php-ext-enable opcache \
	&& docker-php-ext-enable memcache \
	&& pecl install imagick \
	&& docker-php-ext-enable imagick

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
	
RUN { \
	echo 'max_input_time = 60'; \
	echo 'max_execution_time = 120'; \
	echo 'upload_max_filesize = 64M'; \
	echo 'post_max_size = 64m'; \
	echo 'memory_limit = 256M'; \
	echo 'expose_php = off'; \
} > /usr/local/etc/php/conf.d/uploadsettings.ini

COPY docker-entrypoint.sh /entrypoint.sh

# WORKDIR is /var/www/html (inherited via "FROM php")
# "/entrypoint.sh" will populate it at container startup from /usr/src/piwik
VOLUME /var/www/html

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
