FROM ubuntu:16.04

EXPOSE 80 443

# Keep upstart from complaining
# RUN dpkg-divert --local --rename --add /sbin/initctl
# RUN ln -sf /bin/true /sbin/initctl

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

ADD ./foreground.sh /etc/apache2/foreground.sh

RUN apt-get update && \
    apt-get install -y python-software-properties software-properties-common && \
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && \
    apt-get update && \
	apt-get -y install mysql-client pwgen python-setuptools curl git unzip apache2 php5.6 \
		php5.6-gd libapache2-mod-php5.6 wget supervisor php5.6-pgsql curl libcurl3 \
		libcurl3-dev php5.6-curl php5.6-xmlrpc php5.6-intl php5.6-mysql git-core php5.6-xml php5.6-mbstring php5.6-zip php5.6-soap && \
	chown -R www-data:www-data /var/www/html && \
	chmod +x /etc/apache2/foreground.sh

# Enable SSL, moodle requires it
RUN a2enmod ssl && a2ensite default-ssl  #if using proxy dont need actually secure connection

#instalación de ioncube
ADD ./ioncube_loader_lin_5.6.so /usr/lib/php/20131226
ADD ./00-ioncube.ini /etc/php/5.6/apache2/conf.d

# Cleanup, this is ran to reduce the resulting size of the image.
RUN apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/dpkg/* /var/lib/cache/* /var/lib/log/*

CMD ["/etc/apache2/foreground.sh"]