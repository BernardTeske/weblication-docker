FROM php:8.3-apache

# Apache-Module
RUN a2enmod headers rewrite

# Systempakete + Build-Tools + Libs für Extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl unzip \
    pkg-config g++ \
    libicu-dev \
    libonig-dev \ 
    libxslt1-dev \
    libzip-dev \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    imagemagick libmagickwand-dev \
    libwebp-dev libavif-dev \
 && rm -rf /var/lib/apt/lists/*

# GD korrekt konfigurieren (JPEG + FreeType); dann Extensions bauen
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" \
    xsl mbstring pdo pdo_mysql zip gd opcache intl

# Imagick (optional)
RUN pecl install imagick && docker-php-ext-enable imagick || true
