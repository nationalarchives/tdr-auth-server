<#assign signInPageTitle = msg("loginTitle")>
<#assign betaBanner = msg("betaBanner")>
<#assign betaBannerInfo = msg("betaBannerInfo")>
<#assign betaBannerLink = msg("betaBannerLink")>

<#macro registrationLayout pageTitle=signInPageTitle displayInfo=false displayMessage=true displayRequiredFields=false showAnotherWayIfPresent=true>
    <!DOCTYPE html>
    <html xmlns="http://www.w3.org/1999/xhtml" lang="en">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="robots" content="noindex, nofollow">

        <#if properties.meta?has_content>
            <#list properties.meta?split(' ') as meta>
                <meta name="${meta?split('==')[0]}" content="${meta?split('==')[1]}"/>
            </#list>
        </#if>
        <title>${msg("loginTitle",(realm.displayName!''))}</title>
        <link rel="icon" href="${url.resourcesPath}/img/favicon.ico"/>
        <#if properties.stylesCommon?has_content>
            <#list properties.stylesCommon?split(' ') as style>
                <link href="${url.resourcesCommonPath}/${style}" rel="stylesheet"/>
            </#list>
        </#if>
        <#if properties.styles?has_content>
            <#list properties.styles?split(' ') as style>
                <link href="${url.resourcesPath}/${style}" rel="stylesheet"/>
            </#list>
        </#if>
        <#if properties.scripts?has_content>
            <#list properties.scripts?split(' ') as script>
                <script src="${url.resourcesPath}/${script}" type="text/javascript"></script>
            </#list>
        </#if>

        <link rel="shortcut icon" type="image/ico" href="${url.resourcesPath}/img/favicon.ico">
        <script src="https://code.iconify.design/1/1.0.3/iconify.min.js"></script>
    </head>

    <body class="govuk-template__body">
    <#-- Start TDR Template header -->
    <header class="govuk-header " role="banner" data-module="header">
        <div class="govuk-header__container govuk-width-container tna-header">
            <div class="govuk-header__tna-logo">
                <a href="${properties.tdrHomeUrl}" class="govuk-header__tna_link govuk-header__tna_link--homepage">
                    <img src="${url.resourcesPath}/img/tna-horizontal-white-logo.svg"
                         class="govuk-header__tna-logo-image" alt="TNA horizontal logo"/>
                </a>
            </div>

            <div class="govuk-header__tna-content">
                <a href="#" class="govuk-header__link govuk-header__link--service-name">
                    ${msg("mainHeader")}
                </a>
            </div>
        </div>
    </header>
    <#-- End TDR Template header -->

    <#-- Start TDR Content -->
    <div class="govuk-width-container">

        <div class="govuk-phase-banner">
            <p class="govuk-phase-banner__content">
                <strong class="govuk-tag govuk-phase-banner__content__tag">${msg("betaBanner")}</strong>
                <span class="govuk-phase-banner__text">${msg("betaBannerInfo")}
                <a class="govuk-link" target="_blank" rel="noreferrer noopener"
                   href="${properties.tdrHomeUrl}/contact">${msg("betaBannerLink")}</a>
                </span>
            </p>
        </div>

        <main class="govuk-main-wrapper " id="main-content" role="main">
            <div class="govuk-grid-row">
                <div class="govuk-grid-column-two-thirds">
                    <h1 class="govuk-heading-l">${pageTitle}</h1>

                    <#-- Start TDR Error Messages -->
                    <#if displayMessage && message?has_content>
                        <#if message.type = 'error'>
                            <div class="govuk-error-summary" aria-labelledby="error-summary-title" role="alert"
                                 tabindex="-1" data-module="govuk-error-summary">
                                <h2 class="govuk-error-summary__title" id="error-summary-title">
                                    There is a problem with this form
                                </h2>
                                <div class="govuk-error-summary__body">
                                    <ul class="govuk-list govuk-error-summary__list">
                                        <li>
                                            <#if message.summary = msg("webauthn-error-register-verification")>
                                              <p>${msg("webauthn-error-register-verification")?no_esc}</p>
                                            <#elseif message.summary = msg("webauthn-error-api-get")>
                                              <p>${msg("webauthn-error-api-get")?no_esc}</p>
                                            <#else>
                                              <a href="#error-kc-form-login">${message.summary}</a>
                                            </#if>
                                        </li>
                                    </ul>
                                    <#if message.summary = msg("invalidTotpMessage") || message.summary = msg("missingTotpDeviceNameMessage")>
                                        <p>${msg("totpErrorContact")?no_esc}</p>
                                    </#if>
                                </div>
                            </div>
                        <#else>
                            <div class="govuk-warning-text" aria-labelledby="warning-message" role="alert" tabindex="-1">
                                <#if message.type = 'success'><span
                                    class="${properties.kcFeedbackSuccessIcon!}"></span></#if>
                                <#if message.type = 'warning'><span class="govuk-warning-text__icon" aria-hidden="true">!</span></#if>
                                <#if message.type = 'info'><span class="${properties.kcFeedbackInfoIcon!}"></span></#if>
                                <strong class="govuk-warning-text__text" id="warning-message">
                                    <span class="govuk-warning-text__assistive">Warning</span>
                                    ${message.summary}
                                </strong>
                            </div>
                        </#if>
                    </#if>
                    <#-- End TDR Error Messages -->

                    <#nested "form">
                </div>
            </div>
        </main>
    </div>
    <#-- End TDR Content -->

    <#-- Start TDR Template footer -->
    <footer class="govuk-footer " role="contentinfo">
        <div class="govuk-width-container ">
            <div class="govuk-footer__meta">
                <div class="govuk-footer__meta-item govuk-footer__meta-item--grow">

                    <h2 class="govuk-visually-hidden">Support links</h2>
                    <ul class="govuk-footer__inline-list">
                        <li class="govuk-footer__inline-list-item">
                            <a class="govuk-footer__link" href="${properties.tdrHomeUrl}/contact">
                                Contact
                            </a>
                        </li>
                        <li class="govuk-footer__inline-list-item">
                            <a class="govuk-footer__link" href="${properties.tdrHomeUrl}/cookies">
                                Cookies
                            </a>
                        </li>
                    </ul>

                    <svg role="presentation" focusable="false" class="govuk-footer__licence-logo"
                         xmlns="http://www.w3.org/2000/svg" viewbox="0 0 483.2 195.7" height="17" width="41">
                        <path fill="currentColor"
                              d="M421.5 142.8V.1l-50.7 32.3v161.1h112.4v-50.7zm-122.3-9.6A47.12 47.12 0 0 1 221 97.8c0-26 21.1-47.1 47.1-47.1 16.7 0 31.4 8.7 39.7 21.8l42.7-27.2A97.63 97.63 0 0 0 268.1 0c-36.5 0-68.3 20.1-85.1 49.7A98 98 0 0 0 97.8 0C43.9 0 0 43.9 0 97.8s43.9 97.8 97.8 97.8c36.5 0 68.3-20.1 85.1-49.7a97.76 97.76 0 0 0 149.6 25.4l19.4 22.2h3v-87.8h-80l24.3 27.5zM97.8 145c-26 0-47.1-21.1-47.1-47.1s21.1-47.1 47.1-47.1 47.2 21 47.2 47S123.8 145 97.8 145"/>
                    </svg>
                    <span class="govuk-footer__licence-description">
                                All content is available under the
                                <a class="govuk-footer__link"
                                   href="https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/"
                                   rel="license">Open Government Licence v3.0</a>, except where otherwise stated
                            </span>
                </div>
                <div class="govuk-footer__meta-item">
                    <a class="govuk-footer__link govuk-footer__copyright-logo"
                       href="https://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/">©
                        Crown copyright</a>
                </div>
            </div>
        </div>
    </footer>
    <script>
        window.GOVUKFrontend.initAll()
    </script>
    <#-- End TDR Template footer -->
    </body>
    </html>
</#macro>
