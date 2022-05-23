package uk.gov.nationalarchives.eventpublisherspi

import io.circe.generic.auto._
import io.circe.syntax.EncoderOps
import org.keycloak.events.admin.AdminEvent
import org.keycloak.events.{Event, EventListenerProvider, EventType}
import org.keycloak.models.KeycloakSession
import software.amazon.awssdk.http.apache.ApacheHttpClient
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.sns.SnsClient
import uk.gov.nationalarchives.aws.utils.SNSUtils
import uk.gov.nationalarchives.eventpublisherspi.EventPublisherProvider.{EventDetails, EventPublisherConfig}
import uk.gov.nationalarchives.eventpublisherspi.helpers.EventUtils.AdminEventUtils

import java.net.URI

class EventPublisherProvider(config: EventPublisherConfig, session: KeycloakSession, snsUtils: SNSUtils) extends EventListenerProvider {

  override def onEvent(event: Event): Unit = {
    if(event.getType == EventType.LOGIN_ERROR && event.getError == "user_disabled") {
      publishEvent(accountDisabledMessage, event)
    }
  }

  override def onEvent(event: AdminEvent, includeRepresentation: Boolean = true): Unit = {
    if (event.isAdminRoleAssignment()) { publishAdminEvent(adminRoleAssignmentMessage, event) }
  }

  override def close(): Unit = { }

  def publishEvent(f: Event => String, event: Event): Unit = {
    snsUtils.publish(f(event), config.snsTopicArn)
  }

  def publishAdminEvent(f: AdminEvent => String, event: AdminEvent): Unit = {
    snsUtils.publish(f(event), config.snsTopicArn)
  }

  private def accountDisabledMessage(event: Event): String = {
    val baseUri = session.getContext.getUri.getBaseUri.toString
    val userId = event.getUserId
    val userLink = baseUri + s"admin/${event.getRealmId}/console/#/realms/${event.getRealmId}/users/${userId}"
    val message = s"Keycloak id <${userLink}| ${userId}> has been disabled"
    EventDetails(config.tdrEnvironment, message).asJson.toString()
  }

  private def adminRoleAssignmentMessage(event: AdminEvent): String = {
    val userId = event.getAuthDetails.getUserId()
    val realm = session.realms().getRealm(event.getRealmId())
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
    val snsUtils: SNSUtils = SNSUtils(SnsClient.builder()
      .region(Region.EU_WEST_2)
      .endpointOverride(URI.create(config.sqsUrl))
      .httpClient(httpClient)
      .build())

    new EventPublisherProvider(config, session, snsUtils)
  }

  case class EventPublisherConfig(sqsUrl: String, snsTopicArn: String, tdrEnvironment: String)
  case class EventDetails(tdrEnv: String, message: String)
  case class RoleMappingRepresentation(id: Option[String] = None,
                                       name: Option[String] = None,
                                       description: Option[String] = None,
                                       composite: Option[Boolean] = None,
                                       clientRole: Option[Boolean] = None,
                                       containerId: Option[String] = None)
}
