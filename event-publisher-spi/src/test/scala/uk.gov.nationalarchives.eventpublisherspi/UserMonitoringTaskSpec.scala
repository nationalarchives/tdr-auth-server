package uk.gov.nationalarchives.eventpublisherspi

import org.keycloak.models._
import org.mockito.{ArgumentCaptor, Mockito, MockitoSugar}
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers
import software.amazon.awssdk.services.sns.SnsClient
import software.amazon.awssdk.services.sns.model.PublishRequest
import uk.gov.nationalarchives.eventpublisherspi.EventPublisherProvider.EventPublisherConfig

import java.util
import java.util.UUID
import scala.jdk.CollectionConverters._

class UserMonitoringTaskSpec extends AnyFlatSpec with Matchers with MockitoSugar {

  val validConfiguredCredentialTypes: List[String] = List("otp", "webauthn")
  val otpCredentialType: String = validConfiguredCredentialTypes.head
  val webauthnCredentialType: String = validConfiguredCredentialTypes.last
  val userId = "dfd7356c-e6e0-40dd-affd-de04e29ad359"
  val userId2 = "4b3c3e89-775a-4c69-974e-bdc194a04d2d"
  val topicArn = "snsTopicArn"
  val searchMap: util.Map[String, String] = Map[String, String]().asJava

  "The run method" should "not send a message if there are no users missing MFA" in {
    val mockSession = mock[KeycloakSession]
    val mockRealmProvider = mock[RealmProvider]
    val mockRealmModel = mock[RealmModel]
    val mockUserCredentialManager = mock[SubjectCredentialManager]
    val mockUserModel = mock[UserModel]
    val mockUserProvider = mock[UserProvider]
    val mockSnsClient = Mockito.mock(classOf[SnsClient])

    when(mockUserProvider.searchForUserStream(mockRealmModel, searchMap)).thenReturn(java.util.stream.Stream.of(mockUserModel))
    when(mockUserCredentialManager.isConfiguredFor(otpCredentialType)).thenReturn(true)
    when(mockUserCredentialManager.isConfiguredFor(webauthnCredentialType)).thenReturn(true)
    when(mockRealmProvider.getRealmByName("testRealm")).thenReturn(mockRealmModel)
    when(mockSession.users()).thenReturn(mockUserProvider)
    when(mockSession.realms()).thenReturn(mockRealmProvider)
    when(mockUserModel.credentialManager()).thenReturn(mockUserCredentialManager)
    new UserMonitoringTask(mockSnsClient, EventPublisherConfig("", "test", Set("testRealm")), validConfiguredCredentialTypes, searchMap).run(mockSession)

    verifyZeroInteractions(mockSnsClient)
  }

  "The run method" should "send a message if there is one user with MFA and one without" in {
    val mockSession = mock[KeycloakSession]
    val mockRealmProvider = mock[RealmProvider]
    val mockRealmModel = mock[RealmModel]
    val mockUserCredentialManagerWithMFA = mock[SubjectCredentialManager]
    val mockUserCredentialManagerWithoutMFA = mock[SubjectCredentialManager]
    val mockUserModelWithMFA = mock[UserModel]
    val mockUserModelWithoutMFA = mock[UserModel]
    val mockUserProvider = mock[UserProvider]
    val mockSnsClient = Mockito.mock(classOf[SnsClient])
    val publishRequestCaptor: ArgumentCaptor[PublishRequest] = ArgumentCaptor.forClass(classOf[PublishRequest])

    when(mockUserModelWithoutMFA.getId).thenReturn(userId)
    when(mockUserModelWithMFA.getServiceAccountClientLink).thenReturn("")
    when(mockUserModelWithoutMFA.getServiceAccountClientLink).thenReturn("")
    when(mockUserProvider.searchForUserStream(mockRealmModel, searchMap)).thenReturn(java.util.stream.Stream.of(mockUserModelWithMFA, mockUserModelWithoutMFA))
    when(mockUserCredentialManagerWithMFA.isConfiguredFor(otpCredentialType)).thenReturn(true)
    when(mockUserCredentialManagerWithMFA.isConfiguredFor(webauthnCredentialType)).thenReturn(true)
    when(mockUserCredentialManagerWithoutMFA.isConfiguredFor(otpCredentialType)).thenReturn(false)
    when(mockUserCredentialManagerWithoutMFA.isConfiguredFor(webauthnCredentialType)).thenReturn(false)
    when(mockRealmProvider.getRealmByName("testRealm")).thenReturn(mockRealmModel)
    when(mockSession.users()).thenReturn(mockUserProvider)
    when(mockSession.realms()).thenReturn(mockRealmProvider)
    when(mockUserModelWithMFA.credentialManager()).thenReturn(mockUserCredentialManagerWithMFA)
    when(mockUserModelWithoutMFA.credentialManager()).thenReturn(mockUserCredentialManagerWithoutMFA)
    new UserMonitoringTask(mockSnsClient, EventPublisherConfig(topicArn, "test", Set("testRealm")), validConfiguredCredentialTypes, searchMap).run(mockSession)

    val expectedMessage = """{
                             |  "tdrEnv" : "test",
                             |  "message" : "\ntestRealm realm has 1 user without MFA\ndfd7356c-e6e0-40dd-affd-de04e29ad359\n"
                             |}""".stripMargin

    verify(mockSnsClient, times(1)).publish(publishRequestCaptor.capture())

    val publishRequest: PublishRequest = publishRequestCaptor.getValue
    publishRequest.message should equal(expectedMessage)
    publishRequest.topicArn should equal(topicArn)
  }

