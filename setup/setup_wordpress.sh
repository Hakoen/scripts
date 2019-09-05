#!/bin/bash

location='/var/www'
domain='domain.nl'
## DATABASE
db_name='wordpress_db'
db_user='wp_user'
db_passwd=$(openssl rand -base64 32)
hostname='localhost'
db_tableprefix='wp_'
## FTP
ftp_user='ftp'
ftp_passwd='Password'

## Setup Database
echo "Enter your mysql root password: " && mysql -u root -p -e "CREATE USER \"${db_user}\"@\"localhost\" IDENTIFIED BY \"${db_passwd}\"; CREATE DATABASE ${db_name}; GRANT ALL PRIVILEGES ON ${db_name}.* TO \"${db_user}\"@\"localhost\"; FLUSH PRIVILEGES; "

## Install Wordpress
wget https://nl.wordpress.org/latest-nl_NL.tar.gz
tar -xzvf latest-nl_NL.tar.gz
mv wordpress ${location}

## Create config
printf "<?php\ndefine( 'DB_NAME', '${db_name}' );\ndefine( 'DB_USER', '${db_user}' );\ndefine( 'DB_PASSWORD', '${db_passwd}' );\ndefine( 'DB_HOST', 'localhost' );\ndefine( 'DB_CHARSET', 'utf8mb4' );\ndefine( 'DB_COLLATE', '' );\n " > ${location}/wordpress/wp-config.php
curl https://api.wordpress.org/secret-key/1.1/salt/ >> ${location}/wordpress/wp-config.php
printf "\$table_prefix = '${db_tableprefix}';\ndefine( 'WP_DEBUG', false );\ndefine( 'FS_METHOD', 'direct' );\ndefine( 'FTP_BASE', '${location}/wordpress' );\ndefine( 'FTP_CONTENT_DIR', '${location}/wordpress/wp-content/' );\ndefine( 'FTP_PLUGIN_DIR ', '${location}/wordpress/wp-content/plugins/' );\ndefine( 'FTP_USER', '${ftp_user}' );\ndefine( 'FTP_PASS', '${ftp_passwd}' );\ndefine( 'FTP_HOST', 'localhost:22' );\ndefine( 'FTP_SSL', false );\nif ( ! defined( 'ABSPATH' ) ) { define( 'ABSPATH', dirname( __FILE__ ) . '/' ); }\nrequire_once( ABSPATH . 'wp-settings.php' );\n " >>  ${location}/wordpress/wp-config.php

## Create apache vhost
printf "<VirtualHost *:80>\n  ServerName ${domain} \n  ServerAlias ${domain}\n  DocumentRoot ${location}/wordpress\n  ErrorLog ${APACHE_LOG_DIR}/error.log\n  CustomLog ${APACHE_LOG_DIR}/access.log combined\n</VirtualHost>\n" > /etc/apache2/sites-available/${domain}.conf
a2ensite ${domain}.conf
systemctl restart apache2.service