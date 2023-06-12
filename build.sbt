import Dependencies._

lazy val commonSettings = Seq(
  scalaVersion := "2.13.11",
  Test / fork := true,
  assembly / assemblyJarName := s"${(This / name).value}.jar",
  assemblyPackageScala / assembleArtifact := false,
  assemblyPackageDependency / assembleArtifact := false,
  assemblyPackageDependency / test := {},
  libraryDependencies ++= Seq(
    circeCore,
    circeParser,
    circeGeneric,
    javaxEnterprise,
    javaxInject,
    notifyJavaClient,
    keycloakCore,
    keycloakModelJpa,
    keycloakServerSpi,
    snsSdk,
    awsSsm,
    awsSecretsManager,
    typeSafeConfig,
    quarkusCredentials % Provided,
    rds,
    scalaCache,
    mockito % Test,
    scalaTest % Test
  ),
  assembly / assemblyMergeStrategy := {
    case PathList("META-INF", "MANIFEST.MF") => MergeStrategy.discard
    case _ => MergeStrategy.first
  },
  assemblyPackageDependency / assemblyMergeStrategy := {
    case PathList("META-INF", "MANIFEST.MF") => MergeStrategy.discard
    case _ => MergeStrategy.first
  }

)

lazy val root = (project in file("."))
  .aggregate(eventPublisherSpi, govUkNotifySpi, credentialProvider)

lazy val eventPublisherSpi = (project in file("./event-publisher-spi"))
  .settings(
    name := "event-publisher-spi"
  ).settings(commonSettings)

lazy val govUkNotifySpi = (project in file("./govuk-notify-spi"))
  .settings(
    name := "govuk-notify-spi" ,
  ).settings(commonSettings)

lazy val credentialProvider = (project in file("./credentials-provider"))
  .settings(
    name := "credentials-provider"
  ).settings(commonSettings)
