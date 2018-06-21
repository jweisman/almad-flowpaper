FROM joshmweisman/nginx-php-docker
RUN apk add --update alpine-sdk libjpeg-turbo-dev freetype-dev pdftk

RUN wget https://github.com/flexpaper/pdf2json/releases/download/v0.69/pdf2json-0.69.tar.gz \
	&& mkdir pdf2json \
	&& tar -xzf pdf2json-0.69.tar.gz -C pdf2json/ \
	&& cd pdf2json \
	# Incorrect path in .h file
	&& sed -e 's/sys\/unistd.h/unistd.h/' -i src/XmlLinks.h \
	&& ./configure  \
	&& make \
	&& make install

RUN wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/flexpaper-desktop-publisher/swftools-0.9.2.tar.gz \
	&& tar -xvf swftools-0.9.2.tar.gz  \
	&& cd swftools-0.9.2 \
	&& LIBRARY_PATH=/lib:/usr/lib ./configure \
	&& make \
	# Makefile includes rm with -o flag
	&& sed -e 's/-o -L/#-o -L/' -i swfs/Makefile \
	&& make install

WORKDIR /tmp

RUN wget http://docs.aws.amazon.com/aws-sdk-php/v3/download/aws.zip \
	&& mkdir $DOCROOT/libs $DOCROOT/libs/aws \
	&& unzip aws.zip -d $DOCROOT/libs/aws

RUN wget https://flowpaper.com/annotations_builds/FlowPaper_Annotations_Trial.zip \
	&& mkdir $DOCROOT/flowpaper \
	&& unzip FlowPaper_Annotations_Trial.zip -d $DOCROOT/flowpaper

COPY alma.php $DOCROOT/flowpaper/php/
COPY config.ini.nix.php $DOCROOT/flowpaper/php/config/

# Allow environment variables to be used
RUN echo $'env[ALMA_API_KEY] = $ALMA_API_KEY \n\
env[AWS_ACCESS_KEY_ID] = $AWS_ACCESS_KEY_ID \n\
env[AWS_SECRET_ACCESS_KEY] = $AWS_SECRET_ACCESS_KEY \n\
env[PATH] = /usr/local/bin:/usr/bin:/bin' >> /usr/local/etc/php-fpm.d/www.conf

USER www
