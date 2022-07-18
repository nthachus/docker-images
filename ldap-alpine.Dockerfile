ARG  TAG=latest
FROM alpine:${TAG}

RUN apk update -q \
 && apk add --no-cache openldap openldap-backend-all openldap-clients openldap-overlay-all \
 && rm -rf /var/cache/apk/* /tmp/* /var/lib/openldap/openldap-data/*.example \
 && mkdir -p /run/openldap /etc/openldap/slapd.d /etc/ldap \
 && chown ldap:ldap /run/openldap /etc/openldap/slapd.d /etc/ldap \
 && ln -sf /run/openldap /var/lib/openldap/run \
 && sed -i -e 's/ cn=Manager,/ cn=admin,/g' -e 's/\.la$/.so/' \
  -e "s,^[[:space:]]*include: .*/core.ldif,&\ninclude: file:///etc/openldap/schema/cosine.ldif\ninclude: file:///etc/openldap/schema/nis.ldif\ninclude: file:///etc/openldap/schema/inetorgperson.ldif," \
  -e "s/^[[:space:]]*olcDbIndex: objectClass eq/&\nolcDbIndex: cn,uid eq/" /etc/openldap/slapd.ldif

ADD https://raw.githubusercontent.com/samba-team/samba/v4-2-stable/examples/LDAP/samba.ldif /etc/openldap/schema/
COPY ./ldap-alpine_entrypoint.sh /entrypoint.sh

EXPOSE 389 636
VOLUME ["/etc/ldap", "/var/lib/openldap/openldap-data"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["slapd", "-u", "ldap", "-g", "ldap", "-F", "/etc/openldap/slapd.d", "-h", "ldap:/// ldaps:///", "-d"]
