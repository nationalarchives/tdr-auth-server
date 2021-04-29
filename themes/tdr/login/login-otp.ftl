<#import "template.ftl" as layout>
<@layout.registrationLayout; section>
    <#if section = "title">
        ${msg("loginTitle",realm.displayName)}
    <#elseif section = "header">
        ${msg("loginTitleHtml",realm.displayNameHtml)?no_esc}
    <#elseif section = "form">
      <form id="kc-totp-login-form" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">
        <div class="govuk-form-group--error">
          <div class="govuk-form-group">
            <label for="totp" class="govuk-label">${msg("loginTotpOneTime")}</label>
          </div>
          <input id="totp" name="totp" autocomplete="off" type="text" class="govuk-input govuk-!-width-two-thirds" autofocus/>
        </div>
          ${message?has_content?c}
<#--          <#if message.type = 'error'>-->
<#--            <span class="govuk-error-message" id="error-kc-form-login">-->
<#--                  <span class="govuk-visually-hidden">${msg("screenReaderError")}</span>-->
<#--                  ${message.summary}-->
<#--            </span>-->
<#--          </#if>-->
        <button class="govuk-button" type="submit" data-module="govuk-button" role="button" name="login">
            ${msg("signInButton")}
        </button>
      </form>
    </#if>
</@layout.registrationLayout>