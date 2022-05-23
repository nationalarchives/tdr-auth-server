package uk.gov.nationalarchives.eventpublisherspi

import org.keycloak.events.{Event, EventType}
import org.keycloak.events.admin.{AdminEvent, AuthDetails, OperationType, ResourceType}
import org.keycloak.models._
import org.mockito.ArgumentMatchersSugar.any
import org.mockito.MockitoSugar.{mock, times, verify, when}
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers
import uk.gov.nationalarchives.aws.utils.SNSUtils
import uk.gov.nationalarchives.eventpublisherspi.EventPublisherProvider.EventPublisherConfig

import java.net.URI

class EventPublisherProviderSpec extends AnyFlatSpec with Matchers {

  "the onEvent function" should "publish a message if the 'admin' role is assigned to a user" in {
    val mockKeycloakSession = mock[KeycloakSession]
    val mockRealm = mock[RealmModel]
    val mockRealmProvider = mock[RealmProvider]
    val mockUserProvider = mock[UserProvider]
    val mockSnsUtils = mock[SNSUtils]
    val callingUser = mock[UserModel]
    val callingUserId = "2bfdc4b4-bebb-48db-8648-04e787b686a9"
    val affectedUser = mock[UserModel]
    val affectedUserId = "76254946-dfb2-4434-9c64-bf0d0c671abd"

    when(callingUser.getUsername).thenReturn("Calling Username")
    when(affectedUser.getUsername).thenReturn("Affected Username")
    when(mockKeycloakSession.realms()).thenReturn(mockRealmProvider)
    when(mockRealmProvider.getRealm(any[String])).thenReturn(mockRealm)
    when(mockKeycloakSession.users()).thenReturn(mockUserProvider)
    when(mockUserProvider.getUserById(mockRealm, callingUserId)).thenReturn(callingUser)
    when(mockUserProvider.getUserById(mockRealm, affectedUserId)).thenReturn(affectedUser)

    val authDetails = new AuthDetails()
    authDetails.setUserId(callingUserId)
    authDetails.setIpAddress("172.17.0.1")

    val adminEvent = new AdminEvent()
    adminEvent.setRealmId("master")
    adminEvent.setResourceType(ResourceType.REALM_ROLE_MAPPING)
    adminEvent.setOperationType(OperationType.CREATE)
    adminEvent.setResourcePath(s"users/$affectedUserId/role-mappings/realm")
    adminEvent.setRepresentation(
      "[{ \"id\": \"47194376-d36c-4c1e-b480-0c782052beda\"," +
        "\"name\": \"admin\",\"description\": \"${role_admin}\",\"composite\": true," +
        "\"clientRole\": false, \"containerId\": \"master\"}]"
    )
    adminEvent.setAuthDetails(authDetails)

    val expectedMessage =
      s"""{
         |  "tdrEnv" : "tdrEnv",
         |  "message" : "User Calling Username has assigned role 'admin' to user Affected Username from ip 172.17.0.1 in the master realm"
         |}""".stripMargin

    val eventPublisher = new EventPublisherProvider(EventPublisherConfig("http://snsUrl.com", "snsTopicArn", "tdrEnv"), mockKeycloakSession, mockSnsUtils)
    eventPublisher.onEvent(adminEvent)

    verify(mockSnsUtils, times(1)).publish(expectedMessage, "snsTopicArn")
  }

  "the onEvent function" should "not publish a message if a role other than 'admin' is assigned to a user" in {
    val mockKeycloakSession = mock[KeycloakSession]
    val mockSnsUtils = mock[SNSUtils]

    val adminEvent = new AdminEvent()
    adminEvent.setResourceType(ResourceType.REALM_ROLE_MAPPING)
    adminEvent.setOperationType(OperationType.CREATE)
    adminEvent.setRepresentation(
      "[{ \"id\": \"47194376-d36c-4c1e-b480-0c782052beda\"," +
        "\"name\": \"someOtherRole\",\"description\": \"${role_someOtherRole}\",\"composite\": true," +
        "\"clientRole\": false, \"containerId\": \"master\"}]"
    )

    val eventPublisher = new EventPublisherProvider(EventPublisherConfig("http://snsUrl.com", "snsTopicArn", "tdrEnv"), mockKeycloakSession, mockSnsUtils)
    eventPublisher.onEvent(adminEvent)
    verify(mockSnsUtils, times(0)).publish(any[String], any[String])
  }

