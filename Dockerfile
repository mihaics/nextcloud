FROM		alpine:3.3
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

# add owncloud dependencies
RUN             apk add nginx php-fpm \
	php-ctype php-dom php-gd \
	php-iconv php-json php-xml \
	php-posix php-xmlreader \
	php-zip php-zlib \
	php-pdo php-pdo_mysql php-pdo_sqlite php-mysql\
	php-curl php-bz2 php-intl php-mcrypt php-openssl\
	php-ldap php-imap php-ftp\
	php-pcntl 

# clean apk cache
RUN		rm -rf /var/cache/apk/*

# add owncloud
ADD 	https://download.nextcloud.com/server/releases/nextcloud-10.0.0.zip /tmp/
RUN	unzip -qq /tmp/nextcloud-10.0.0.zip -d /

# add contacts, calander and documents app
ADD	https://github.com/owncloud/contacts/releases/download/v1.1.0.0/contacts.tar.gz /tmp/
RUN	tar -xzf /tmp/contacts.tar.gz -C /nextcloud/apps/
ADD	https://github.com/owncloud/documents/releases/download/v0.12.0/documents.zip /tmp/
RUN	unzip -qq /tmp/documents.zip -d /nextcloud/apps/
ADD	https://github.com/owncloud/calendar/releases/download/v1.0/calendar.tar.gz /tmp/
RUN	tar -xzf /tmp/calendar.tar.gz -C /nextcloud/apps/

# clean
RUN	rm /tmp/*

# fix rights
WORKDIR /nextcloud/
RUN 	chown -R root:nginx ./
#RUN 	chown -R nginx:nginx ./tmp
RUN 	chown -R nginx:nginx ./config

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
