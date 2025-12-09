FROM php:8.4-apache

# System dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    libicu-dev \
    libpq-dev \
    libzip-dev \
    unzip \
    && docker-php-ext-install intl pdo_mysql pdo_pgsql zip \
    && a2enmod rewrite \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy the application ('.env' and other local files are excluded via .dockerignore)
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Ensure Apache serves from the public directory
RUN sed -ri 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf

# Clean any locally-generated caches and fix permissions for runtime writes
RUN rm -f bootstrap/cache/*.php \
    && chown -R www-data:www-data storage bootstrap/cache

CMD ["apache2-foreground"]
