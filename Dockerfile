FROM php:7.1

RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/bin --filename=composer --version=1.5.2

COPY ./ /home/a

CMD ["php", "-a"]