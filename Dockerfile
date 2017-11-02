FROM ubuntu:16.04
MAINTAINER Jussi Vaihia <jussi.vaihia@futurice.com>

WORKDIR /opt/app
RUN useradd -m app

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
	build-essential locales vim htop wget \
	python python-pip python-dev \
	supervisor libpq-dev \
	git unzip redis-server memcached \
    libxml2-dev libxslt1-dev libz-dev libffi-dev \
    libpcre3 libpcre3-dev libssl-dev libjpeg8-dev

# Nginx
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN echo "deb http://nginx.org/packages/ubuntu/ trusty nginx" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y nginx-full
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN mkdir -p /opt/app
RUN chown app /opt/app

COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

RUN chown app /opt/
USER app

ADD docker/supervisord.conf /etc/supervisor/supervisord.conf
ADD docker/nginx.conf /etc/nginx/nginx.conf
ADD sentry.conf.py /etc/sentry/sentry.conf.py
ADD config.yml /etc/sentry/config.yml

COPY . /opt/app/

ENV SENTRY_SECRET_KEY default_insecure_secret_that_is_really_really_long
ENV CELERY_LOG_LEVEL info
ENV SENTRY_CONF /etc/sentry

EXPOSE 8000

USER root
CMD ["bash", "docker/start.sh"]
