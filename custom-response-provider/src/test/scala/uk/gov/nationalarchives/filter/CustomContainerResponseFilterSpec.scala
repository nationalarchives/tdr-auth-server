package uk.gov.nationalarchives.filter

import jakarta.ws.rs.container.{ContainerRequestContext, ContainerResponseContext}
import jakarta.ws.rs.core.MultivaluedHashMap
import org.mockito.Mockito.when
import org.mockito.MockitoSugar.mock
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers

import scala.jdk.CollectionConverters.ListHasAsScala

class CustomContainerResponseFilterSpec extends AnyFlatSpec with Matchers {

  val containerRequestContext: ContainerRequestContext = mock[ContainerRequestContext]
  val containerResponseContext: ContainerResponseContext = mock[ContainerResponseContext]

  "filter" should "add a security header in ContainerResponseContext" in {
    val multivaluedMap = new MultivaluedHashMap[String, AnyRef]()
    when(containerResponseContext.getHeaders).thenReturn(multivaluedMap)

    val provider = new CustomContainerResponseFilter()
    provider.filter(containerRequestContext, containerResponseContext)

    multivaluedMap.get("X-Permitted-Cross-Domain-Policies").asScala should be(List("none"))
  }
}
