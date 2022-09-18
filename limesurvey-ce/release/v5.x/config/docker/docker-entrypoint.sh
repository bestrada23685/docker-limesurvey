#!/bin/bash

DB_TYPE="${DB_TYPE:-pgsql}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-limesurvey}"
DB_USERNAME="${DB_USERNAME:-postgres}"
DB_PASSWORD="${DB_PASSWORD:-}"
DB_PASSWORD_FILE="${DB_PASSWORD_FILE:-}"
DB_CHARSET="${DB_CHARSET:-utf8}"
DB_TABLE_PREFIX="${DB_TABLE_PREFIX:-lime_}"

ADMIN_USERNAME="${ADMIN_USERNAME:-admin}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-}"
ADMIN_PASSWORD_FILE="${ADMIN_PASSWORD_FILE:-}"
ADMIN_FULLNAME="${ADMIN_FULLNAME:-admin}"
ADMIN_EMAIL="${ADMIN_EMAIL:-'your-email@std.uni.edu.ni'}"

DEBUG="${DEBUG:-0}"
DEBUGSQL="${DEBUGSQL:-0}"

if [ ! -z "$DB_PASSWORD" ] && [ ! -z "$DB_PASSWORD_FILE" ]
then
    echo >&2 "[ERROR]: Both DB_PASSWORD and DB_PASSWORD_FILE are set (but are exclusive)."
    exit 1
fi

if [ ! -z "$DB_PASSWORD_FILE" ]
then
  DB_PASSWORD="$(< "$DB_PASSWORD_FILE")"
fi

if [ -z "$DB_PASSWORD" ]
then
    echo >&2 "[ERROR]: Missing DB_PASSWORD."
    exit 1
fi

if [ ! -z "$ADMIN_PASSWORD" ] && [ ! -z "$ADMIN_PASSWORD_FILE" ]
then
    echo >&2 "[ERROR]: Both ADMIN_PASSWORD and ADMIN_PASSWORD_FILE are set (but are exclusive)."
    exit 1
fi

if [ ! -z "$ADMIN_PASSWORD_FILE" ]
then
    ADMIN_PASSWORD="$(< "$ADMIN_PASSWORD_FILE")"
fi

if [ -z "$ADMIN_PASSWORD" ]
then
    echo >&2 "[ERROR]: Missing ADMIN_PASSWORD."
    exit 1
fi

until nc -z -v -w 30 "$DB_HOST" "$DB_PORT"
do
    echo "[INFO]: Waiting for database server connection..."
    sleep 5
done

if [ -f /var/www/html/limesurvey/application/config/config.php ]
then
    echo "[INFO]: config.php exists"
else
cat <<EOF >/var/www/html/limesurvey/application/config/config.php
<?php if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}
/*
| -------------------------------------------------------------------
| DATABASE CONNECTIVITY SETTINGS
| -------------------------------------------------------------------
| This file will contain the settings needed to access your database.
|
| For complete instructions please consult the 'Database Connection'
| page of the User Guide.
|
| -------------------------------------------------------------------
| EXPLANATION OF VARIABLES
| -------------------------------------------------------------------
|
|    'connectionString' Hostname, database, port and database type for
|     the connection. Driver example: mysql. Currently supported:
|                 mysql, pgsql, mssql, sqlite, oci
|    'username' The username used to connect to the database
|    'password' The password used to connect to the database
|    'tablePrefix' You can add an optional prefix, which will be added
|                 to the table name when using the Active Record class
|
*/
return array(
    'name' => 'LimeSurvey',
    'components' => array(
        'db' => array(
            'connectionString' => '$DB_TYPE:host=$DB_HOST;port=$DB_PORT;user=$DB_USERNAME;password=$DB_PASSWORD;dbname=$DB_NAME;',
            'emulatePrepare' => true,
            'username' => '$DB_USERNAME',
            'password' => '$DB_PASSWORD',
            'charset' => '$DB_CHARSET',
            'tablePrefix' => '$DB_TABLE_PREFIX',
        ),
        // Uncomment the following lines if you need table-based sessions.
        // Note: Table-based sessions are currently not supported on MSSQL server.
        // 'session' => array (
            // 'class' => 'application.core.web.DbHttpSession',
            // 'connectionID' => 'db',
            // 'sessionTableName' => '{{sessions}}',
        // ),
        'urlManager' => array(
            'urlFormat' => 'get',
            'rules' => array(
            // You can put your own rules here
            ),
            'showScriptName' => true,
        ),
    ),
    // Use the following config variable to set modified optional settings copied from config-defaults.php
    'config'=>array(
    // debug: Set this to 1 if you are looking for errors. If you still get no errors after enabling this
    // then please check your error-logs - either in your hosting provider admin panel or in some /logs directory
    // on your webspace.
    // LimeSurvey developers: Set this to 2 to additionally display STRICT PHP error messages and get full access to standard themes
        'debug'=>$DEBUG,
        'debugsql'=>$DEBUGSQL, // Set this to 1 to enanble sql logging, only active when debug = 2
        // 'force_xmlsettings_for_survey_rendering' => true, // Uncomment if you want to force the use of the XML file rather than DB (for easy theme development)
        // 'use_asset_manager'=>true, // Uncomment if you want to use debug mode and asset manager at the same time
    )
);
/* End of file config.php */
/* Location: ./application/config/config.php */ 
EOF
chmod 444 "/var/www/html/limesurvey/application/config/config.php"
chown "www-data:www-data" "/var/www/html/limesurvey/application/config/config.php"
fi

cd /var/www/html/limesurvey/

php application/commands/console.php updatedb

if [ $? -eq 0 ]
then
	echo "[INFO]:Database already exists."
else
	php application/commands/console.php install "$ADMIN_USERNAME" "$ADMIN_PASSWORD" "$ADMIN_FULLNAME" "$ADMIN_EMAIL" verbose
fi

php application/commands/console.php flushassets

exec "$@"