import sbt._

object Dependencies {
  private val keycloakVersion = "25.0.0"
  private val circeVersion = "0.14.7"

  lazy val awsSecretsManager = "com.amazonaws.secretsmanager" % "aws-secretsmanager-caching-java" % "2.0.0"
  lazy val awsUtils: ModuleID = "uk.gov.nationalarchives" %% "tdr-aws-utils" % "0.1.27"
  lazy val circeCore = "io.circe" %% "circe-core" % circeVersion
  lazy val circeGeneric = "io.circe" %% "circe-generic" % circeVersion
  lazy val circeParser = "io.circe" %% "circe-parser" % circeVersion
  lazy val javaxEnterprise = "javax.enterprise" % "cdi-api" % "2.0.SP1"
  lazy val javaxInject = "javax.inject" % "javax.inject" % "1"
  lazy val keycloakCore: ModuleID = "org.keycloak" % "keycloak-core" % keycloakVersion % "provided"
  lazy val keycloakModelJpa: ModuleID = "org.keycloak" % "keycloak-model-jpa" % keycloakVersion % "provided"
  lazy val keycloakServerSpi: ModuleID = "org.keycloak" % "keycloak-server-spi" % keycloakVersion % "provided"
  lazy val mockito: ModuleID = "org.mockito" %% "mockito-scala" % "1.17.31"
  lazy val notifyJavaClient: ModuleID = "uk.gov.service.notify" % "notifications-java-client" % "5.1.0-RELEASE"
  lazy val rds = "software.amazon.awssdk" % "rds" % "2.25.68"
  lazy val quarkusCredentials = "io.quarkus" % "quarkus-credentials" % "3.11.1"
  lazy val scalaCache = "com.github.cb372" %% "scalacache-caffeine" % "0.28.0"
  lazy val scalaTest: ModuleID = "org.scalatest" %% "scalatest" % "3.2.18"
  lazy val snsSdk = "software.amazon.awssdk" % "sns" % "2.25.68"
  lazy val awsSsm = "software.amazon.awssdk" % "ssm" % "2.25.68"
  lazy val typeSafeConfig = "com.typesafe" % "config" % "1.4.3"
  lazy val caffiene = "com.github.ben-manes.caffeine" % "caffeine" % "3.1.8"
}
