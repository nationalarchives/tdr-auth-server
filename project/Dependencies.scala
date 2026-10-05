import sbt._

object Dependencies {
  private val keycloakVersion = "26.7.3"
  private val circeVersion = "0.14.16"
  private val awsSdkVersion = "2.54.12"
  private val nettyVersion = "4.1.137.Final"
  
  lazy val awsSecretsManager = "com.amazonaws.secretsmanager" % "aws-secretsmanager-caching-java" % "2.2.0"
  lazy val awsUtils: ModuleID = "uk.gov.nationalarchives" %% "tdr-aws-utils" % "0.1.55"
  lazy val circeCore = "io.circe" %% "circe-core" % circeVersion
  lazy val circeGeneric = "io.circe" %% "circe-generic" % circeVersion
  lazy val circeParser = "io.circe" %% "circe-parser" % circeVersion
  lazy val javaxEnterprise = "javax.enterprise" % "cdi-api" % "2.0"
  lazy val javaxInject = "javax.inject" % "javax.inject" % "1"
  lazy val keycloakCore: ModuleID = "org.keycloak" % "keycloak-core" % keycloakVersion % "provided"
  lazy val keycloakModelJpa: ModuleID = "org.keycloak" % "keycloak-model-jpa" % keycloakVersion % "provided"
  lazy val keycloakServerSpi: ModuleID = "org.keycloak" % "keycloak-server-spi" % keycloakVersion % "provided"
  lazy val mockito: ModuleID = "org.mockito" %% "mockito-scala" % "2.2.3"
  lazy val notifyJavaClient: ModuleID = "uk.gov.service.notify" % "notifications-java-client" % "6.2.0-RELEASE" 
  lazy val quarkusCredentials = "io.quarkus" % "quarkus-credentials" % "3.38.3"
  lazy val rds = "software.amazon.awssdk" % "rds" % "2.54.12"
  lazy val scalaCache = "com.github.cb372" %% "scalacache-caffeine" % "0.28.0"
  lazy val scalaTest: ModuleID = "org.scalatest" %% "scalatest" % "3.2.20"
  lazy val snsSdk = "software.amazon.awssdk" % "sns" % awsSdkVersion
  lazy val awsSsm = "software.amazon.awssdk" % "ssm" % awsSdkVersion
  lazy val typeSafeConfig = "com.typesafe" % "config" % "1.4.9"
  lazy val caffiene = "com.github.ben-manes.caffeine" % "caffeine" % "3.2.4"
  lazy val nettyModules: Seq[ModuleID] = Seq(
    "io.netty" % "netty-buffer" % nettyVersion,
    "io.netty" % "netty-codec" % nettyVersion,
    "io.netty" % "netty-codec-dns" % nettyVersion,
    "io.netty" % "netty-codec-haproxy" % nettyVersion,
    "io.netty" % "netty-codec-http" % nettyVersion,
    "io.netty" % "netty-codec-http2" % nettyVersion,
    "io.netty" % "netty-codec-socks" % nettyVersion,
    "io.netty" % "netty-common" % nettyVersion,
    "io.netty" % "netty-handler" % nettyVersion,
    "io.netty" % "netty-handler-proxy" % nettyVersion,
    "io.netty" % "netty-resolver" % nettyVersion,
    "io.netty" % "netty-resolver-dns" % nettyVersion,
    "io.netty" % "netty-transport" % nettyVersion,
    "io.netty" % "netty-transport-classes-epoll" % nettyVersion,
    "io.netty" % "netty-transport-native-unix-common" % nettyVersion
  )
}
