# nginx, MariaDB, and PHP in Debian/Ubuntu

## Installation

```
wget https://raw.githubusercontent.com/mikekatip/lemp-server-install/master/lemp-server-install.sh
chmod +x lemp-server-install.sh
./lemp-server-install.sh
```
Tested in the following distros:
- Debian 8 (Jessie)
- Debian 9 (Stretch)
- Ubuntu 16.04 LTS (Xenial Xerus)
- Ubuntu 17.10 (Artful Aardvark)
- Elementary OS 0.4 (Loki).

### Errors

Install `ca-certificates` (which allows `wget` to use https) to resolve the following errors:

- The certificate of ‘raw.githubusercontent.com’ is not trusted.
- The certificate of ‘raw.githubusercontent.com’ hasn't got a known issuer.

```
su -c "apt-get install ca-certificates"
```
## Domain Management Script

### Installation

`lemp-server-install.sh` will automatically install `domain.sh` to `/usr/bin/domain`. 

Manual installation is not necessary, but possible with the following commands.

```
sudo wget -O /usr/bin/domain https://raw.githubusercontent.com/mikekatip/lemp-server-install/master/usr/local/bin/domain.sh
sudo chmod +x /usr/bin/domain
```

### Usage

#### Adding a Domain

```
sudo domain add domain.tld
```

##### Example

```
sudo domain add example.com
```

#### Removing a Domain

```
sudo domain remove domain.tld
```

##### Example

```
sudo domain remove example.com
```