  "The run method" should "send a message if there are two users with MFA missing" in {
    val mockSession = mock[KeycloakSession]
    val mockRealmProvider = mock[RealmProvider]
    val mockRealmModel = mock[RealmModel]
    val mockUserCredentialManagerWithoutMFA1 = mock[SubjectCredentialManager]
    val mockUserCredentialManagerWithoutMFA2 = mock[SubjectCredentialManager]
    val mockUserModelWithoutMFA1 = mock[UserModel]
    val mockUserModelWithoutMFA2 = mock[UserModel]
    val mockUserProvider = mock[UserProvider]
    val mockSnsClient = Mockito.mock(classOf[SnsClient])
    val publishRequestCaptor: ArgumentCaptor[PublishRequest] = ArgumentCaptor.forClass(classOf[PublishRequest])

    when(mockUserModelWithoutMFA1.getId).thenReturn(userId)
    when(mockUserModelWithoutMFA2.getId).thenReturn(userId2)
    when(mockUserProvider.searchForUserStream(mockRealmModel, searchMap))
      .thenReturn(java.util.stream.Stream.of(mockUserModelWithoutMFA1, mockUserModelWithoutMFA2))
    when(mockUserCredentialManagerWithoutMFA1.isConfiguredFor(otpCredentialType)).thenReturn(false)
    when(mockUserCredentialManagerWithoutMFA1.isConfiguredFor(webauthnCredentialType)).thenReturn(false)
    when(mockUserCredentialManagerWithoutMFA2.isConfiguredFor(otpCredentialType)).thenReturn(false)
    when(mockUserCredentialManagerWithoutMFA2.isConfiguredFor(webauthnCredentialType)).thenReturn(false)
    when(mockRealmProvider.getRealmByName("testRealm")).thenReturn(mockRealmModel)
    when(mockSession.users()).thenReturn(mockUserProvider)
    when(mockSession.realms()).thenReturn(mockRealmProvider)
    when(mockUserModelWithoutMFA1.credentialManager()).thenReturn(mockUserCredentialManagerWithoutMFA1)
    when(mockUserModelWithoutMFA2.credentialManager()).thenReturn(mockUserCredentialManagerWithoutMFA2)
    new UserMonitoringTask(mockSnsClient, EventPublisherConfig(topicArn, "test", Set("testRealm")), validConfiguredCredentialTypes, searchMap).run(mockSession)

    val expectedMessage = """{
                            |  "tdrEnv" : "test",
                            |  "message" : "\ntestRealm realm has 2 users without MFA\ndfd7356c-e6e0-40dd-affd-de04e29ad359\n4b3c3e89-775a-4c69-974e-bdc194a04d2d\n"
                            |}""".stripMargin

    verify(mockSnsClient, times(1)).publish(publishRequestCaptor.capture())

    val publishRequest: PublishRequest = publishRequestCaptor.getValue
    publishRequest.message should equal(expectedMessage)
    publishRequest.topicArn should equal(topicArn)
  }

