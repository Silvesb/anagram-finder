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

# Ensure no cached configuration or routes ship with the image so
# Render-provided environment variables take effect at runtime.
RUN php artisan config:clear \
    && php artisan route:clear \
    && php artisan view:clear

# Ensure Apache serves from the public directory
RUN sed -ri 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf

# Clean any locally-generated caches, ensure writable directories exist, and fix permissions
RUN rm -f bootstrap/cache/*.php \
    && mkdir -p storage/framework/sessions \
    && mkdir -p storage/framework/cache/data \
    && mkdir -p storage/framework/testing \
    && mkdir -p storage/framework/views \
    && mkdir -p storage/logs \
    && chown -R www-data:www-data storage bootstrap/cache

CMD ["apache2-foreground"]
