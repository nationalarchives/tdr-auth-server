<#assign signInPageTitle = msg("loginTitle")>
<#assign betaBanner = msg("betaBanner")>
<#assign tdrBetaBanner = msg("tdrBetaBanner")>
<#assign betaBannerInfo = msg("betaBannerInfo")>
<#assign tdrBetaBannerInfo = msg("tdrBetaBannerInfo")>
<#assign betaBannerLink = msg("betaBannerLink")>
<#assign tdrBetaBannerLink = msg("tdrBetaBannerLink")>
<#assign loggedInPageTitle = msg("loggedInTitle")>

<#macro registrationLayout pageTitle=signInPageTitle displayHeading=true displayMessage=true displayRequiredFields=false showAnotherWayIfPresent=true errorTarget="error-kc-form-login">
    <!DOCTYPE html>
    <html xmlns="http://www.w3.org/1999/xhtml" lang="en" class="govuk-template">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="robots" content="noindex, nofollow">

        <#if properties.meta?has_content>
            <#list properties.meta?split(' ') as meta>
                <meta name="${meta?split('==')[0]}" content="${meta?split('==')[1]}"/>
            </#list>
        </#if>
        <#if properties.blockSharedPages = 'true'>
            <#if displayMessage && message?has_content && message.type = 'error'>
            <title>Error: ${pageTitle} Transfer Digital Records - GOV.UK</title>
            <#else>
            <title>${pageTitle} Transfer Digital Records - GOV.UK</title>
            </#if>
        <#else>
            <#if displayMessage && message?has_content && message.type = 'error'>
            <title>Error: ${pageTitle} Transfer & Access Your Records - GOV.UK</title>
            <#else>
            <title>${pageTitle} Transfer & Access Your Records - GOV.UK</title>
            </#if>
        </#if>

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

    <header class="govuk-header" role="banner" data-module="govuk-header">
        <div class="govuk-header__container govuk-width-container tna-header">
            <div class="govuk-header__logo">
                <a href="${properties.tnaHomepage}" class="govuk-header__link govuk-header__link--homepage">
                    <svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" class="tna-logo" viewBox="0 0 160 160" style="pointer-events: auto;">
                            <title>The National Archives</title>
                        <path fill="transparent" d="M0 0h160v160H0z" class="tna-logo__background" style="pointer-events: auto;"></path>
                        <g class="tna-logo__foreground" fill="currentColor">
                            <path d="M1.9 107.2h156.3V158H1.9v-50.8zm0-52.7h156.3v50.8H1.9V54.5zm0-52.6h77.2v50.8H1.9V1.9zm79 0h77.2v50.8H80.9V1.9zm0-1.9H0v160h160V0H80.9z"></path>
                            <path d="M21.3 19.5h-5.4v-3h14.3v3h-5.4v18.4h-3.5zM31.6 16.5H35v9h8.4v-9h3.4v21.4h-3.4v-9.3H35v9.3h-3.4zM50.9 16.5h12.2v3h-8.8v6.1h7.4v3h-7.4v6.3h8.8v3H50.9zM19.7 69.2h3.8l6.4 12.5c.6 1.1 1.1 2.7 1.6 4h.2c-.2-1.7-.3-3.6-.3-4.8V69.2h3.5v21.4h-3.7l-6.3-12.3c-.7-1.4-1.2-2.7-1.7-4.2H23c.2 1.4.3 3.3.3 5v11.5h-3.5c-.1 0-.1-21.4-.1-21.4zM47.8 82.6l-1.7-6.3c-.3-1.1-.6-2.2-.9-3.8H45c-.3 1.6-.5 2.6-.8 3.8l-1.7 6.3h5.3zM43 69.2h4.2l6.2 21.4h-3.5l-1.5-5.2h-6.6l-1.4 5.2h-3.6L43 69.2zM57.2 72.3h-5.4v-3.1H66v3.1h-5.4v18.4h-3.4zM67.8 69.2h3.5v21.4h-3.5zM87.5 80c0-5.3-1.7-8-4.8-8-3.2 0-4.8 2.7-4.8 8 0 5.2 1.6 7.9 4.8 7.9 3.2 0 4.8-2.7 4.8-7.9m-13.3 0c0-7 3-11.1 8.5-11.1 5.4 0 8.4 4.1 8.4 11.1 0 6.9-3 11-8.4 11s-8.5-4.1-8.5-11M94.3 69.2H98l6.4 12.5c.6 1.1 1.2 2.7 1.7 4h.2c-.2-1.7-.3-3.6-.3-4.8V69.2h3.4v21.4h-3.7l-6.3-12.3c-.7-1.4-1.2-2.7-1.7-4.2h-.2c.2 1.4.3 3.3.3 5v11.5h-3.5V69.2zM122.4 82.6l-1.7-6.3c-.3-1.1-.6-2.2-.9-3.8h-.2c-.3 1.6-.5 2.6-.8 3.8l-1.7 6.3h5.3zm-4.8-13.4h4.2l6.2 21.4h-3.5l-1.5-5.2h-6.6l-1.4 5.2h-3.6l6.2-21.4zM129.9 69.2h3.5v18.4h8.4v3.1h-11.9zM26.9 135.2l-1.7-6.3c-.3-1.1-.6-2.2-.9-3.8h-.2c-.3 1.6-.5 2.6-.8 3.8l-1.7 6.3h5.3zm-4.8-13.4h4.2l6.2 21.4H29l-1.5-5.2h-6.6l-1.4 5.2h-3.6l6.2-21.4zM39.9 132.5c2.5 0 3.4-1.6 3.4-3.9 0-2.2-1-3.8-3.4-3.8h-2.7v7.7h2.7zm-6.1-10.7h6.4c4.5 0 6.7 2.4 6.7 6.6 0 3.1-1.5 5.6-3.7 6.3v.2c1 1.1 4 7.5 4.8 7.9v.5h-3.8c-1-.6-3.6-7.2-4.4-7.8h-2.5v7.8h-3.5v-21.5zM52.9 132.5c0 5.3 1.9 8 4.8 8s4-2 4-5.2l3.5.1c0 .2.1.4.1.6 0 4.4-2.1 7.5-7.5 7.5-5.2 0-8.5-3.9-8.5-11.1 0-7.1 3.3-11 8.5-11 6.4 0 7.5 4.6 7.5 7.2 0 .3 0 .7-.1.9l-3.5.1c0-3.3-1.2-5.2-4-5.2-2.9.2-4.8 2.9-4.8 8.1M68 121.8h3.5v9.1h8.3v-9.1h3.5v21.5h-3.5v-9.4h-8.3v9.4H68zM87.9 121.8h3.5v21.4h-3.5zM94.2 121.8h3.6l3.2 12.3c.5 1.9.8 3.6 1.1 5.6h.2c.3-2 .6-3.7 1.1-5.6l3.2-12.3h3.6l-6.1 21.4H100l-5.8-21.4zM112.7 121.8H125v3.1h-8.8v6h7.4v3h-7.4v6.3h8.8v3.1h-12.3zM130.4 136c0 .2-.1.5-.1.8 0 1.9.8 3.7 3.4 3.7 2.1 0 3.3-1.2 3.3-2.9 0-1.6-.7-2.4-2.2-3l-3.4-1.3c-2.4-.9-4.2-2.4-4.2-5.7 0-3.5 2.3-6.1 6.6-6.1 5.5 0 6.4 3.6 6.4 5.9 0 .3 0 .7-.1 1.1l-3.4.1c0-.2.1-.5.1-.7 0-1.7-.6-3.2-3-3.2-2.1 0-3 1.2-3 2.8 0 1.7.9 2.5 2.2 2.9l3.5 1.3c2.6 1 4.3 2.6 4.3 5.8 0 3.6-2.4 6.1-7 6.1-5.9 0-6.8-3.9-6.8-6.5 0-.3 0-.6.1-1l3.3-.1z"></path>
                        </g>
                    </svg>
                    <span class="govuk-visually-hidden">
                                The National Archives
                    </span>
                </a>
            </div>

            <div class="govuk-header__content">
                <#if properties.blockSharedPages = 'true'>
                <a href="${properties.tdrHomeUrl}" class="govuk-header__link govuk-header__service-name govuk-header__service-name--tdr">
                    ${msg("tdrMainHeader")}
                </a>
                </#if>
            </div>
        </div>
    </header>
    <#-- End TDR Template header -->

    <#-- Start TDR Content -->
    <div class="govuk-width-container">

        <div class="govuk-phase-banner">
            <p class="govuk-phase-banner__content">
                <strong class="govuk-tag govuk-phase-banner__content__tag">${msg("tdrBetaBanner")}</strong>
                <span class="govuk-phase-banner__text">${msg("tdrBetaBannerInfo")}
                <a class="govuk-link" target="_blank" rel="noreferrer noopener"
                   href="${properties.tdrHomeUrl}/contact">${msg("tdrBetaBannerLink")}</a>
                </span>
            </p>
        </div>

        <main class="govuk-main-wrapper " id="main-content" role="main">
            <div class="govuk-grid-row">
                <div class="govuk-grid-column-two-thirds">
                    <#-- Start TDR Error Messages -->
                    <#if displayMessage && message?has_content>
                        <#if message.type = 'error'>
                            <div class="govuk-error-summary" aria-labelledby="error-summary-title" role="alert"
                                 tabindex="-1" data-module="govuk-error-summary">
                                <h2 class="govuk-error-summary__title" id="error-summary-title">
                                    There is a problem
                                </h2>
                                <div class="govuk-error-summary__body">
                                    <ul class="govuk-list govuk-error-summary__list">
                                        <li>
                                            <#if message.summary = msg("webauthn-error-register-verification")>
                                                <p>${msg("webauthn-error-register-verification")?no_esc}</p>
                                            <#elseif message.summary = msg("webauthn-error-api-get")>
                                                <p>${msg("webauthn-error-api-get")?no_esc}</p>
                                            <#else>
                                                <a href="#${errorTarget}">${message.summary}</a>
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
                                <span class="govuk-warning-text__icon" aria-hidden="true">
                                    <#if message.type = 'success'>&#10003;<#-- checkmark --></#if>
                                    <#if message.type = 'warning'>!</#if>
                                    <#if message.type = 'info'>i</#if>
                                </span>
                                <strong class="govuk-warning-text__text" id="warning-message">
                                    <span class="govuk-warning-text__assistive">Warning</span>
                                    ${message.summary}
                                </strong>
                            </div>
                        </#if>
                    </#if>
                    <#-- End TDR Error Messages -->
                    <#if displayHeading>
                        <h1 class="govuk-heading-l">
                            <#if message?has_content && message.summary = msg("alreadyLoggedInMessage")>
                                ${loggedInPageTitle}
                            <#else>
                                <#if properties.blockSharedPages = 'true'>
                                    ${pageTitle}
                                <#else>
                                    <#-- Display Warning Text -->
                                    <div class="govuk-warning-text">
                                    <span class="govuk-warning-text__icon" aria-hidden="true">!</span>
                                    <strong class="govuk-warning-text__text">
                                        <span class="govuk-visually-hidden">Warning</span>
                                        Do not share your sign in details with anyone else.
                                    </strong>
                                    </div>
                                    ${pageTitle}
                                </#if>
                            </#if>
                        </h1>
                    </#if>
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
