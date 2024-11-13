<#import "template.ftl" as layout>
<#assign configureMfaPageTitle = msg("configureMfa")>
<@layout.registrationLayout pageTitle=configureMfaPageTitle displayRequiredFields=true errorTarget="totp"; section>

    <#if section = "header">
        ${msg("loginTotpTitle")}

    <#elseif section = "form">

        <ul id="totp-settings" class="govuk-list--number">
            <li>
                <label class="govuk-label" for="supported-apps">
                    ${msg("loginTotpStep1")}
                </label>

                <p class="govuk-body">Choose and install one of the following free apps</p>

                <ul id="supported-apps" class="govuk-list govuk-list--bullet">
                    <li>Google Authenticator</li>
                    <li>Microsoft Authenticator</li>
                    <li>Free OTP</li>
                </ul>
            </li>

            <#if mode?? && mode = "manual">
                <li>
                    <p class="govuk-body" >${msg("loginTotpManualStep2")}</p>
                    <p class="govuk-body"><span id="totp-secret-key">${totp.totpSecretEncoded}</span></p>
                    <p><a class="govuk-link" href="${totp.qrUrl}" id="mode-barcode">${msg("loginTotpScanBarcode")}</a></p>
                </li>
                <li>
                    <p class="govuk-body">${msg("loginTotpManualStep3")}</p>
                    <p>
                    <ul class="govuk-list govuk-list--bullet">
                        <li id="totp-type">${msg("loginTotpType")}: ${msg("loginTotp." + totp.policy.type)}</li>
                        <li id="totp-algorithm">${msg("loginTotpAlgorithm")}: ${totp.policy.getAlgorithmKey()}</li>
                        <li id="totp-digits">${msg("loginTotpDigits")}: ${totp.policy.digits}</li>
                        <#if totp.policy.type = "totp">
                            <li id="totp-period">${msg("loginTotpInterval")}: ${totp.policy.period}</li>
                        <#elseif totp.policy.type = "hotp">
                            <li id="totp-counter">${msg("loginTotpCounter")}: ${totp.policy.initialCounter}</li>
                        </#if>
                    </ul>
                    </p>
                </li>
            <#else>
                <li>
                    <div class="govuk-form-group">
                        <p class="govuk-body">${msg("loginTotpStep2")}</p>
                        <p class="govuk-body">Open the app and scan the QR code shown below.</p>
                        <img id="totp-secret-qr-code" src="data:image/png;base64, ${totp.totpSecretQrCode}" alt="Figure: Barcode"><br/>
                        <a class="govuk-link" href="${totp.manualUrl}" id="mode-manual">${msg("loginTotpUnableToScan")}</a>
                    </div>

                </li>
            </#if>
            <li>
                <p class="govuk-body">${msg("loginTotpStep3")}</p>
                <p class="govuk-body">Your app will show a 6-digit code. Enter that code in the box below.</p>
                <form action="${url.loginAction}" id="totp-settings-form" method="post">
                    <div class="govuk-form-group<#if message?has_content && message.type = 'error'>--error</#if>">
                        <label for="totp" class="govuk-label">${msg("authenticatorCode")}</label>
                        <input type="text" id="totp" name="totp" autocomplete="off" class="govuk-input govuk-!-width-two-thirds" />
                        <input type="hidden" id="totpSecret" name="totpSecret" value="${totp.totpSecret}" />
                        <#if mode??><input type="hidden" id="mode" name="mode" value="${mode}"/></#if>
                    </div>
                    <#if message?has_content && message.type = 'error'>
                      <p class="govuk-error-message" id="error-kc-form-login">
                        <span class="govuk-visually-hidden">${msg("screenReaderError")}</span>
                        ${message.summary}
                      </p>
                    </#if>
                    <button class="govuk-button" type="submit" data-module="govuk-button" role="button" name="login">
                        ${msg("doSubmit")}
                    </button>
                </form>
            </li>
        </ul>
    </#if>
</@layout.registrationLayout>
