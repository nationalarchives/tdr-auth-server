FROM jboss/keycloak:8.0.2
COPY standalone-ha.xml /opt/jboss/keycloak/standalone/configuration/
COPY govuk/ /opt/jboss/keycloak/themes/govuk/
COPY templates/sms-validation* /opt/jboss/keycloak/themes/base/login/
COPY templates/messages/messages_en.properties /tmp/
COPY target/keycloak-sms-authenticator-sns-*.jar /opt/jboss/keycloak/standalone/deployments/
RUN cat /tmp/messages_en.properties >> /opt/jboss/keycloak/themes/base/login/messages/messages_en.properties
