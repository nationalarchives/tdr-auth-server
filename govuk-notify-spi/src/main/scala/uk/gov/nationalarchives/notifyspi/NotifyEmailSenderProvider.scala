package uk.gov.nationalarchives.notifyspi

import java.util
import org.keycloak.email.{EmailException, EmailSenderProvider}
import org.keycloak.models.UserModel
import software.amazon.awssdk.http.apache.ApacheHttpClient
import software.amazon.awssdk.regions.Region
import uk.gov.service.notify.NotificationClient

import java.net.URI
import scala.jdk.CollectionConverters._
import scala.util.{Failure, Success, Try}
import software.amazon.awssdk.services.ssm.SsmClient
import software.amazon.awssdk.services.ssm.model.GetParameterRequest
import com.typesafe.config.{ConfigFactory, Config => TypeSafeConfig}

class NotifyEmailSenderProvider(environmentVariables: Map[String, String]) extends EmailSenderProvider {
  val configFactory: TypeSafeConfig = ConfigFactory.load
  val notifyApiKeyPath: String = configFactory.getString("notify.apiKeyPath")
  val notifyTemplateIdPath: String = configFactory.getString("notify.templateIdPath")

  def getApiKey: String = {
    getSsmParameterValue(notifyApiKeyPath)
  }

  def getTemplateId: String = {
    getSsmParameterValue(notifyTemplateIdPath)
  }

  private def getSsmParameterValue(parameterPath: String): String = {
    val httpClient = ApacheHttpClient.builder.build
    val ssmClient: SsmClient = SsmClient.builder()
      .httpClient(httpClient)
      .region(Region.EU_WEST_2)
      .build()
    val getParameterRequest = GetParameterRequest.builder.name(parameterPath).withDecryption(true).build
    ssmClient.getParameter(getParameterRequest).parameter().value()
  }

  override def send(config: util.Map[String, String],
                     user: UserModel,
                     subject: String,
                     textBody: String,
                     htmlBody: String): Unit = {

    val notifyClient = new NotificationClient(getApiKey)

    val personalisation: Map[String, String] = Map(
      "keycloakMessage" -> textBody,
      "keycloakSubject" -> subject)

    sendNotifyEmail(notifyClient, NotifyEmailInfo(getTemplateId, user.getEmail, personalisation, user.getId))
  }

  override def close(): Unit = { }

  def sendNotifyEmail(notifyClient: NotificationClient, emailInfo: NotifyEmailInfo): Unit = {
    Try {
      notifyClient.sendEmail(
        emailInfo.templateId,
        emailInfo.userEmail,
        emailInfo.personalisation.asJava,
        emailInfo.reference)
    } match {
      case Failure(exception) => throw new EmailException(exception)
      case Success(_) => ()
    }
  }

  override def send(config: util.Map[String, String], address: String, subject: String, textBody: String, htmlBody: String): Unit = ()
}

case class NotifyEmailInfo(templateId: String, userEmail: String, personalisation: Map[String, String], reference: String)
