<#import "template.ftl" as layout>
<@layout.registrationLayout errorTarget="username"; section>
    <#if section = "header">
        ${msg("doLogIn")}
    <#elseif section = "form">
        <#if realm.password>
          <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}"
                method="post">
            <div class="govuk-form-group<#if message?has_content>--error</#if>">
              <div class="govuk-form-group">
                  <label class="govuk-label" for="username">
                      ${msg("email")}
                  </label>
                <input id="username" class="govuk-input govuk-!-width-two-thirds" name="username"
                       value="${(login.username!'')}" type="text" autofocus autocomplete="email"/>
              </div>
              <div class="govuk-form-group">
                  <label class="govuk-label" for="password">
                  ${msg("password")}
                  </label>
                <input id="password" class="govuk-input govuk-!-width-two-thirds" name="password" type="password"
                       autocomplete="current-password"/>
              </div>
            </div>

              <#if message?has_content && message.type = 'error'>
                <p class="govuk-error-message" id="error-kc-form-login">
                  <span class="govuk-visually-hidden">${msg("screenReaderError")}</span>
                  ${message.summary}
                </p>
              </#if>

            <input type="hidden" id="id-hidden-input" name="credentialId"
                   <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>


            <button class="govuk-button" type="submit" data-module="govuk-button" role="button" name="login">
                ${msg("signInButton")}
            </button>
          </form>
          <p class="govuk-body">
            <a href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a>
          </p>
          <p class="govuk-body">
            If you have problems signing in, contact us at <a class="govuk-link" href="mailto:tdr@nationalarchives.gov.uk" data-hsupport="email">tdr@nationalarchives.gov.uk</a>
          </p>
        </#if>
    </#if>
</@layout.registrationLayout>
