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
                            <ul class="govuk-list govuk-list--number">
                                <li>Make sure you have access to the smart device which has the Authenticator app linked to your Transfer Digital Records account.</li>
                                <li>Open the app on your device and go to the Transfer Digital Records account within the app to retrieve the 6 digit one-time passcode.</li>
                                <li>If the code doesn’t work, wait for the app to refresh and generate a new code and try using that instead.</li>
                            </ul>
                            <p class="govuk-body">Contact <a href="mailto:tdr@nationalarchives.gov.uk" class="govuk-link">tdr@nationalarchives.gov.uk</a> if you need support.</p>
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
