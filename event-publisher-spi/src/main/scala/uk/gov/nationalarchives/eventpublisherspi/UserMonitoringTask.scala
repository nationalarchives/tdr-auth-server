package uk.gov.nationalarchives.eventpublisherspi

import org.jboss.logging.Logger
import org.keycloak.models.{KeycloakSession, UserModel, UserProvider}
import org.keycloak.timer.ScheduledTask
import software.amazon.awssdk.http.apache.ApacheHttpClient
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.sns.SnsClient
import uk.gov.nationalarchives.aws.utils.SNSUtils
import uk.gov.nationalarchives.eventpublisherspi.EventPublisherProvider.{EventDetails, EventPublisherConfig}
import io.circe.generic.auto._
import io.circe.syntax.EncoderOps
import java.net.URI
import scala.jdk.CollectionConverters._

class UserMonitoringTask(snsUtils: SNSUtils, config: EventPublisherConfig, credentialType: String) extends ScheduledTask {
  val logger: Logger = Logger.getLogger(classOf[UserMonitoringTask])

  override def run(session: KeycloakSession): Unit = {
    val userProvider: UserProvider =  session.users()
    val realms = session.realms()
      .getRealmsStream.iterator().asScala.toList
    realms.foreach(realm => {
      val credentialManager = session.userCredentialManager()
      val users: List[UserModel] = userProvider.getUsersStream(realm).iterator().asScala.toList
      val usersNoMFA = users
        .filter(u => {
          !credentialManager.isConfiguredFor(realm, u, credentialType)
        })
      val userIds = usersNoMFA.map(_.getId)
      val realmName = realm.getName
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
        snsUtils.publish(eventDetails, config.snsTopicArn)
      }
    })
  }
}

object UserMonitoringTask {
  private val httpClient = ApacheHttpClient.builder.build

  private val credentialType = "otp"

  def apply(config: EventPublisherConfig): UserMonitoringTask = {
    val snsUtils: SNSUtils = SNSUtils(SnsClient.builder()
      .region(Region.EU_WEST_2)
      .endpointOverride(URI.create(config.sqsUrl))
      .httpClient(httpClient)
      .build())
    new UserMonitoringTask(snsUtils, config, credentialType)
  }
}
