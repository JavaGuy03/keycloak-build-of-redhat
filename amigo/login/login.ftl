<!DOCTYPE html>
<html lang="${(locale.currentLanguageTag)!'vi'}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${msg("amigo.loginTitle")} | ${(realm.displayNameHtml!realm.displayName)!"Amigo"}</title>
    <link rel="icon" href="${url.resourcesPath}/img/amigo-mark.png" type="image/png">
    <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css?v=20260915-6">
</head>
<body>
    <div class="amigo-shell">
        <aside class="amigo-brand">
            <div class="amigo-brand-top">
                <img src="${url.resourcesPath}/img/amigo-mark.png" alt="" class="amigo-brand-mark">
                <span class="amigo-brand-name">AMIGO</span>
            </div>
            <div class="amigo-brand-content">
                <h1 class="amigo-brand-title">${msg("amigo.tagline")}</h1>
                <p class="amigo-brand-subtitle">${msg("amigo.subtagline")}</p>
            </div>
            <div class="amigo-brand-footer">${msg("amigo.copyright", .now?string("yyyy"))}</div>
        </aside>

        <main class="amigo-main">
            <header class="amigo-main-header">
                <img src="${url.resourcesPath}/img/amigo-logo-transparent.png" alt="Amigo" class="amigo-logo">
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

            <div class="amigo-form-wrap">
                <div class="amigo-form-head">
                    <span class="amigo-form-rule" aria-hidden="true"></span>
                    <h2 class="amigo-welcome">${msg("amigo.welcome")}</h2>
                    <p class="amigo-welcome-sub">${msg("amigo.welcomeSubtitle")}</p>
                </div>

                <#if message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
                    <div class="amigo-alert amigo-alert-${message.type}" role="alert">
                        <span class="amigo-alert-icon" aria-hidden="true">!</span>
                        <span class="amigo-alert-copy">${kcSanitize(message.summary)?no_esc}</span>
                    </div>
                </#if>

                <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">
                    <div class="amigo-field">
                        <label for="username" class="amigo-label">
                            <#if !realm.loginWithEmailAllowed>${msg("username")}
                            <#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}
                            <#else>${msg("email")}</#if>
                        </label>
                        <input tabindex="1" id="username" class="amigo-input" name="username" value="${(login.username!'')}"
                               type="text" autofocus autocomplete="username"
                               placeholder="${msg("amigo.usernamePlaceholder")}"
                               aria-invalid="<#if messagesPerField.existsError('username','password')>true<#else>false</#if>"/>
                        <#if messagesPerField.existsError('username','password') && !(message?has_content)>
                            <span class="amigo-field-error">${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}</span>
                        </#if>
                    </div>

                    <div class="amigo-field">
                        <label for="password" class="amigo-label">${msg("password")}</label>
                        <input tabindex="2" id="password" class="amigo-input" name="password"
                               type="password" autocomplete="current-password"
                               placeholder="${msg("amigo.passwordPlaceholder")}"
                               aria-invalid="<#if messagesPerField.existsError('username','password')>true<#else>false</#if>"/>
                    </div>

                    <#if realm.rememberMe && !usernameHidden??>
                        <div class="amigo-options">
                            <label class="amigo-checkbox">
                                <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox" <#if login.rememberMe??>checked</#if>>
                                <span>${msg("rememberMe")}</span>
                            </label>
                            <#if realm.resetPasswordAllowed>
                                <a tabindex="4" href="${url.loginResetCredentialsUrl}" class="amigo-link">${msg("doForgotPassword")}</a>
                            </#if>
                        </div>
                    <#elseif realm.resetPasswordAllowed>
                        <div class="amigo-options amigo-options-end">
                            <a tabindex="4" href="${url.loginResetCredentialsUrl}" class="amigo-link">${msg("doForgotPassword")}</a>
                        </div>
                    </#if>

                    <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth?has_content && auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                    <button tabindex="5" class="amigo-submit" name="login" id="kc-login" type="submit">
                        <span>${msg("doLogIn")}</span>
                        <span class="amigo-submit-arrow" aria-hidden="true">&#8594;</span>
                    </button>
                </form>

                <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
                    <p class="amigo-signup">
                        ${msg("noAccount")}
                        <a tabindex="6" href="${url.registrationUrl}" class="amigo-link">${msg("doRegister")}</a>
                    </p>
                </#if>
            </div>
        </main>
    </div>
</body>
</html>
