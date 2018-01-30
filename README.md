# Install nginx, MariaDB, and PHP in Debian Stretch

In addition to installing nginx, MariaDB, and PHP, "lemp-server-install-debian.sh" will also download domain.sh and save it as "/usr/bin/domain".

```
wget https://raw.githubusercontent.com/mikekatip/lemp/master/lemp-server-install-debian.sh -O - | sh
```

#  Adding a new domain

When adding a domain to be used for local development, replace .tld with .local. 

```
domain add domain.tld
```

# Removing a domain

```
domain remove domain.tld
```
