#!/bin/bash

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

${SUDO} apt update && ${SUDO} apt upgrade -y && ${SUDO} apt dist-upgrade -y
${SUDO} apt install --reinstall apt-transport-https apt-utils aptitude autoconf bison build-essential ca-certificates certbot curl dialog dirmngr git git-core kmod libbz2-dev libcurl4-openssl-dev libfreetype6-dev libicu-dev libjpeg-dev libmcrypt-dev libpng-dev libpspell-dev libreadline-dev libssl-dev libxml2-dev locales lsb-release nano pkg-config software-properties-common -y

# set locale
${SUDO} locale-gen en_US.UTF-8
${SUDO} dpkg-reconfigure locales
${SUDO} bash -c "echo 'LANG=en_US.UTF-8' > /etc/default/locale"
${SUDO} bash -c "echo 'LANG=en_US.UTF-8' > /etc/environment"

# NGINX
wget http://nginx.org/packages/keys/nginx_signing.key
cat nginx_signing.key | ${SUDO} apt-key add -
rm nginx_signing.key
${SUDO} bash -c "echo 'deb http://nginx.org/packages/mainline/debian/ stretch nginx' > /etc/apt/sources.list.d/nginx.list"
${SUDO} bash -c "echo 'deb-src http://nginx.org/packages/mainline/debian/ stretch nginx' >> /etc/apt/sources.list.d/nginx.list"
${SUDO} apt update
${SUDO} apt install nginx -y
${SUDO} systemctl start nginx
${SUDO} systemctl enable  nginx
# ${SUDO} systemctl status nginx

# MariaDB 
${SUDO} apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
${SUDO} add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.2/debian stretch main'
${SUDO} apt update
${SUDO} apt install mariadb-server -y
${SUDO} systemctl start mariadb
${SUDO} systemctl enable mariadb
# ${SUDO} systemctl status mariadb
${SUDO} mysql_secure_installation

#PHP
${SUDO} wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
${SUDO} bash -c 'echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/php.list'
${SUDO} apt update
${SUDO} apt install php7.2-cgi php7.2-gd php7.2-curl php7.2-imap php7.2-sqlite3 php7.2-mysql php7.2-tidy php7.2-pspell php7.2-recode php7.2-xml php7.2-intl php7.2-enchant php7.2-gmp php7.2-mbstring php7.2-soap php7.2-xmlrpc php7.2-zip php7.2-fpm -y

${SUDO} sed -i "s/memory_limit = .*/memory_limit = 256M/" /etc/php/7.2/fpm/php.ini
${SUDO} sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/" /etc/php/7.2/fpm/php.ini
${SUDO} sed -i "s/zlib.output_compression = .*/zlib.output_compression = on/" /etc/php/7.2/fpm/php.ini
${SUDO} sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.2/fpm/php.ini

${SUDO} mv /etc/php/7.2/fpm/pool.d/www.conf /etc/php/7.2/fpm/pool.d/www.conf.org
${SUDO} bash -c "cat << 'EOF' > /etc/php/7.2/fpm/pool.d/www.conf
[www]
user = www-data
group = www-data
listen = /run/php/php7.2-fpm.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0666
pm = ondemand
pm.max_children = 5
pm.process_idle_timeout = 10s
pm.max_requests = 200
chdir = /
EOF"

${SUDO} systemctl restart php7.2-fpm 

${SUDO} mkdir /etc/nginx/conf.backup
${SUDO} mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.backup/default.conf
${SUDO} bash -c "cat << 'EOF' > /etc/nginx/conf.d/default.conf
server {
    listen       80;
    server_name  localhost;

    location / {
        root   /var/www/default;
        index  index.php index.html index.htm;
    }

  location ~ \.php$ {
    fastcgi_index index.php;
    fastcgi_keep_conn on;
    include /etc/nginx/fastcgi_params;
    fastcgi_pass unix:/run/php/php7.2-fpm.sock;
    fastcgi_param SCRIPT_FILENAME /var/www/default\$fastcgi_script_name;
  }
}
EOF"

${SUDO} sed -e '/sites-enabled/ s/^#*/#/' -i /etc/nginx/nginx.conf

${SUDO} mkdir -p /var/www/default
${SUDO} chgrp -R www-data /var/www
${SUDO} usermod -a -G www-data $USER
${SUDO} chmod -R 775 /var/www

${SUDO} bash -c "cat << 'EOF' > /var/www/default/info.php
<?php phpinfo(); ?>
EOF"


${SUDO} bash -c "cat << 'EOF' > /var/www/default/index.php
<!DOCTYPE html>
<html>
<head>
<title><?php echo \$_SERVER['HTTP_HOST']; ?></title>
<link href='//fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css'>
<style>
    body {
        font-family: 'Open Sans', sans-serif;
        background: #000;
        color: #fff;
    }
    html,body {
        height: 100%;
    }
    body {
        display: table; 
        margin: 0 auto;
    }
    .container {  
        height: 100%;
        display: table-cell;   
        vertical-align: middle;    
    }
    .cent {
         height: 50px;
        width: 100%;
        background-color: none;      
     }
</style>
</head>
<body>
<div class="container">
    <div class="cent"><h1><?php echo \$_SERVER['HTTP_HOST']; ?></h1></div>
</div>
</body>
</html>
EOF"

${SUDO} systemctl restart nginx

# openssl

${SUDO} openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
${SUDO} rm -R /etc/nginx/snippets
${SUDO} mkdir /etc/nginx/snippets/

${SUDO} bash -c "cat << 'EOF' > /etc/nginx/snippets/ssl-params.conf
# from https://cipherli.st/
# and https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers \"EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH\";
ssl_ecdh_curve secp384r1;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
# Disable preloading HSTS for now.  You can use the commented out header line that includes
# the \"preload\" directive if you understand the implications.
#add_header Strict-Transport-Security \"max-age=63072000; includeSubdomains; preload\";
add_header Strict-Transport-Security \"max-age=63072000; includeSubdomains\";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
ssl_dhparam /etc/ssl/certs/dhparam.pem;
EOF"

# domain add/remove script

${SUDO} wget -O /usr/bin/domain https://raw.githubusercontent.com/mikekatip/lemp-server-install/master/domain.sh
${SUDO} chmod +x /usr/bin/domain
