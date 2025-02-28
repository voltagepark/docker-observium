FROM ubuntu:24.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && \
    apt -y install \
    apache2 cron fping graphviz imagemagick ipmitool snmp rrdtool subversion whois wget unzip \
    libapache2-mod-php8.3 php8.3-cli php8.3-mysql php8.3-gd php8.3-bcmath php8.3-mbstring php8.3-opcache php8.3-curl \
    php-apcu php-pear mysql-client libvirt-clients python3-mysqldb python3-pymysql python-is-python3 supervisor && \
    apt-get clean autoclean && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/cache/* /var/lib/log/*


COPY files/apache-observium.conf /etc/apache2/sites-enabled/000-default.conf
COPY files/cron-observium /etc/cron.d/observium
COPY files/supervisord.conf /etc/supervisord.conf
COPY files/docker-entrypoint.sh /usr/local/bin/

RUN a2dismod mpm_event && \
    a2enmod mpm_prefork && \
    a2enmod php8.3 && \
    a2enmod rewrite && \
    echo "TLS_REQCERT\tnever" >> /etc/ldap/ldap.conf && \
    chmod 0644 /etc/cron.d/observium && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

VOLUME ["/config"]
EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
