package uk.gov.nationalarchives.eventpublisherspi

import io.circe.generic.auto._
import io.circe.syntax.EncoderOps
import org.jboss.logging.Logger
import org.keycloak.models.{KeycloakSession, SubjectCredentialManager, UserModel, UserProvider}
import org.keycloak.timer.ScheduledTask
import software.amazon.awssdk.http.apache.ApacheHttpClient
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.sns.SnsClient
import software.amazon.awssdk.services.sns.model.PublishRequest
import uk.gov.nationalarchives.eventpublisherspi.EventPublisherProvider.{EventDetails, EventPublisherConfig}

import scala.jdk.CollectionConverters._

class UserMonitoringTask(snsClient: SnsClient,
                         config: EventPublisherConfig,
                         validConfiguredCredentialTypes: List[String],
                         userSearchParams: java.util.Map[String, String]) extends ScheduledTask {

  private val logger: Logger = Logger.getLogger(classOf[UserMonitoringTask])

  override def run(session: KeycloakSession): Unit = {

    val userProvider: UserProvider =  session.users()
    val realmNames = config.realmNames
    realmNames.foreach(realmName => {
      val realm = session.realms().getRealmByName(realmName)
      val users: List[UserModel] = userProvider.searchForUserStream(realm, userSearchParams).iterator().asScala.toList

      val usersNoMFA = users
        .filter(u => Option(u.getServiceAccountClientLink).getOrElse("").isBlank)
        .filter(u => {
          val credentialManager: SubjectCredentialManager = u.credentialManager()
          validConfiguredCredentialTypes.forall(credentialType => !credentialManager.isConfiguredFor(credentialType))

        })
      val userIds = usersNoMFA.map(_.getId)
      if(usersNoMFA.nonEmpty) {
        val suffix = if(usersNoMFA.size == 1) "" else "s"
        val message =
          s"""
             |$realmName realm has ${usersNoMFA.size} user$suffix without MFA
             |${userIds.take(10).mkString("\n")}
             |""".stripMargin
        logger.info(
          s"""
             |The following users have missing MFA in realm $realmName
             |${userIds.mkString("\n")}
             |""".stripMargin)

        val eventDetails = EventDetails(config.tdrEnvironment, message).asJson.toString()
        val publishRequest = PublishRequest.builder.message(eventDetails).topicArn(config.snsTopicArn).build()
        snsClient.publish(publishRequest)
      }
    })
  }
}

object UserMonitoringTask {
  private val httpClient = ApacheHttpClient.builder.build

  private val validConfiguredCredentialTypes = List("otp", "webauthn")

  def apply(config: EventPublisherConfig): UserMonitoringTask = {
    val snsClient = SnsClient.builder()
      .region(Region.EU_WEST_2)
      .httpClient(httpClient)
      .build()
    new UserMonitoringTask(snsClient, config, validConfiguredCredentialTypes, Map[String, String]().asJava)
  }
}
