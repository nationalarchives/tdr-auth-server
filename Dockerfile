FROM quay.io/keycloak/keycloak:26.6.1 as builder

# ----------------------------
# Install build dependencies
# ----------------------------
USER root

RUN microdnf upgrade -y && \
    microdnf -y install python3 java-21-openjdk-headless shadow-utils && \
    microdnf clean all

RUN useradd -U keycloak

WORKDIR /opt/keycloak

# ----------------------------
# Copy ALL Keycloak customisations BEFORE build
# ----------------------------

# Themes (IMPORTANT: full folder, not partial copies)
COPY themes /opt/keycloak/themes

# Providers (SPI jars)
COPY govuk-notify-spi/target/scala-2.13/govuk-notify-spi* /opt/keycloak/providers/
COPY credentials-provider/target/scala-2.13/credentials-provider.jar /opt/keycloak/providers/
COPY event-publisher-spi/target/scala-2.13/event-publisher-spi.jar /opt/keycloak/providers/
COPY custom-response-provider/target/scala-2.13/custom-response-provider.jar /opt/keycloak/providers/

# Runtime config (still copied, but split correctly later)
COPY keycloak.conf /opt/keycloak/conf/

# Build-time config (THIS IS THE IMPORTANT ONE)
COPY build.conf /keycloak-configuration/build.conf

# Scripts / realm / utilities
COPY environment-properties /keycloak-configuration/environment-properties
COPY import_tdr_realm.py /keycloak-configuration/
COPY update_client_configuration.py /keycloak-configuration/
COPY update_realm_configuration.py /keycloak-configuration/
COPY tdr-realm-export.json /keycloak-configuration/

# ----------------------------
# SINGLE authoritative build
# ----------------------------

RUN rm -rf /opt/keycloak/data/tmp/*

RUN /opt/keycloak/bin/kc.sh \
    -cf /keycloak-configuration/build.conf \
    build

# ----------------------------
# Final permissions
# ----------------------------

RUN chown -R keycloak:keycloak /opt/keycloak /keycloak-configuration
RUN chmod +x /keycloak-configuration/import_tdr_realm.py

USER 1000

RUN mkdir -p /opt/keycloak/data/import

# ----------------------------
# Runtime entrypoint
# ----------------------------

ENTRYPOINT ["/keycloak-configuration/import_tdr_realm.py"]
