#!/bin/sh -e

# ----------------------------------------
# environment variables
# ----------------------------------------
LDAP_MODULE_PATH=/usr/lib/openldap
SLAPD_CONFIG_DIR=/etc/openldap/slapd.d
SLAPD_SCHEMA_DIR=/etc/openldap/schema
SLAPD_CERTS_DIR=/etc/openldap/certs

# ----------------------------------------
# slapd options
# ----------------------------------------
harg=""
if test x$SLAPD_LDAP = xyes ; then
    harg="$harg ldap:///"
fi
if test x$SLAPD_LDAPS = xyes ; then
    harg="$harg ldaps:///"
fi
if test x$SLAPD_LDAPI = xyes ; then
    harg="$harg ldapi:///"
fi
if test "x$harg" != x ; then
    harg="-h $harg"
fi

# ----------------------------------------
# directory
# ----------------------------------------
if test ! -d /run/openldap ; then
    mkdir /run/openldap
fi
chown ldap:ldap /run/openldap

if test ! -d $SLAPD_CONFIG_DIR ; then
    mkdir $SLAPD_CONFIG_DIR
fi

if test ! -f $SLAPD_CONFIG_DIR/cn\=config.ldif ; then

    # ----------------------------------------
    # initial entries
    # ----------------------------------------
    LDIF=/tmp/init.ldif
    cat << EOT > $LDIF
dn: cn=config
objectClass: olcGlobal
cn: config
EOT
    
    # ----------------------------------------
    # ldaps support
    # ----------------------------------------
    if test x$SLAPD_LDAPS = xyes ; then
	cat << EOT >> $LDIF
olcTLSCACertificateFile: $SLAPD_CERTIFICATE_CA
olcTLSCertificateFile: $SLAPD_CERTIFICATE
olcTLSCertificateKeyFIle: $SLAPD_CERTIFICATE_KEY
EOT
    fi
    
    # ----------------------------------------
    # create config entries
    # ----------------------------------------
    cat << EOT >> $LDIF

dn: olcDatabase={0}config,cn=config
objectClass: olcDatabaseConfig
olcDatabase: {0}config
olcRootDN: cn=config
olcRootPW: `slappasswd -s $LDAP_ADMIN_PASS`

dn: cn=module,cn=config
objectClass: olcModuleList
cn: module
olcModulePath: $LDAP_MODULE_PATH
olcModuleLoad: back_mdb

dn: cn=module,cn=config
objectClass: olcModuleList
cn: module
olcModulePath: $LDAP_MODULE_PATH
olcModuleLoad: back_monitor

dn: olcDatabase={1}monitor,cn=config
objectClass: olcDatabaseConfig
olcDatabase: {1}monitor

dn: olcDatabase={2}mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: {2}mdb
olcSuffix: $SUFFIX
olcRootDN: cn=$DB_ADMIN_USER,$SUFFIX
olcRootPW: `slappasswd -s $DB_ADMIN_PASS`
olcDbDirectory: $DB_DIR
EOT

    if test $DEBUG -eq 1 ; then
	cat $LDIF
    fi

    # ----------------------------------------
    # register initial ldif file
    # ----------------------------------------
    /usr/sbin/slapadd -n0 -F $SLAPD_CONFIG_DIR -l $LDIF
    rm -f $LDIF
    
    # ----------------------------------------
    # set default schema
    # ----------------------------------------
    schemas="corba core cosine duaconf dyngroup inetorgperson java misc nis openldap ppolicy collective"
    for schema in $schemas ; do
	slapadd -n0 -F $SLAPD_CONFIG_DIR -l $SLAPD_SCHEMA_DIR/$schema.ldif
    done
fi

# ----------------------------------------
# change owner before starting
# ----------------------------------------
chown -R ldap:ldap $SLAPD_CONFIG_DIR

# ----------------------------------------
# run command passed to docker run
# ----------------------------------------
exec "$@" "$harg"
