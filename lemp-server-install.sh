#!/bin/bash -x

export DEBIAN_FRONTEND=noninteractive

echo
echo "*** CHECKING FOR ROOT/SUDO ***"
echo

USER_NAME=$(whoami)

if (( $EUID != 0 )); then        
    # if user is NOT "root"
    
    if ! [ -x "$(command -v sudo)" ]; then
        echo
        echo "** INSTALLING 'sudo' **" 
        echo 
        su -c "apt-get install sudo"
        echo        
        echo " * DONE *"
        echo
    fi
    
    if getent group sudo | grep &>/dev/null "\b${USER_NAME}\b"; then
        echo " * ${USER_NAME} IS IN THE sudo GROUP *"
    else
        echo    
        echo "** ADDING ${USER_NAME} TO sudo GROUP **" 
        echo 
        # adding user to the "sudo" group is probably better, but editing "/etc/sudoers" does NOT require logout/login before use
        su -c "echo '${USER_NAME}  ALL=(ALL:ALL) ALL' >> /etc/sudoers"
        echo    
        echo " * DONE *"
        echo
    fi
else
    # if user IS "root"
    
    if ! [ -x "$(command -v sudo)" ]; then
        echo        
        echo "** INSTALLING 'sudo' **" 
        echo        
        apt-get install sudo
        echo
        echo " * DONE *"
        echo
    fi
fi

echo
echo "*** SETTING LOCALE ***"
echo

LANG=en_US.UTF-8
LANGUAGE=en_US:en
sudo locale-gen --purge ${LANG}
sudo bash -c "echo 'LANG=${LANG}' > /etc/default/locale"
sudo bash -c "echo 'LANGUAGE=${LANGUAGE}' >> /etc/default/locale"
sudo bash -c "echo 'LANG=${LANG}' > /etc/environment"
echo
echo " * DONE *"
echo

echo
echo "*** UPDATING SOFTWARE ***"
echo

if ! [ -x "$(command -v apt)" ]; then
    # use "apt-get" if "apt" is not installed
    sudo apt-get update 
    sudo apt-get upgrade --yes 
    INSTALL="sudo apt-get install --yes"
else
    # use "apt" instead of "apt-get"
    sudo apt update 
    sudo apt upgrade --yes 
    INSTALL="sudo apt install --yes"
fi

INSTALL_APT="apt apt-transport-https apt-utils software-properties-common"
INSTALL_OTHER="curl dialog lsb-release nano ca-certificates dirmngr"

${INSTALL} ${INSTALL_APT} ${INSTALL_OTHER}

INSTALL="sudo apt install --yes"

sudo apt-get autoremove

echo
echo " * DONE *"
echo

echo
echo "*** GETTING OPERATING SYSTEM INFORMATION ***"
echo

DISTRO=$(lsb_release -si)
DISTRO=${DISTRO,,}

RELEASE=$(lsb_release -sr)

CODENAME=$(lsb_release -cs)
CODENAME=${CODENAME,,}
echo
echo DISTRO: ${DISTRO}
echo RELEASE: ${RELEASE}
echo CODENAME: ${CODENAME}
echo

# check for debian sid

if [ "${CODENAME}" == "sid" ]; then
    CODENAME="stretch"
    
    echo    
    echo "** DEBIAN sid DETECTED **"
    echo
    echo ALTERNATE CODENAME: ${CODENAME}
    echo
fi

# check for ubuntu based system

DISTROU=$(lsb_release -siu)

if [ "${DISTROU}" == "Ubuntu" ]; then
    DISTRO=$(lsb_release -siu)
    DISTRO=${DISTRO,,}

    RELEASE=$(lsb_release -sru)

    CODENAME=$(lsb_release -csu)
    CODENAME=${CODENAME,,}
    
    echo    
    echo "** UBUNTU DETECTED **"
    echo
    echo UBUNTU DISTRO: ${DISTRO}
    echo UBUNTU RELEASE: ${RELEASE}
    echo UBUNTU CODENAME: ${CODENAME}
    echo
