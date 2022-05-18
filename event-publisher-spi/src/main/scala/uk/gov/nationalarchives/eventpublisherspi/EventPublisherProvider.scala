package uk.gov.nationalarchives.eventpublisherspi

import java.net.URI
import io.circe.generic.auto._
import io.circe.syntax.EncoderOps
import org.keycloak.events.admin.AdminEvent
import org.keycloak.events.{Event, EventListenerProvider}
import org.keycloak.models.KeycloakSession
import software.amazon.awssdk.http.apache.ApacheHttpClient
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.sns.SnsClient
import software.amazon.awssdk.services.sns.model.PublishRequest
import uk.gov.nationalarchives.eventpublisherspi.EventPublisherProvider.{EventDetails, EventPublisherConfig}
import uk.gov.nationalarchives.eventpublisherspi.helpers.EventUtils.AdminEventUtils

class EventPublisherProvider(config: EventPublisherConfig, session: KeycloakSession, snsClient: SnsClient) extends EventListenerProvider {

  override def onEvent(event: Event): Unit = {
    //Currently no events published
  }

  override def onEvent(event: AdminEvent, includeRepresentation: Boolean = true): Unit = {
    if (event.isAdminRoleAssignment()) { publishAdminEvent(adminRoleAssignmentMessage, event) }
  }

  override def close(): Unit = { }

  def publishAdminEvent(f: AdminEvent => String, event: AdminEvent): Unit = {
    val publishRequest = PublishRequest.builder.message(f(event)).topicArn(config.snsTopicArn).build()
    snsClient.publish(publishRequest)
  }

  private def adminRoleAssignmentMessage(event: AdminEvent): String = {
    val userId = event.getAuthDetails.getUserId
    val realm = session.realms().getRealm(event.getRealmId)
    val affectedUserId = event.getResourcePath.split("/").tail.head
    val callingUser = session.users().getUserById(realm, userId)
    val affectedUser = session.users().getUserById(realm, affectedUserId)
    val message = s"User ${callingUser.getUsername}" +
      s" has assigned role 'admin' to user ${affectedUser.getUsername}" +
      s" from ip ${event.getAuthDetails.getIpAddress}" +
      s" in the ${event.roleMappingRepresentation().containerId.getOrElse("")} realm"
    EventDetails(config.tdrEnvironment, message).asJson.toString()
  }
}

object EventPublisherProvider {
  private val httpClient = ApacheHttpClient.builder.build

  def apply(config: EventPublisherConfig, session: KeycloakSession): EventPublisherProvider = {
    val snsClient = SnsClient.builder()
      .region(Region.EU_WEST_2)
      .httpClient(httpClient)
      .build()

    new EventPublisherProvider(config, session, snsClient)
  }

  case class EventPublisherConfig(snsTopicArn: String, tdrEnvironment: String)
  case class EventDetails(tdrEnv: String, message: String)
  case class RoleMappingRepresentation(id: Option[String] = None,
                                       name: Option[String] = None,
                                       description: Option[String] = None,
                                       composite: Option[Boolean] = None,
                                       clientRole: Option[Boolean] = None,
                                       containerId: Option[String] = None)
}
