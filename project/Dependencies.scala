import sbt._

object Dependencies {
  private val keycloakVersion = "26.3.2"
  private val circeVersion = "0.14.14"
  private val awsSdkVersion = "2.32.25"
  
  lazy val awsSecretsManager = "com.amazonaws.secretsmanager" % "aws-secretsmanager-caching-java" % "2.0.0"
  lazy val awsUtils: ModuleID = "uk.gov.nationalarchives" %% "tdr-aws-utils" % "0.1.27"
  lazy val circeCore = "io.circe" %% "circe-core" % circeVersion
  lazy val circeGeneric = "io.circe" %% "circe-generic" % circeVersion
  lazy val circeParser = "io.circe" %% "circe-parser" % circeVersion
  lazy val javaxEnterprise = "javax.enterprise" % "cdi-api" % "2.0"
  lazy val javaxInject = "javax.inject" % "javax.inject" % "1"
  lazy val keycloakCore: ModuleID = "org.keycloak" % "keycloak-core" % keycloakVersion % "provided"
  lazy val keycloakModelJpa: ModuleID = "org.keycloak" % "keycloak-model-jpa" % keycloakVersion % "provided"
  lazy val keycloakServerSpi: ModuleID = "org.keycloak" % "keycloak-server-spi" % keycloakVersion % "provided"
  lazy val mockito: ModuleID = "org.mockito" %% "mockito-scala" % "2.0.0"
  lazy val notifyJavaClient: ModuleID = "uk.gov.service.notify" % "notifications-java-client" % "5.2.1-RELEASE" 
  lazy val quarkusCredentials = "io.quarkus" % "quarkus-credentials" % "3.25.3"
  lazy val rds = "software.amazon.awssdk" % "rds" % "2.26.27"
  lazy val scalaCache = "com.github.cb372" %% "scalacache-caffeine" % "0.28.0"
  lazy val scalaTest: ModuleID = "org.scalatest" %% "scalatest" % "3.2.19"
  lazy val snsSdk = "software.amazon.awssdk" % "sns" % awsSdkVersion
  lazy val awsSsm = "software.amazon.awssdk" % "ssm" % awsSdkVersion
  lazy val typeSafeConfig = "com.typesafe" % "config" % "1.4.4"
  lazy val caffiene = "com.github.ben-manes.caffeine" % "caffeine" % "3.2.2"
}
