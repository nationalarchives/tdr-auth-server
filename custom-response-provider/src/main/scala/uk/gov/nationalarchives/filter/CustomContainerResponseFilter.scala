package uk.gov.nationalarchives.filter

import jakarta.ws.rs.container.{ContainerRequestContext, ContainerResponseContext, ContainerResponseFilter}
import jakarta.ws.rs.ext.Provider

@Provider
class CustomContainerResponseFilter extends ContainerResponseFilter {

  override def filter(requestContext: ContainerRequestContext, responseContext: ContainerResponseContext): Unit = {
    responseContext.getHeaders.add("X-Permitted-Cross-Domain-Policies", "none")
  }
}
