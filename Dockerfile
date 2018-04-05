FROM ttskch/nginx-php-fpm-heroku

WORKDIR /tmp

RUN wget http://docs.aws.amazon.com/aws-sdk-php/v3/download/aws.zip
RUN mkdir /docroot/libs && mkdir /docroot/libs/aws
RUN unzip aws.zip -d /docroot/libs/aws

RUN wget https://flowpaper.com/annotations_builds/FlowPaper_Annotations_Trial.zip
RUN mkdir /docroot/flowpaper && unzip FlowPaper_Annotations_Trial.zip -d /docroot/flowpaper
COPY alma.php /docroot/flowpaper/php/alma.php
COPY config.ini.nix.php /docroot/flowpaper/php/config/config.ini.nix.php

# Allow environment variables to be used
RUN sed -e 's/;clear_env = no/clear_env = no/' -i /etc/php7/php-fpm.d/www.conf

USER nonroot
