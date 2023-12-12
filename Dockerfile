FROM php:5.6.40-apache
RUN cat /etc/os-release
RUN rm -rf /etc/apt/sources.list && rm -rf /etc/apache2/sites-enabled/000-default.conf

COPY ./sources.list /etc/apt/sources.list
COPY ./000-default.conf /etc/apache2/sites-enabled/000-default.conf

RUN apt-get update -y && apt-get install -y  curl wget nano git libapache2-mod-proxy-uwsgi

RUN apt-get update && \
    apt-get install -y \
        zlib1g-dev libpng-dev

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# make sure apt is up to date
RUN apt-get update --fix-missing
RUN apt-get install -y curl
RUN apt-get install -y build-essential libssl-dev        

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 7.10.1

# Install nvm with node and npm
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.30.1/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH


WORKDIR /tmp
RUN wget https://getcomposer.org/download/1.5.4/composer.phar
RUN mv composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer


RUN docker-php-ext-install pdo pdo_mysql mbstring zip gd

WORKDIR /var/www/html/
RUN a2enmod -m proxy_http proxy_wstunnel

CMD ["tail", "-f", "/dev/null"]