  "The run method" should "send a message if there are two users in two different realms with MFA missing" in {
    val mockSession = mock[KeycloakSession]
    val mockRealmProvider = mock[RealmProvider]
    val mockRealmModel1 = mock[RealmModel]
    val mockRealmModel2 = mock[RealmModel]
    val mockUserCredentialManagerWithoutMFA1 = mock[SubjectCredentialManager]
    val mockUserCredentialManagerWithoutMFA2 = mock[SubjectCredentialManager]
    val mockUserModelWithoutMFA1 = mock[UserModel]
    val mockUserModelWithoutMFA2 = mock[UserModel]
    val mockUserProvider = mock[UserProvider]
    val mockSnsClient = Mockito.mock(classOf[SnsClient])
    val publishRequestCaptor: ArgumentCaptor[PublishRequest] = ArgumentCaptor.forClass(classOf[PublishRequest])

    when(mockUserModelWithoutMFA1.getId).thenReturn(userId)
    when(mockUserModelWithoutMFA2.getId).thenReturn(userId2)
    when(mockUserProvider.searchForUserStream(mockRealmModel1, searchMap)).thenReturn(java.util.stream.Stream.of(mockUserModelWithoutMFA1))
    when(mockUserProvider.searchForUserStream(mockRealmModel2, searchMap)).thenReturn(java.util.stream.Stream.of(mockUserModelWithoutMFA2))
    when(mockUserCredentialManagerWithoutMFA1.isConfiguredFor(otpCredentialType)).thenReturn(false)
    when(mockUserCredentialManagerWithoutMFA1.isConfiguredFor(webauthnCredentialType)).thenReturn(false)
    when(mockUserCredentialManagerWithoutMFA2.isConfiguredFor(otpCredentialType)).thenReturn(false)
    when(mockUserCredentialManagerWithoutMFA2.isConfiguredFor(webauthnCredentialType)).thenReturn(false)
    when(mockRealmProvider.getRealmByName("testRealm1")).thenReturn(mockRealmModel1)
    when(mockRealmProvider.getRealmByName("testRealm2")).thenReturn(mockRealmModel2)
    when(mockSession.users()).thenReturn(mockUserProvider)
    when(mockSession.realms()).thenReturn(mockRealmProvider)
    when(mockUserModelWithoutMFA1.credentialManager()).thenReturn(mockUserCredentialManagerWithoutMFA1)
    when(mockUserModelWithoutMFA2.credentialManager()).thenReturn(mockUserCredentialManagerWithoutMFA2)
    new UserMonitoringTask(mockSnsClient, EventPublisherConfig(topicArn, "test", Set("testRealm1", "testRealm2")),
      validConfiguredCredentialTypes, searchMap).run(mockSession)

    val expectedMessage1 = """{
                            |  "tdrEnv" : "test",
                            |  "message" : "\ntestRealm1 realm has 1 user without MFA\ndfd7356c-e6e0-40dd-affd-de04e29ad359\n"
                            |}""".stripMargin

    val expectedMessage2 = """{
                            |  "tdrEnv" : "test",
                            |  "message" : "\ntestRealm2 realm has 1 user without MFA\n4b3c3e89-775a-4c69-974e-bdc194a04d2d\n"
                            |}""".stripMargin

    verify(mockSnsClient, times(2)).publish(publishRequestCaptor.capture())

    val publishRequest1: PublishRequest = publishRequestCaptor.getAllValues.asScala.head
    val publishRequest2: PublishRequest = publishRequestCaptor.getAllValues.asScala.last

    publishRequest1.message should equal(expectedMessage1)
    publishRequest1.topicArn should equal(topicArn)
    publishRequest2.message should equal(expectedMessage2)
    publishRequest2.topicArn should equal(topicArn)
  }

  "The run method" should "not send a message if there is a user without otp but with webauthn" in {
    val mockSession = mock[KeycloakSession]
    val mockRealmProvider = mock[RealmProvider]
    val mockRealmModel = mock[RealmModel]
    val mockUserCredentialManager = mock[SubjectCredentialManager]
    val mockUserModel = mock[UserModel]
    val mockUserProvider = mock[UserProvider]
    val mockSnsClient = Mockito.mock(classOf[SnsClient])

    when(mockUserProvider.searchForUserStream(mockRealmModel, searchMap)).thenReturn(java.util.stream.Stream.of(mockUserModel))
    when(mockUserCredentialManager.isConfiguredFor(otpCredentialType)).thenReturn(false)
    when(mockUserCredentialManager.isConfiguredFor(webauthnCredentialType)).thenReturn(true)
    when(mockRealmProvider.getRealmByName("testRealm")).thenReturn(mockRealmModel)
    when(mockSession.users()).thenReturn(mockUserProvider)
    when(mockSession.realms()).thenReturn(mockRealmProvider)
    when(mockUserModel.credentialManager()).thenReturn(mockUserCredentialManager)
    new UserMonitoringTask(mockSnsClient, EventPublisherConfig("", "test", Set("testRealm")), validConfiguredCredentialTypes, searchMap).run(mockSession)

    verifyZeroInteractions(mockSnsClient)
  }

  "The run method" should "not send a message if only service account users are missing MFA" in {
    val mockSession = mock[KeycloakSession]
    val mockRealmProvider = mock[RealmProvider]
    val mockRealmModel = mock[RealmModel]
    val mockUserCredentialManager = mock[SubjectCredentialManager]
    val mockUserModel = mock[UserModel]
    val mockUserProvider = mock[UserProvider]
    val mockSnsClient = Mockito.mock(classOf[SnsClient])

    when(mockUserProvider.searchForUserStream(mockRealmModel, searchMap)).thenReturn(java.util.stream.Stream.of(mockUserModel))
    when(mockUserCredentialManager.isConfiguredFor(otpCredentialType)).thenReturn(true)
    when(mockUserCredentialManager.isConfiguredFor(webauthnCredentialType)).thenReturn(true)
    when(mockRealmProvider.getRealmByName("testRealm")).thenReturn(mockRealmModel)
    when(mockSession.users()).thenReturn(mockUserProvider)
    when(mockSession.realms()).thenReturn(mockRealmProvider)
    when(mockUserModel.getServiceAccountClientLink).thenReturn(UUID.randomUUID().toString)
    new UserMonitoringTask(mockSnsClient, EventPublisherConfig("", "test", Set("testRealm")), validConfiguredCredentialTypes, searchMap).run(mockSession)

    verifyZeroInteractions(mockSnsClient)
  }
}
