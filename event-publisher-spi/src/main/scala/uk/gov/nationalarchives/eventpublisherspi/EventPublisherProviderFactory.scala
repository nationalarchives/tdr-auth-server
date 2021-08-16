package uk.gov.nationalarchives.eventpublisherspi

import org.keycloak.Config
import org.keycloak.events.{EventListenerProvider, EventListenerProviderFactory}
import org.keycloak.models.{KeycloakSession, KeycloakSessionFactory}
import uk.gov.nationalarchives.eventpublisherspi.EventPublisherProvider.EventPublisherConfig

class EventPublisherProviderFactory extends EventListenerProviderFactory {
  private val eventPublisherId = "event-publisher"

  var eventPublisherConfig: Option[EventPublisherConfig] = None

  override def create(session: KeycloakSession): EventListenerProvider = {
    EventPublisherProvider(eventPublisherConfig.get, session);
  }

  override def init(config: Config.Scope): Unit = {
    val snsUrl = config.get("snsUrl")
    val snsTopicArn = config.get("snsTopicArn")
    val tdrEnvironment = config.get("tdrEnvironment")
    eventPublisherConfig = Option(EventPublisherConfig(snsUrl, snsTopicArn, tdrEnvironment))
  }

  override def postInit(factory: KeycloakSessionFactory): Unit = { }

  override def close(): Unit = { }

  override def getId: String = {
    eventPublisherId
  }
}
