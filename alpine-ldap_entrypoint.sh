#!/bin/sh
set -e
: ${LOG_LEVEL:=256}

if [[ -z "$(ls -A /etc/openldap/slapd.d)" ]]; then
  # generate configuration
  slapadd -d $LOG_LEVEL -n 0 -F /etc/openldap/slapd.d -l $([[ -f /etc/ldap/slapd.ldif ]] && echo /etc/ldap/slapd.ldif || echo /etc/openldap/slapd.ldif)
fi

if [[ -z "$(ls -A /var/lib/openldap/openldap-data)" ]]; then
  [[ -f /etc/ldap/DB_CONFIG ]] && cp /etc/ldap/DB_CONFIG /var/lib/openldap/openldap-data/

  # import data
  [[ -f /etc/ldap/init.ldif ]] && slapadd -d $LOG_LEVEL -F /etc/openldap/slapd.d -l /etc/ldap/init.ldif
fi

# fix permissions
chown ldap:ldap -R /etc/openldap/slapd.d /var/lib/openldap/openldap-data

# correct arguments
[[ "${*: -2}" = "-d" ]] && set -- "$@" $LOG_LEVEL
exec "$@"
