FROM ubuntu:trusty
MAINTAINER agix

# Install packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install supervisor git apache2 libapache2-mod-php5 pwgen imagemagick sqlite3 openssh-server

RUN apt-get install php5-sqlite

#Install ssh
RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

# Add image configuration and scripts
ADD set_root_pw.sh /set_root_pw.sh
ADD start-apache2.sh /start-apache2.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
ADD .htpasswd /etc/apache2/.htpasswd
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN mkdir -p /app
RUN git clone https://github.com/agix/vuln_g00dcorner /app/content
RUN rm -rf /app/content/.git
RUN mkdir -p /app/secured && mkdir -p /app/content && rm -fr /var/www/html && ln -s /app/content /var/www/html
RUN mkdir -p /app/secured/avatars && mkdir -p /app/secured/photos
RUN chown -R www-data:www-data /app/secured

EXPOSE 80 22
CMD ["/run.sh"]
