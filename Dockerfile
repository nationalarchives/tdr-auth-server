FROM jboss/keycloak:9.0.0
COPY realm-export.json /tmp
COPY standalone-ha.xml /opt/jboss/keycloak/standalone/configuration/
COPY govuk/ /opt/jboss/keycloak/themes/govuk/
