FROM php:8.3-apache-bookworm

# --- Apache ---
RUN a2enmod headers rewrite \
 && { echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf; } \
 && a2enconf servername

# VHost inkl. DirectoryIndex
RUN set -eux; \
  { \
    echo '<VirtualHost *:80>'; \
    echo '  ServerAdmin webmaster@localhost'; \
    echo '  DocumentRoot /var/www/html'; \
    echo '  <Directory /var/www/html>'; \
    echo '    Options FollowSymLinks'; \
    echo '    AllowOverride All'; \
    echo '    Require all granted'; \
    echo '  </Directory>'; \
    echo '  DirectoryIndex index.php index.html'; \
    echo '  ErrorLog ${APACHE_LOG_DIR}/error.log'; \
    echo '  CustomLog ${APACHE_LOG_DIR}/access.log combined'; \
    echo '  Header always set X-Content-Type-Options nosniff'; \
    echo '</VirtualHost>'; \
  } > /etc/apache2/sites-available/000-default.conf

# --- Systempakete / Libs für PHP-Extensions ---
# HTTP-Mirror (deb.debian.org) liefert hier teils korrupte .debs → Hash Sum mismatch.
# HTTPS umgeht das; betrifft Netzwerk/Mirror, nicht Intel vs. Apple Silicon.
RUN sed -i 's|http://deb.debian.org|https://deb.debian.org|g' /etc/apt/sources.list.d/debian.sources \
 && apt-get update && apt-get install -y --no-install-recommends \
    curl unzip ca-certificates \
    pkg-config g++ \
    libicu-dev \
    libonig-dev \
    libxslt1-dev \
    libzip-dev \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    imagemagick libmagickwand-dev \
 && rm -rf /var/lib/apt/lists/*

# --- PHP-Extensions ---
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" xsl mbstring pdo pdo_mysql zip gd opcache intl \
 && pecl install imagick && docker-php-ext-enable imagick || true

# --- Optionaler Build-Cache für wSetup.zip ---
ARG WSETUP_URL="https://dev.weblication.de/dev/downloads/wSetup.zip"
RUN set -eux; mkdir -p /opt/weblication; \
    if curl -fSL "$WSETUP_URL" -o /opt/weblication/wSetup.zip; then \
      echo "wSetup.zip gecached."; \
    else \
      echo "WARN: wSetup.zip konnte beim Build nicht geladen werden – wird zur Laufzeit versucht."; \
    fi

# --- Entrypoint ---
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh \
 && chown -R www-data:www-data /var/www/html

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
