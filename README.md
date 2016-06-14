# NextCloud Docker Container
All you need to build a docker container of NextCloud.
This container is based on aphine and contains the NextCloud apps contacts, documents and calendar.
Also there is no tls/ssl support. For transport encryption you should use a separate
nginx reverse proxy.

## Run with existing config
To run this container you need an existing NextCloud config and data directory

    docker run --name nextcloud -v $PWD/config:/nextcloud/config -v $PWD/data:/nextcloud/data mcsaky/nextcloud

Depending on your database you should link this container to a database container.

## Run NextCloud for the first time
For the first run without existing configuration or database you could set this
Envirenment variables:

|Variable| Default | Description |
|--------|---------|-------------|
|DBTYPE  | mysql       | Type of database (only mysql supportet yet)|
|DBNAME  | owncloud    | Database name                              |
|DBHOST  | mysqldb     | Hostname or address to database           |
|DBUSER  | root        | Database Username for NextCloud             |
|DBPASS  | password    | Password for database username             |
|ADMIN   | admin       | Username for NextCloud administrator        |
|ADMINPASS| password   | Password for NextCloud administrator        |

Or run with the default settings like this:

    docker run --name db -e MYSQL_ROOT_PASSWORD=password -d mariadb
    docker run --name nextcloud -v $PWD/config:/nextcloud/config \
                               -v $PWD/data:/nextcloud/data \
                               --link db:mysqldb mcsaky/nextcloud


## Add more NextCloud apps
To add more apps copy the download link of the app and add two lines like this to
the Dockerfile:

    ADD	https://github.com/owncloud/calendar/releases/download/v1.0/calendar.tar.gz /tmp/
    RUN	tar -xzf /tmp/calendar.tar.gz -C /nextcloud/apps/

Additional the app must be enable add container start, so you should add a line
like the following to the start.sh:

    $ocdir/occ app:enable calendar

Now rebuild the image.
