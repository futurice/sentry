#!/usr/bin/env bash

if [ ! -z ${REMOTE_USER+x} ]; then
    # development user
    find /etc/nginx/nginx.conf -type f -exec sed -i "s~\$remote_user;~$REMOTE_USER;~g" {} \;
    # use proxied port in prod, in development the container port eg. :8000
    find /etc/nginx/nginx.conf -type f -exec sed -i "s~\$host;~\$host\:\$server_port;~g" {} \;
fi

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