  "the onEvent function" should "not publish a message if event resource type is not 'realm role mapping'" in {
    val mockKeycloakSession = mock[KeycloakSession]
    val mockSnsUtils = mock[SNSUtils]

    val adminEvent = new AdminEvent()
    adminEvent.setResourceType(ResourceType.AUTH_EXECUTION)
    adminEvent.setOperationType(OperationType.CREATE)
    adminEvent.setRepresentation(
      "[{ \"id\": \"47194376-d36c-4c1e-b480-0c782052beda\"," +
        "\"name\": \"admin\",\"description\": \"${role_admin}\",\"composite\": true," +
        "\"clientRole\": false, \"containerId\": \"master\"}]"
    )

    val eventPublisher = new EventPublisherProvider(EventPublisherConfig("http://snsUrl.com", "snsTopicArn", "tdrEnv"), mockKeycloakSession, mockSnsUtils)
    eventPublisher.onEvent(adminEvent)
    verify(mockSnsUtils, times(0)).publish(any[String], any[String])
  }

  "the onEvent function" should "not publish a message if event operation type is not 'create'" in {
    val mockKeycloakSession = mock[KeycloakSession]
    val mockSnsUtils = mock[SNSUtils]

    val adminEvent = new AdminEvent()

    adminEvent.setResourceType(ResourceType.REALM_ROLE_MAPPING)
    adminEvent.setOperationType(OperationType.DELETE)
    adminEvent.setRepresentation(
      "[{ \"id\": \"47194376-d36c-4c1e-b480-0c782052beda\"," +
        "\"name\": \"admin\",\"description\": \"${role_admin}\",\"composite\": true," +
        "\"clientRole\": false, \"containerId\": \"master\"}]"
    )

    val eventPublisher = new EventPublisherProvider(EventPublisherConfig("http://snsUrl.com", "snsTopicArn", "tdrEnv"), mockKeycloakSession, mockSnsUtils)
    eventPublisher.onEvent(adminEvent)
    verify(mockSnsUtils, times(0)).publish(any[String], any[String])
  }

  "the onEvent function" should "publish a message if the users account has been disabled" in {
    val mockKeycloakSession = mock[KeycloakSession]
    val mockKeycloakContext = mock[KeycloakContext]
    val mockKeycloakUriInfo = mock[KeycloakUriInfo]
    val mockRealm = mock[RealmModel]
    val mockRealmProvider = mock[RealmProvider]
    val mockUserProvider = mock[UserProvider]
    val mockSnsUtils = mock[SNSUtils]
    val user = mock[UserModel]
    val userId = "2bfdc4b4-bebb-48db-8648-04e787b686a9"
    val stubbedURI = URI.create("https://base-url.com/auth/")

    when(mockKeycloakSession.getContext).thenReturn(mockKeycloakContext)
    when(mockKeycloakContext.getUri).thenReturn(mockKeycloakUriInfo)
    when(mockKeycloakContext.getUri.getBaseUri).thenReturn(stubbedURI)
    when(user.getUsername).thenReturn("test-user")
    when(mockKeycloakSession.getContext).thenReturn(mockKeycloakContext)
    when(mockKeycloakSession.realms()).thenReturn(mockRealmProvider)
    when(mockRealmProvider.getRealm(any[String])).thenReturn(mockRealm)
    when(mockKeycloakSession.users()).thenReturn(mockUserProvider)
    when(mockUserProvider.getUserById(mockRealm, userId)).thenReturn(user)

    val loginEvent = new Event()
    loginEvent.setType(EventType.LOGIN_ERROR)
    loginEvent.setError("user_disabled")
    loginEvent.setRealmId("tdr")
    loginEvent.setUserId(userId)

    val expectedMessage =
      s"""{
         |  "tdrEnv" : "tdrEnv",
         |  "message" : "Keycloak id <https://base-url.com/auth/admin/tdr/console/#/realms/tdr/users/2bfdc4b4-bebb-48db-8648-04e787b686a9| 2bfdc4b4-bebb-48db-8648-04e787b686a9> has been disabled"
         |}""".stripMargin

    val eventPublisher = new EventPublisherProvider(EventPublisherConfig("http://snsUrl.com", "snsTopicArn", "tdrEnv"), mockKeycloakSession, mockSnsUtils)
    eventPublisher.onEvent(loginEvent)

    verify(mockSnsUtils, times(1)).publish(expectedMessage, "snsTopicArn")
  }

  "the onEvent function" should "not publish a message if the login event is not 'user_disabled'" in {
    val mockSession = mock[KeycloakSession]
    val mockSnsUtils = mock[SNSUtils]

    val loginEvent = new Event()
    loginEvent.setType(EventType.LOGIN_ERROR)
    loginEvent.setError("test_error")

    val eventPublisher = new EventPublisherProvider(EventPublisherConfig("http://snsUrl.com", "snsTopicArn", "tdrEnv"), mockSession, mockSnsUtils)
    eventPublisher.onEvent(loginEvent)

    verify(mockSnsUtils, times(0)).publish(any[String], any[String])
  }
}