fi

echo
echo " * DONE *"
echo

echo
echo "*** INSTALLING NGINX, MARIADB, PHP ***"
echo

# nginx
wget http://nginx.org/packages/keys/nginx_signing.key
sudo apt-key add nginx_signing.key
rm nginx_signing.key
sudo bash -c "echo 'deb http://nginx.org/packages/mainline/${DISTRO}/ ${CODENAME} nginx' > /etc/apt/sources.list.d/nginx.list"
sudo bash -c "echo 'deb-src http://nginx.org/packages/mainline/${DISTRO}/ ${CODENAME} nginx' >> /etc/apt/sources.list.d/nginx.list"
INSTALL_NGINX="nginx"

# MariaDB
# debian jessie
sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
# everything else 
sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8

sudo bash -c "echo 'deb http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.2/${DISTRO} ${CODENAME} main' > /etc/apt/sources.list.d/mariadb.list"
sudo bash -c "echo 'deb-src http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.2/${DISTRO} ${CODENAME} main' >> /etc/apt/sources.list.d/mariadb.list"
INSTALL_MARIADB="mariadb-server"

# php

if [ "${DISTRO}" == "debian" ]; then
    sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    sudo bash -c "echo 'deb https://packages.sury.org/php/ ${CODENAME} main' > /etc/apt/sources.list.d/php.list"
fi

if [ "${DISTRO}" == "ubuntu" ]; then
    sudo add-apt-repository ppa:ondrej/php
fi

INSTALL_PHP="php7.2-cgi php7.2-gd php7.2-curl php7.2-imap php7.2-sqlite3 php7.2-mysql php7.2-tidy php7.2-pspell php7.2-recode php7.2-xml php7.2-intl php7.2-enchant php7.2-gmp php7.2-mbstring php7.2-soap php7.2-xmlrpc php7.2-zip php7.2-fpm"

# apt install lemp-server
sudo apt update 
${INSTALL} ${INSTALL_NGINX} ${INSTALL_MARIADB} ${INSTALL_PHP}

#### LEMP SERVER CONFIG ####

# nginx
sudo mkdir /etc/nginx/conf.backup
sudo mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.backup/default.conf
sudo bash -c "cat << 'EOF' > /etc/nginx/conf.d/default.conf
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

sudo sed -e '/sites-enabled/ s/^#*/#/' -i /etc/nginx/nginx.conf

sudo mkdir -p /var/www/default
sudo chgrp -R www-data /var/www
sudo usermod -a -G www-data $USER
sudo chmod -R 775 /var/www

sudo bash -c "cat << 'EOF' > /var/www/default/info.php
<?php phpinfo(); ?>
EOF"


sudo bash -c "cat << 'EOF' > /var/www/default/index.php
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

# MariaDB
sudo mysql_secure_installation

#php
sudo sed -i "s/memory_limit = .*/memory_limit = 256M/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/zlib.output_compression = .*/zlib.output_compression = on/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.2/fpm/php.ini

sudo mv /etc/php/7.2/fpm/pool.d/www.conf /etc/php/7.2/fpm/pool.d/www.conf.org
sudo bash -c "cat << 'EOF' > /etc/php/7.2/fpm/pool.d/www.conf
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

# domain add/remove script

# sudo wget -O /usr/bin/domain https://raw.githubusercontent.com/mikekatip/lemp-server-install/master/domain.sh
# sudo chmod +x /usr/bin/domain

#### START AND ENABLE SERVICES ####

# MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb

# php
sudo systemctl restart php7.2-fpm 

# nginx
sudo systemctl start nginx
sudo systemctl enable  nginx

#### DISPLAY IP ADDRESS ON LOGIN SCREEN ####

sudo wget -O /etc/rc.local https://raw.githubusercontent.com/mikekatip/lemp-server-install/master/etc/rc.local

sudo chmod +x /etc/rc.local

sudo reboot