#!/bin/sh

if [ -f "${PHP_CONF}" ];
then
	cp -f "${PHP_CONF}" /etc/php7/php-fpm.d/www.conf &> /dev/null
fi

if [ -f "${WEB_CONF}" ];
then
	cp -f "${WEB_CONF}" /etc/nginx/conf.d/default.conf &> /dev/null
fi

sed -i "s|root \/shared\/hesk\/;|root $HESK_PATH/;|g" /etc/nginx/conf.d/default.conf

if [ "$(ls -A "${HESK_PATH}")" ]; then
   echo "$HESK_PATH is not Empty"
else
  if [ "${MODE}" = "run" ] ; then
   echo "${HESK_PATH} is Empty"
   exit 1
  else
   MODE="install"
  fi
fi

if [ "${MODE}"x = "x" ]; then
	   MODE="run"
fi

echo "MODE: $MODE" 

if [ "${MODE}" = "backup" ] ; then
  echo "${HESK_PATH} hesk_settings.inc.php header.txt footer.txt"
fi

if [ "${MODE}" = "install" ] ; then
  mkdir -p "${HESK_PATH}"
  unzip /hesk/hesk*.zip -o -d "${HESK_PATH}" -x hesk_settings.inc.php header.txt footer.txt
  unzip /hesk/hesk*.zip -n -d "${HESK_PATH}" hesk_settings.inc.php header.txt footer.txt
  
  if [ "${ADD_MODS_URL}" != "" ];
  then
    wget -qO- "${ADD_MODS_URL}" | tar xvz -C "${HESK_PATH}" --strip 1
  fi

  if [ "${ADD_LANG_URL}" != "" ]; 
  then
    echo "ADD LANG" 
    wget -qO- "${ADD_LANG_URL}" | tar xvz -C "${HESK_PATH}"/language/
  fi

  chmod 755 -R "${HESK_PATH}"
  chmod 666    "${HESK_PATH}"/hesk_settings.inc.php
  chmod 777 -R "${HESK_PATH}"/attachments
  chmod 777 -R "${HESK_PATH}"/cache
  echo "Start..."
  /usr/sbin/php-fpm7
  /usr/sbin/nginx -g "daemon off;"
fi

if [ "${MODE}" = "run" ] ; then
  rm -fR "$HESK_PATH"/install
  echo "Start..."
  /usr/sbin/php-fpm7
  /usr/sbin/nginx -g "daemon off;"
fi 
