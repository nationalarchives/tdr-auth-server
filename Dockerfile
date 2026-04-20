FROM quay.io/keycloak/keycloak:26.6.1 as builder

FROM registry.access.redhat.com/ubi9-minimal

USER root

# Install dependencies
RUN microdnf upgrade -y && \
    microdnf -y install python3 java-21-openjdk-headless shadow-utils && \
    microdnf clean all

RUN useradd -U keycloak

# ----------------------------
COPY --from=builder /opt/keycloak /opt/keycloak

WORKDIR /opt/keycloak

# ----------------------------
# Copy customisations BEFORE build
# ----------------------------

COPY themes /opt/keycloak/themes

COPY govuk-notify-spi/target/scala-2.13/govuk-notify-spi* /opt/keycloak/providers/
COPY credentials-provider/target/scala-2.13/credentials-provider.jar /opt/keycloak/providers/
COPY event-publisher-spi/target/scala-2.13/event-publisher-spi.jar /opt/keycloak/providers/
COPY custom-response-provider/target/scala-2.13/custom-response-provider.jar /opt/keycloak/providers/

COPY keycloak.conf /opt/keycloak/conf/

COPY build.conf /keycloak-configuration/build.conf

COPY environment-properties /keycloak-configuration/environment-properties
COPY import_tdr_realm.py /keycloak-configuration/
COPY update_client_configuration.py /keycloak-configuration/
COPY update_realm_configuration.py /keycloak-configuration/
COPY tdr-realm-export.json /keycloak-configuration/

# ----------------------------
# Build Keycloak
# ----------------------------

RUN rm -rf /opt/keycloak/data/tmp/*

RUN /opt/keycloak/bin/kc.sh \
    -cf /keycloak-configuration/build.conf \
    build

# ----------------------------
# Permissions
# ----------------------------

RUN chown -R keycloak:keycloak /opt/keycloak /keycloak-configuration
RUN chmod +x /keycloak-configuration/import_tdr_realm.py

USER 1000

RUN mkdir -p /opt/keycloak/data/import

ENTRYPOINT ["/keycloak-configuration/import_tdr_realm.py"]
