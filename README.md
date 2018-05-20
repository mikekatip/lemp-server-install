# nginx, MariaDB, and PHP in Debian/Ubuntu

Tested in the following distros:
- Debian 8 (Jessie)
- Debian 9 (Stretch)
- Ubuntu 16.04 LTS (Xenial Xerus)
- Ubuntu 17.10 (Artful Aardvark)
- Elementary OS 0.4 (Loki).

## Installation

```
wget https://raw.githubusercontent.com/mikekatip/lemp-server-install/master/lemp-server-install.sh -O - | bash
```
### Errors

Install `ca-certificates` (which allows `wget` to use https) to resolve the following errors:

- `The certificate of ‘raw.githubusercontent.com’ is not trusted.`
- `The certificate of ‘raw.githubusercontent.com’ hasn't got a known issuer.`

```
su -c "apt-get install ca-certificates"
```
## Domain Management Script

### Installation

`lemp-server-install.sh` will automatically install `domain.sh` to `/usr/bin/domain`. 

Manual installation is not necessary, but is possible with the following commands:

```
sudo wget -O /usr/bin/domain https://raw.githubusercontent.com/mikekatip/lemp-server-install/master/usr/local/bin/domain.sh
sudo chmod +x /usr/bin/domain
```

### Usage

#### Add a Domain

##### Public Web Server

```
sudo domain add domain.tld
```

- Web Root Directory: `/var/www/domain.tld`
- nginx .conf file: `/etc/nginx/conf.d/domain.tld.conf`
- Configured for SSL using LetsEncrypt
- `http://domain.tld` will be redirected to `https://domain.tld`
- `http://www.domain.tld` will be redirected to `https://domain.tld`
- `https://www.domain.tld` will be redirected to `https://domain.tld`

##### Local Web Server

```
sudo domain add domain.local
```

If you installed LEMP on your local development machine instead of a public web sever, replace `.tld` (.com, .net, .org, etc) with `.local`. 

- Web Root Directory: `/var/www/domain.local`
- nginx .conf file: `/etc/nginx/conf.d/domain.local.conf`
- `/etc/hosts` will be updated to point `domain.local` to `127.0.0.1`
- Not configured for SSL using LetsEncrypt

#### Remove a Domain

Make sure to make a backup before removing a domain.

```
sudo domain remove domain.tld
```
```
sudo domain remove domain.local
```

- Removes Web Root Directory (will not be backed up before deletion)
- Removes nginx .conf file (will not be backed up before deletion)
- Restarts nginx
