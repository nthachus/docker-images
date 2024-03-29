#!/bin/sh
set -e
: ${LOG_LEVEL:=256}

if [ -z "$(ls -A /etc/openldap/slapd.d/)" ]; then
  config_file=/etc/ldap/slapd.ldif

  if [ ! -e $config_file ]; then
    config_file=/etc/openldap/slapd.ldif

    [ -z "$SUFFIX" ] || sed -i "s/\([ ,]\)dc=my-domain,dc=com/\\1$SUFFIX/g" $config_file
    [ -z "$ROOT_USER" ] || sed -i "s/ cn=admin,/ cn=$ROOT_USER,/g" $config_file
    [ -z "$ROOT_PW" ] || sed -i "s/^\([[:space:]]*olcRootPW:\) .*/\\1 $ROOT_PW/g" $config_file
    [ -z "$ACCESS_CONTROL" ] || sed -i "s/^#\?[[:space:]]*olcAccess: to \*/olcAccess: $ACCESS_CONTROL\n&/" $config_file
  fi

  # generate configuration
  slapadd -d $LOG_LEVEL -n 0 -F /etc/openldap/slapd.d -l $config_file
fi

if [ -z "$(ls -A /var/lib/openldap/openldap-data/)" ]; then
  [ ! -e /etc/ldap/DB_CONFIG ] || cp -f /etc/ldap/DB_CONFIG /var/lib/openldap/openldap-data/

  # import data
  [ ! -e /etc/ldap/init.ldif ] || slapadd -d $LOG_LEVEL -F /etc/openldap/slapd.d -l /etc/ldap/init.ldif
fi

# fix permissions
chown -R ldap:ldap /etc/openldap/slapd.d /var/lib/openldap/openldap-data

# correct arguments
[ "${*: -2}" != '-d' ] || set -- "$@" $LOG_LEVEL
exec "$@"
