# Install nginx, MariaDB, and PHP in Debian/Ubuntu

Tested in Debian 8 (Jessie), Debian 9 (Stretch), Ubuntu 16.04 LTS (Xenial Xerus), Ubuntu 17.10 (Artful Aardvark), and Elementary OS 0.4 (Loki).

```
wget https://raw.githubusercontent.com/mikekatip/lemp-server-install/master/lemp-server-install.sh
chmod +x lemp-server-install.sh
./lemp-server-install.sh
```
## ERROR: The certificate of ‘raw.githubusercontent.com’ is not trusted

Install *ca-certificates* to resolve the following errors:

- The certificate of ‘raw.githubusercontent.com’ is not trusted.
- The certificate of ‘raw.githubusercontent.com’ hasn't got a known issuer.

```
su -c "apt-get install ca-certificates"
```
