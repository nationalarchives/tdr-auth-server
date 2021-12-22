FROM jboss/keycloak:16.1.0
USER root
RUN microdnf update && microdnf install python3

COPY environment-properties /tmp/environment-properties
COPY import_tdr_realm.py update_client_configuration.py update_realm_configuration.py tdr-realm-export.json /tmp/
COPY standalone-ha.xml /opt/jboss/keycloak/standalone/configuration/
COPY themes/tdr/login /opt/jboss/keycloak/themes/tdr/login
COPY themes/tdr/email /opt/jboss/keycloak/themes/tdr/email
COPY target/scala-2.13/govuk-notify-spi.jar /opt/jboss/keycloak/standalone/deployments/
COPY target/scala-2.13/event-publisher-spi.jar /opt/jboss/keycloak/standalone/deployments/
RUN chown -R jboss /tmp/environment-properties
RUN chown jboss /tmp/tdr-realm-export.json /tmp/import_tdr_realm.py
RUN chmod +x /tmp/import_tdr_realm.py
USER 1000

ENTRYPOINT /tmp/import_tdr_realm.py
