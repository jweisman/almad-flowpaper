FROM ttskch/nginx-php-fpm-heroku
RUN apk add --update alpine-sdk libjpeg-turbo-dev freetype-dev pdftk

RUN wget https://github.com/flexpaper/pdf2json/releases/download/v0.69/pdf2json-0.69.tar.gz \
	&& mkdir pdf2json \
	&& tar -xzf pdf2json-0.69.tar.gz -C pdf2json/ \
	&& cd pdf2json \
	&& sed -e 's/sys\/unistd.h/unistd.h/' -i src/XmlLinks.h \
	&& ./configure  \
	&& make \
	&& make install

RUN wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/flexpaper-desktop-publisher/swftools-0.9.2.tar.gz \
	&& tar -xvf swftools-0.9.2.tar.gz  \
	&& cd swftools-0.9.2 \
	&& LIBRARY_PATH=/lib:/usr/lib ./configure \
	&& make \
	&& sed -e 's/-o -L/#-o -L/' -i swfs/Makefile \
	&& make install

WORKDIR /tmp

RUN wget http://docs.aws.amazon.com/aws-sdk-php/v3/download/aws.zip
RUN mkdir /docroot/libs && mkdir /docroot/libs/aws
RUN unzip aws.zip -d /docroot/libs/aws

RUN wget https://flowpaper.com/annotations_builds/FlowPaper_Annotations_Trial.zip
RUN mkdir /docroot/flowpaper && unzip FlowPaper_Annotations_Trial.zip -d /docroot/flowpaper
COPY alma.php /docroot/flowpaper/php/alma.php
COPY config.ini.nix.php /docroot/flowpaper/php/config/config.ini.nix.php

# Allow environment variables to be used
RUN echo $'env[ALMA_API_KEY] = $ALMA_API_KEY \n\
env[AWS_ACCESS_KEY_ID] = $AWS_ACCESS_KEY_ID \n\
env[AWS_SECRET_ACCESS_KEY] = $AWS_SECRET_ACCESS_KEY \n\
env[PATH] = /usr/local/bin:/usr/bin:/bin' >> /etc/php7/php-fpm.d/www.conf

USER nonroot
