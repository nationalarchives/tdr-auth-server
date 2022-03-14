<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=true; section>
    <#if section = "header">
        ${kcSanitize(msg("webauthn-error-title"))?no_esc}
    <#elseif section = "form">
      <form id="kc-error-credential-form" class="${properties.kcFormClass!}" action="${url.loginAction}"
            method="post">
        <input type="hidden" id="executionValue" name="authenticationExecution"/>
        <input type="hidden" id="isSetRetry" name="isSetRetry"/>
      </form>

      <input tabindex="4" id="errorPageRefresh" type="button"
             class="govuk-button${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}"
             name="try-again" id="kc-try-again" value="${kcSanitize(msg("doTryAgain"))?no_esc}"
      />

        <#if isAppInitiatedAction??>
          <form action="${url.loginAction}" class="${properties.kcFormClass!}" id="kc-webauthn-settings-form"
                method="post">
            <button type="submit"
                    class="${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}"
                    id="cancelWebAuthnAIA" name="cancel-aia" value="true"/>${msg("doCancel")}
            </button>
          </form>
        </#if>

    </#if>
</@layout.registrationLayout>