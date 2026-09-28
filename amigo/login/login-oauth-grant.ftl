<#assign amigoCommon = url.resourcesPath + "/../../common/amigo">
<!DOCTYPE html>
<html lang="${(locale.currentLanguageTag)!'vi'}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${msg("amigo.consentPageTitle")} | ${(realm.displayNameHtml!realm.displayName)!"Amigo"}</title>
    <link rel="icon" href="${amigoCommon}/img/amigo-mark.png" type="image/png">
    <link rel="stylesheet" href="${amigoCommon}/css/brand.css?v=20260925-02">
    <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css?v=20260925-02">
</head>
<body>
    <div class="amigo-shell">
        <aside class="amigo-brand">
            <div class="amigo-brand-top">
                <img src="${amigoCommon}/img/amigo-logo-transparent.png" alt="AMIGO" class="amigo-brand-logo-img">
            </div>
            <div class="amigo-brand-content">
                <h1 class="amigo-brand-title">${msg("amigo.tagline")}</h1>
                <p class="amigo-brand-subtitle">${msg("amigo.subtagline")}</p>
            </div>
            <div class="amigo-brand-footer">${msg("amigo.copyright", .now?string("yyyy"))}</div>
        </aside>

        <main class="amigo-main">
            <header class="amigo-main-header">
                <div class="amigo-header-brand">
                    <img src="${amigoCommon}/img/amigo-logo-transparent.png" alt="Amigo" class="amigo-logo">
                </div>

                <#if realm.internationalizationEnabled && locale.supported?size gt 1>
                    <nav class="amigo-languages" aria-label="${msg("amigo.language")}">
                        <#list locale.supported as l>
                            <a href="${l.url}"
                               class="amigo-language-link<#if l.label == locale.current> is-active</#if>"
                               <#if l.label == locale.current>aria-current="page"</#if>><#if l.label?contains("Việt") || l.label?contains("Vietnamese")>${msg("amigo.vietnamese")}<#elseif l.label?contains("English") || l.label?contains("Anh")>${msg("amigo.english")}<#else>${l.label}</#if></a>
                        </#list>
                    </nav>
                </#if>
            </header>

            <div class="amigo-form-wrap amigo-consent-wrap">
                <section class="amigo-form-card" aria-labelledby="amigo-consent-title">
                    <div class="amigo-form-head amigo-consent-head">
                        <#if client.name?has_content>
                            <#assign consentClientName = advancedMsg(client.name)>
                        <#elseif client.clientId?has_content>
                            <#assign consentClientName = client.clientId>
                        <#else>
                            <#assign consentClientName = msg("amigo.consentClientFallback")>
                        </#if>

                        <div class="amigo-consent-badge">
                            <span class="amigo-consent-badge-icon" aria-hidden="true">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M12 3 5 6v5c0 4.6 2.8 8.1 7 10 4.2-1.9 7-5.4 7-10V6l-7-3Z"/>
                                    <path d="m9 12 2 2 4-4"/>
                                </svg>
                            </span>
                            <span>${msg("amigo.consentEyebrow")}</span>
                        </div>

                        <h2 id="amigo-consent-title" class="amigo-welcome amigo-consent-title">${msg("amigo.consentTitle")}</h2>
                        <p class="amigo-client-context">
                            ${msg("amigo.consentAppPrefix")}
                            <strong>${consentClientName}</strong>
                            ${msg("amigo.consentAppSuffix")}
                        </p>
                        <p class="amigo-welcome-sub amigo-consent-subtitle">${msg("amigo.consentSubtitle")}</p>
                    </div>

                    <#if message?has_content>
                        <div class="amigo-alert amigo-alert-${message.type}" role="alert">
                            <span class="amigo-alert-copy">${kcSanitize(message.summary)?no_esc}</span>
                        </div>
                    </#if>

                    <div id="kc-oauth" class="amigo-consent-content">
                        <div class="amigo-consent-section-head">
                            <h3 class="amigo-consent-request">${msg("amigo.consentRequest")}</h3>
                            <#if oauth.clientScopesRequested??>
                                <span class="amigo-scope-count">
                                    <#if oauth.clientScopesRequested?size == 1>
                                        ${msg("amigo.consentPermissionCountSingle")}
                                    <#else>
                                        ${msg("amigo.consentPermissionCount", oauth.clientScopesRequested?size)}
                                    </#if>
                                </span>
                            </#if>
                        </div>
                        <ul class="amigo-scope-list">
                            <#if oauth.clientScopesRequested??>
                                <#list oauth.clientScopesRequested as clientScope>
                                    <li class="amigo-scope-item">
                                        <span class="amigo-scope-icon" aria-hidden="true">
                                            <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="16" height="16"><path d="m5 10 3 3 7-7"/></svg>
                                        </span>
                                        <span>
                                            <#if !clientScope.parameterizedScopeParameter??>
                                                ${advancedMsg(clientScope.consentScreenText)}
                                            <#else>
                                                ${advancedMsg(clientScope.consentScreenText)}:
                                                <strong>${clientScope.parameterizedScopeParameter}</strong>
                                            </#if>
                                        </span>
                                    </li>
                                </#list>
                            </#if>
                        </ul>

                        <#if client.attributes.policyUri?? || client.attributes.tosUri??>
                            <div class="amigo-consent-legal">
                                <p>
                                    <#if client.name?has_content>
                                        ${msg("oauthGrantInformation", advancedMsg(client.name))}
                                    <#else>
                                        ${msg("oauthGrantInformation", client.clientId)}
                                    </#if>
                                </p>
                                <div class="amigo-consent-legal-links">
                                    <#if client.attributes.tosUri??>
                                        <a href="${client.attributes.tosUri}" target="_blank" rel="noopener noreferrer">${msg("oauthGrantTos")}</a>
                                    </#if>
                                    <#if client.attributes.policyUri??>
                                        <a href="${client.attributes.policyUri}" target="_blank" rel="noopener noreferrer">${msg("oauthGrantPolicy")}</a>
                                    </#if>
                                </div>
                            </div>
                        </#if>

                        <form class="amigo-consent-form" action="${url.oauthAction}" method="post">
                            <input type="hidden" name="code" value="${oauth.code}">
                            <button class="amigo-submit" name="accept" id="kc-login" type="submit">
                                <span>${msg("amigo.consentApprove")}</span>
                                <span class="amigo-submit-arrow" aria-hidden="true">&#8594;</span>
                            </button>
                            <button class="amigo-cancel" name="cancel" id="kc-cancel" type="submit">${msg("amigo.consentDecline")}</button>
                        </form>
                    </div>

                    <div class="amigo-trust-banner">
                        <svg class="amigo-trust-icon" viewBox="0 0 20 20" fill="currentColor" width="16" height="16" aria-hidden="true">
                            <path fill-rule="evenodd" d="M2.166 4.999A11.954 11.954 0 0010 1.944 11.954 11.954 0 0017.834 5c.11.65.166 1.32.166 2.001 0 5.225-3.34 9.67-8 11.317C5.34 16.67 2 12.225 2 7c0-.682.057-1.35.166-2.001zm11.541 3.708a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                        </svg>
                        <div class="amigo-trust-text">
                            <strong>${msg("amigo.consentSecurityTitle")}</strong>
                            <span>${msg("amigo.consentSecurityDesc")}</span>
                        </div>
                    </div>
                </section>
            </div>
        </main>
    </div>
</body>
</html>
