FROM hasholding/nginx-php-simple
LABEL maintainer "Levent SAGIROGLU <LSagiroglu@gmail.com>"

EXPOSE 80 443
ENV HESK_PATH "/shared/hesk"
ENV PHP_CONF "/etc/php7/php-fpm.d/www.conf"
ENV WEB_CONF "/etc/nginx/conf.d/default.conf"

ENV ADD_MODS_URL ""
ENV ADD_LANG_URL ""
VOLUME /shared
VOLUME /hesk
RUN apk add --update --no-cache php7-mysqli php7-json php7-session && \
    mkdir -p $HESK_PATH 

COPY entrypoint.sh /bin/entrypoint.sh
COPY default.conf /etc/nginx/conf.d/default.conf
COPY hesk282.zip /hesk/hesk282.zip
ENTRYPOINT ["/bin/entrypoint.sh"]
