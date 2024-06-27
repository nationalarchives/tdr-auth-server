<#import "template.ftl" as layout>
<#assign enterOtpPageTitle = msg("enterOtp")>
<@layout.registrationLayout pageTitle=enterOtpPageTitle displayHeading=false errorTarget="otp"; section>
    <#if section="header">
        ${msg("doLogIn")}
    <#elseif section="form">
        <form id="otp-login-form" action="${url.loginAction}" method="post">
            <div class="govuk-form-group<#if message?has_content>--error</#if>">
                <div class="govuk-form-group">
                    <h1 class="govuk-label-wrapper">
                        <label class="govuk-label govuk-label--l" for="code">
                            Enter your one-time passcode
                        </label>
                    </h1>
                    <div id="otp-hint" class="govuk-hint">
                        ${msg("loginTotpHint")}
                    </div>
                    <details class="govuk-details govuk-!-margin-bottom-4" data-module="govuk-details">
                        <summary class="govuk-details__summary">
                          <span class="govuk-details__summary-text">
                            Where do I find the one-time passcode?
                          </span>
                        </summary>
                        <div class="govuk-details__text">
                            <ol class="govuk-list govuk-list--number">
                                <li>${msg("otpGuidanceOne")}</li>
                                <li>${msg("otpGuidanceTwo")}</li>
                                <li>${msg("otpGuidanceThree")}</li>
                            </ol>
                            Contact <a class="govuk-link" href="mailto:tdr@nationalarchives.gov.uk"
                                       data-hsupport="email">tdr@nationalarchives.gov.uk</a> if you need support.
                        </div>
                    </details>
                    <input id="code" name="otp" autocomplete="off" type="text" class="govuk-input govuk-input--width-5"
                           inputmode="numeric" autofocus/>
                    <#if message?has_content>
                        <p class="govuk-error-message" id="error-kc-form-login">
                            <span class="govuk-visually-hidden">${msg("screenReaderError")}</span>
                            ${message.summary}
                        </p>
                    </#if>
                </div>
            </div>

            <button class="govuk-button" type="submit" data-module="govuk-button" role="button" name="login">
                Continue
            </button>
        </form>
    </#if>
</@layout.registrationLayout>
