FROM quay.io/keycloak/keycloak:26.8.2 as builder
FROM registry.access.redhat.com/ubi9-minimal
COPY --from=builder /opt/keycloak/ /opt/keycloak/
# Replace vulnerable Jackson databind and align Jackson core with version 2.21.8.
# Keep the original filenames because the Keycloak distribution references them.
# Remove these overrides when Keycloak includes a fix for CVE-2026-110879.
ADD --checksum=sha256:ad77f2285717e2f34c319d988b7c85783a47d0b33f33a501d1fcbf196e61bbaa https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/2.21.8/jackson-databind-2.21.8.jar /opt/keycloak/lib/lib/main/com.fasterxml.jackson.core.jackson-databind-2.21.7.jar
ADD --checksum=sha256:604ef7765013daf5cde192e40bc4c8412c4ca93f4aaf7bf8e9a62fad1e1026bb https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/2.21.8/jackson-core-2.21.8.jar /opt/keycloak/lib/lib/main/com.fasterxml.jackson.core.jackson-core-2.21.7.jar
# Corretto 21.0.13.1.2 includes the fix for Java4Shell.
ADD --checksum=sha256:99955525895ba52e1363fad67e4e4073c15aa0eabd53bc552a9cc17270fecedf https://yum.corretto.aws/corretto.repo /etc/yum.repos.d/corretto.repo
ADD --checksum=sha256:6db32832d82839d368181ae730df7d642b0bff161277f0ab6023359d347cca6b https://yum.corretto.aws/corretto.key /tmp/corretto.key
USER root
RUN microdnf update -y && \
    rpm --import /tmp/corretto.key && \
    microdnf -y install python3 java-21-amazon-corretto-devel-21.0.13.1.2-1 shadow-utils zip unzip && \
    rm /tmp/corretto.key && \
    java -version 2>&1 | grep -F 'Corretto-21.0.13.1.2'
# The admin CLI bundles its own Jackson classes. Replace them and their Maven
# metadata with the patched databind jar above, leaving the rest of the CLI intact.
RUN mkdir -p /tmp/jackson-cli-patch && \
    cd /tmp/jackson-cli-patch && \
    unzip -q /opt/keycloak/lib/lib/main/com.fasterxml.jackson.core.jackson-databind-2.21.7.jar \
      'com/fasterxml/jackson/databind/*' \
      'META-INF/maven/com.fasterxml.jackson.core/jackson-databind/*' && \
    zip -qd /opt/keycloak/bin/client/keycloak-admin-cli-26.8.2.jar \
      'com/fasterxml/jackson/databind/*' \
      'META-INF/maven/com.fasterxml.jackson.core/jackson-databind/*' && \
    zip -qr /opt/keycloak/bin/client/keycloak-admin-cli-26.8.2.jar \
      com/fasterxml/jackson/databind \
      META-INF/maven/com.fasterxml.jackson.core/jackson-databind && \
    cd / && rm -r /tmp/jackson-cli-patch
# Retain the Java4Shell mitigation until the patched runtime is verified.
ENV JAVA_OPTS_APPEND="-XX:-UseBASE64Intrinsics"
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
