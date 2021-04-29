<#import "template.ftl" as layout>
<@layout.registrationLayout; section>
    <#if section = "title">
        ${msg("loginTotpTitle")}
    <#elseif section = "header">
        ${msg("loginTotpTitle")}
    <#elseif section = "form">
      <#if mode?? && mode = "manual">
        <ol id="kc-totp-settings" class="list list-number">
          <li>
            <p>${msg("loginTotpStep1")}</p>
          </li>
          <li>
            <p>${msg("loginTotpStep2")}</p>
            <span class="code">${totp.totpSecretEncoded}</span>
          </li>
          <li>
            <p>${msg("loginTotpStep3")}</p>
          </li>
        </ol>
        <form action="${url.loginAction}" class="${properties.kcFormClass!}" id="kc-totp-settings-form" method="post">
          <div class="${properties.kcFormGroupClass!}">
            <div class="${properties.kcLabelWrapperClass!}">
              <label for="totp" class="${properties.kcLabelClass!}">${msg("loginTotpOneTime")}</label>
            </div>
            <div class="${properties.kcInputWrapperClass!}">
              <input type="text" id="totp" name="totp" autocomplete="off" class="${properties.kcInputClass!}" />
            </div>
            <input type="hidden" id="totpSecret" name="totpSecret" value="${totp.totpSecret}" />
          </div>

          <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doSubmit")}"/>
        </form>
      <#else>
        <ol id="kc-totp-settings" class="list list-number">
          <li>
            <p>${msg("loginTotpStep1")}</p>
          </li>
          <li>
            <p>${msg("loginTotpStep2")}</p>
            <img id="kc-totp-secret-qr-code" src="data:image/png;base64, ${totp.totpSecretQrCode}" alt="Figure: Barcode"><br/>
          </li>
          <li>
            <p>${msg("loginTotpStep3")}</p>
          </li>
        </ol>
        <form action="${url.loginAction}" class="${properties.kcFormClass!}" id="kc-totp-settings-form" method="post">
          <a href="${totp.manualUrl}" id="mode-manual">${msg("loginTotpUnableToScan")}</a>
          <div class="${properties.kcFormGroupClass!}">
            <div class="${properties.kcLabelWrapperClass!}">
              <label for="totp" class="${properties.kcLabelClass!}">${msg("loginTotpOneTime")}</label>
            </div>
            <div class="${properties.kcInputWrapperClass!}">
              <input type="text" id="totp" name="totp" autocomplete="off" class="${properties.kcInputClass!}" />
            </div>
            <input type="hidden" id="totpSecret" name="totpSecret" value="${totp.totpSecret}" />
          </div>

          <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doSubmit")}"/>
        </form>
      </#if>

    </#if>
</@layout.registrationLayout>