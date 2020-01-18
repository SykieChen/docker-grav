FROM php:fpm
# Mod from https://github.com/getgrav/docker-grav/blob/master/Dockerfile

# Install dependencies
RUN apt-get update && apt-get install -y \
        unzip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libyaml-dev \
        libzip-dev \
        cron \
    && docker-php-ext-install opcache \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install zip \
    && (crontab -u www-data -l; echo "* * * * * cd /var/www/com.coder17.www;/usr/local/bin/php bin/grav scheduler 1>> /dev/null 2>&1") | crontab -u www-data - \
    && (crontab -l; echo "* * * * * cd /var/www/com.coder17.www;/usr/local/bin/php bin/grav scheduler 1>> /dev/null 2>&1") | crontab - \
    && service cron start


# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
		echo 'upload_max_filesize=128M'; \
		echo 'post_max_size=128M'; \
	} > /usr/local/etc/php/conf.d/php-recommended.ini


RUN pecl install apcu \
    && pecl install yaml \
    && docker-php-ext-enable apcu yaml
