FROM quay.io/keycloak/keycloak:26.8.2 as builder
FROM registry.access.redhat.com/ubi9-minimal
COPY --from=builder /opt/keycloak/ /opt/keycloak/
USER root
RUN microdnf update -y && \
    microdnf -y install python3 java-21-openjdk-headless shadow-utils
ENV JAVA_OPTS_APPEND="-XX:-UseBASE64Intrinsics"
COPY patch_keycloak_jackson.py /tmp/
FROM quay.io/keycloak/keycloak:26.8.2 as builder
FROM registry.access.redhat.com/ubi9-minimal
COPY --from=builder /opt/keycloak/ /opt/keycloak/
USER root
RUN microdnf update -y && \
    microdnf -y install python3 java-21-openjdk-headless shadow-utils && \
    python3 /tmp/patch_keycloak_jackson.py && \
    rm /tmp/patch_keycloak_jackson.py && \
    useradd -U keycloak
ENV JAVA_OPTS_APPEND="-XX:-UseBASE64Intrinsics"
COPY patch_keycloak_jackson.py /tmp/
WORKDIR /opt/keycloak
RUN mkdir /keycloak-configuration && \
    mkdir -p data/import && \
    bin/kc.sh -cf /keycloak-configuration/build.conf build && \
    chown -R 1000:1000 /opt/keycloak/data && \
    chown -R keycloak /keycloak-configuration && \
    chmod +x /keycloak-configuration/import_tdr_realm.py
COPY quarkus.properties conf/
COPY environment-properties /keycloak-configuration/environment-properties
COPY build.conf import_tdr_realm.py update_client_configuration.py update_realm_configuration.py tdr-realm-export.json /keycloak-configuration/
COPY themes/tdr/login themes/tdr/login
COPY themes/tdr/email themes/tdr/email
COPY govuk-notify-spi/target/scala-2.13/govuk-notify-spi* providers/
COPY credentials-provider/target/scala-2.13/credentials-provider.jar providers/
COPY event-publisher-spi/target/scala-2.13/event-publisher-spi.jar providers/
COPY custom-response-provider/target/scala-2.13/custom-response-provider.jar providers/
COPY keycloak.conf conf/
USER 1000
RUN mkdir -p data/import
ENTRYPOINT /keycloak-configuration/import_tdr_realm.py
RUN useradd -U keycloak
WORKDIR /opt/keycloak
RUN mkdir /keycloak-configuration
COPY quarkus.properties conf/
COPY environment-properties /keycloak-configuration/environment-properties
COPY build.conf import_tdr_realm.py update_client_configuration.py update_realm_configuration.py tdr-realm-export.json /keycloak-configuration/
COPY themes/tdr/login themes/tdr/login
COPY themes/tdr/email themes/tdr/email
COPY govuk-notify-spi/target/scala-2.13/govuk-notify-spi* providers/
COPY credentials-provider/target/scala-2.13/credentials-provider.jar providers/
COPY event-publisher-spi/target/scala-2.13/event-publisher-spi.jar providers/
COPY custom-response-provider/target/scala-2.13/custom-response-provider.jar providers/
COPY keycloak.conf conf/
RUN bin/kc.sh -cf /keycloak-configuration/build.conf build
RUN chown -R 1000:1000 /opt/keycloak/data
RUN chown -R keycloak /keycloak-configuration
RUN chmod +x /keycloak-configuration/import_tdr_realm.py
USER 1000
RUN mkdir -p data/import

ENTRYPOINT /keycloak-configuration/import_tdr_realm.py
