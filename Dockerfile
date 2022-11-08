FROM quay.io/keycloak/keycloak:20.0.1
USER root
RUN microdnf update && microdnf install python3
WORKDIR /opt/keycloak
COPY quarkus.properties conf/
COPY environment-properties /tmp/environment-properties
COPY build.conf import_tdr_realm.py update_client_configuration.py update_realm_configuration.py tdr-realm-export.json /tmp/
COPY themes/tdr/login themes/tdr/login
COPY themes/tdr/email themes/tdr/email
COPY govuk-notify-spi/target/scala-2.13/govuk-notify-spi* providers/
COPY credentials-provider/target/scala-2.13/credentials-provider.jar providers/
COPY event-publisher-spi/target/scala-2.13/event-publisher-spi.jar providers/
COPY keycloak.conf conf/
RUN bin/kc.sh -cf /tmp/build.conf build
RUN chown -R keycloak /tmp/environment-properties
RUN chown keycloak /tmp/tdr-realm-export.json /tmp/import_tdr_realm.py
RUN chmod +x /tmp/import_tdr_realm.py
USER 1000
RUN mkdir -p data/import

ENTRYPOINT /tmp/import_tdr_realm.py
