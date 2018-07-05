FROM alpine:latest
MAINTAINER Yukio Yamamoto <yukio@planeta.sci.isas.jaxa.jp>

ENV SLAPD_LDAP  "yes"
ENV SLAPD_LDAPI "no"
ENV SLAPD_LDAPS "no"

ENV SLAPD_CERTIFICATE_CA "/etc/ssl/certs/ca-certificates.crt"
ENV SLAPD_CERTIFICATE_KEY ""
ENV SLAPD_CERTIFICATE ""

ENV ORGANIZATION_NAME "Example Ltd"
ENV SUFFIX "dc=example,dc=com"
ENV LDAP_ADMIN_USER "admin"
ENV LDAP_ADMIN_PASS "password"
ENV DB_ADMIN_USER "db_admin"
ENV DB_ADMIN_PASS "db_password"
ENV DB_DIR "/var/lib/openldap/openldap-data"
ENV LOG_LEVEL "stats"
ENV DEBUG 0
ENV UID "ldap"
ENV GID "ldap"


RUN set -ex \
  && apk add --update --no-cache \
      openldap \
      openldap-clients \
      openldap-back-mdb \
      openldap-back-monitor \
      ca-certificates \
  && rm -rf /var/cache/apk/*

COPY docker-entrypoint.sh /

RUN set -ex \
  && chmod +x /docker-entrypoint.sh


EXPOSE 389

VOLUME ["$DB_DIR"]

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/sbin/slapd", "-d", "256", "-u", "ldap", "-g", "ldap", "-F", "/etc/openldap/slapd.d/"]
