# Install nginx, MariaDB, and PHP in Debian/Ubuntu

Tested in Debian 8 (Jessie), Debian 9 (Stretch), Ubuntu 16.04 LTS (Xenial Xerus), Ubuntu 17.10 (Artful Aardvark), and Elementary OS 0.4 (Loki).

```
su -c "apt-get install ca-certificates"
wget https://raw.githubusercontent.com/mikekatip/lemp-server-install/master/lemp-server-install.sh
chmod +x lemp-server-install.sh
su -c "./lemp-server-install.sh"
```
