FROM		alpine:latest
MAINTAINER	Mihai Csaky "mihai.csaky@sysop-consulting.ro"

# set default variables for owncloud install
ENV DBTYPE mysql
ENV MYSQL_DBNAME owncloud
ENV MYSQL_DBHOST mysqldb
ENV MYSQL_DBUSER root
ENV MYSQL_DBPASS password
ENV ADMIN  admin
ENV ADMINPASS password

# update alpine linux
RUN		apk update && apk upgrade
RUN		apk add bash unzip

# add owncloud
ADD 	https://download.nextcloud.com/server/releases/latest.zip /tmp/
RUN	unzip -qq /tmp/latest.zip -d /

# add contacts, calander and documents app
#ADD	https://github.com/owncloud/contacts/releases/download/v1.1.0.0/contacts.tar.gz /tmp/
#RUN	tar -xzf /tmp/contacts.tar.gz -C /nextcloud/apps/
#ADD	https://github.com/owncloud/documents/releases/download/v0.12.0/documents.zip /tmp/
#RUN	unzip -qq /tmp/documents.zip -d /nextcloud/apps/
#ADD	https://github.com/owncloud/calendar/releases/download/v1.0/calendar.tar.gz /tmp/
#RUN	tar -xzf /tmp/calendar.tar.gz -C /nextcloud/apps/



# add owncloud dependencies
RUN             apk add sudo nginx php7-fpm \
	php7-ctype php7-dom php7-gd \
	php7-iconv php7-json php7-xml \
	php7-posix php7-xmlreader \
	php7-zip php7-zlib \
	php7-pdo php7-pdo_mysql php7-pdo_sqlite php7-mysqli\
	php7-curl php7-bz2 php7-intl php7-mcrypt php7-openssl\
	php7-ldap php7-imap php7-ftp\
	php7-pcntl php7-session php7-xmlwriter php7-simplexml php7-mbstring

# clean apk cache
RUN		rm -rf /var/cache/apk/*


# clean
RUN	rm /tmp/*


# fix rights
WORKDIR /nextcloud/
RUN 	chown -R root:nginx ./
#RUN 	chown -R nginx:nginx ./tmp
RUN 	chown -R nginx:nginx ./config; chmod 755 occ

# add nginx config
ADD	nginx.conf /etc/nginx/
ADD	php-fpm.conf /etc/php/
ADD	php.ini	/etc/php/

# add some script
ADD start.sh /usr/bin/
RUN chmod +x /usr/bin/start.sh
ADD set_rights.sh /usr/bin/
RUN chmod +x /usr/bin/set_rights.sh
RUN ln /nextcloud/occ /usr/bin/


VOLUME ["/nextcloud/config/","/nextcloud/data/"]

EXPOSE		80

ENTRYPOINT	["start.sh"]
