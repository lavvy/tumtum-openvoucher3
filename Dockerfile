FROM ubuntu:trusty
MAINTAINER Fernando Mayo <fernando@tutum.co>, Feng Honglin <hfeng@tutum.co>

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install supervisor git apache2 libapache2-mod-php5 mysql-server php5-mysql pwgen php-apc php5-mcrypt && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
#RUN git clone https://github.com/fermayo/hello-world-lamp.git /app
#RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

#adding my own little hack

##RUN git clone https://github.com/litzinetz-de/OpenVoucher.git /app2
#ADD https://github.com/litzinetz-de/OpenVoucher/archive/0.4.2.tar.gz /app2/
#RUN tar -xJf /app2/OpenVoucher-0.4.2.tar.xz -C /app2
#RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html && cp -a /app2/src/ /app/ && rm -rf /app/.htaccess

#use curl download untar and delete tar file
#ADD https://github.com/litzinetz-de/OpenVoucher/archive/0.4.2.tar.gz /app2/code.tar.xz
#RUN tar -zxvf /app2/code.tar.gz -C /app2
#RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html && cp -a /app2/OpenVoucher-0.4.2/src/ /app/ && rm -rf /app/.htaccess


#ENV SQLBUDDY_URL https://codeload.github.com/lavvy/sqlbuddy/tar.gz/v1.0.0
ENV SQLBUDDY_URL https://github.com/litzinetz-de/OpenVoucher/archive/0.4.2.tar.gz

ENV HTTP_DOCUMENTROOT /app 


# RUN wget -O /tmp/sqlbuddy.tar.gz ${SQLBUDDY_URL}

ADD ${SQLBUDDY_URL} sqlbuddy.tar.gz
RUN tar -zxf sqlbuddy.tar.gz
RUN mkdir -p /app 
RUN cp -pr OpenVoucher-0.4.2-*/src/* ${HTTP_DOCUMENTROOT}/
#RUN rm -rf sqlbuddy-*
RUN chown -R www-data:www-data ${HTTP_DOCUMENTROOT}


#WORKDIR "/app"
#COPY src /app



#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80 3306
CMD ["/run.sh"]
