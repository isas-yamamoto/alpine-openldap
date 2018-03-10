# alpine-openldap

## Features

- Small image (less than 10MB) by alpine linux image
- MDB backend
- slapd.d style configuration (not slapd.conf)

## Quick Start

```bash
git clone https://github.com/isas-yamamoto/alpine-openldap.git
cd alpine-openldap
docker build -t alpine-openldap .
docker run -p 389:389 -d alpine-openldap
```

Then, check to see if the LDAP server runs correctly with ldapsearch:
```bash
ldapsearch -x -LLL -h 127.0.0.1 -D cn=config -b cn=config -w password "(objectClass=*)" dn
```

## Environment Variables

| VARIABLE | DESCRIPTION | DEFAULT |
| :------- | :---------- | :------ |
| ORGANIZATION_NAME | Organization name | Example Ltd |
| SUFFIX | Organization distinguished name | dc=example,dc=com |
| LDAP_ADMIN_USER | LDAP admin username | admin |
| LDAP_ADMIN_PASS | LDAP admin password | password |
| DB_ADMIN_USER | Database admin username | db_admin |
| DB_ADMIN_PASS | Database admin password | db_password |
| DB_DIR | Database directory | /var/lib/openldap/openldap-data |
| LOG_LEVEL | LDAP logging level | stats |
| SLAPD_LDAP | Use LDAP to access slapd | yes |
| SLAPD_LDAPI | Use LDAPI to access slapd | no |
| SLAPD_LDAPS | Use LDAPS to access slapd | no |
| SLAPD_CERTIFICATE_CA | Path to certificates of CA | /etc/ssl/certs/ca-certificates.crt |
| SLAPD_CERTIFICATE_KEY | Path to private keyfile |  |
| SLAPD_CERTIFICATE | Path to certificate data  |  |

## Migration example from other ldap server

Create backup as below
```bash
sudo slapcat > backup.ldif
```

To restore, enter into the docker container:
```
sudo docker exec --it <id> /bin/sh
```
Then, restore from the backup file:
```
slapadd -n 2 -F /etc/openldap/slapd.d -l backup.ldif
```
