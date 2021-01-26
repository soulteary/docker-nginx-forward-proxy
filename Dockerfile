FROM nginx:1.19.6-alpine AS builder

ARG NGINX_VERSION=1.19.6
ARG CONNECT_VERSION=cb4dcd
ARG PACHER_VERSION=proxy_connect_rewrite_1018

RUN apk add --no-cache --virtual .build-deps gcc libc-dev make openssl-dev pcre-dev zlib-dev linux-headers libxslt-dev gd-dev geoip-dev perl-dev libedit-dev mercurial bash alpine-sdk findutils

RUN mkdir -p /usr/src && cd /usr/src && \
    curl -L "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -o nginx.tar.gz && \
    curl -L "https://github.com/soulteary/ngx_http_proxy_connect_module/archive/${CONNECT_VERSION}.tar.gz" -o ngx_http_proxy_connect_module.tar.gz && \
    tar zxvf nginx.tar.gz && \
    tar zxvf ngx_http_proxy_connect_module.tar.gz && \
    cd /usr/src/nginx-1.19.6 && \
    patch -p1 < ../ngx_http_proxy_connect_module-${CONNECT_VERSION}/patch/${PACHER_VERSION}.patch && \
    CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
    CONFARGS=${CONFARGS/-Os -fomit-frame-pointer/-Os} && \
    echo $CONFARGS && \
    ./configure --with-compat $CONFARGS --add-dynamic-module=../ngx_http_proxy_connect_module-${CONNECT_VERSION}/ && \
    make && make install

FROM nginx:1.19.6-alpine
COPY --from=builder /etc/nginx/modules/ngx_http_proxy_connect_module.so /etc/nginx/modules/
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY conf/nginx.conf /etc/nginx/nginx.conf
