<!DOCTYPE html>
<html lang="${(locale.currentLanguageTag)!'vi'}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${msg("amigo.loginTitle")} | ${(realm.displayNameHtml!realm.displayName)!"Amigo"}</title>
    <link rel="icon" href="${url.resourcesPath}/img/amigo-mark.png" type="image/png">
    <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css">
</head>
<body>
    <!-- LOGO - top right corner -->
    <div class="amigo-logo-corner">
        <img src="${url.resourcesPath}/img/amigo-logo-transparent.png" alt="Amigo" class="amigo-logo">
    </div>

    <div class="amigo-container">

        <!-- LEFT PANEL -->
        <div class="amigo-left">
            <div class="amigo-left-content">
                <h1 class="amigo-tagline">${msg("amigo.tagline")}</h1>
                <p class="amigo-subtagline">${msg("amigo.subtagline")}</p>
            </div>
            <div class="amigo-glow amigo-glow-1"></div>
            <div class="amigo-glow amigo-glow-2"></div>
            <svg class="amigo-mark-watermark" viewBox="0 0 494.922743 495.237718" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
                <g transform="translate(-20.867558,514.427514) scale(0.1,-0.1)" fill="currentColor" stroke="none">
                    <path d="M2505 5138 c-22 -4 -64 -7 -93 -7 -29 -1 -92 -10 -140 -20 -48 -11
-118 -25 -157 -32 -69 -12 -254 -68 -310 -93 -16 -8 -51 -23 -76 -35 -25 -12
-50 -21 -55 -21 -15 0 -178 -85 -229 -119 -25 -17 -49 -31 -52 -31 -5 0 -69
-42 -167 -110 -51 -35 -217 -173 -229 -191 -7 -10 -30 -31 -50 -47 -40 -32
-182 -190 -225 -250 -15 -22 -48 -68 -74 -104 -26 -36 -53 -76 -60 -89 -7 -13
-28 -45 -46 -71 -17 -26 -32 -53 -32 -60 0 -7 -7 -23 -15 -35 -45 -65 -139
-278 -150 -341 -4 -23 -11 -42 -15 -42 -5 0 -14 -26 -20 -57 -7 -32 -18 -69
-25 -83 -11 -22 -37 -150 -66 -321 -21 -128 -8 -630 20 -739 5 -19 16 -64 25
-100 39 -161 48 -196 58 -215 6 -11 17 -40 24 -65 26 -89 64 -188 94 -240 4
-8 29 -56 55 -106 43 -84 71 -128 150 -245 50 -74 145 -192 165 -206 11 -8 20
-20 20 -28 0 -11 213 -219 273 -267 12 -9 53 -42 91 -72 38 -30 81 -60 95 -68
14 -7 62 -37 106 -67 79 -53 227 -131 250 -131 7 0 24 -9 38 -20 14 -11 31
-20 39 -20 8 0 31 -9 53 -20 22 -11 45 -20 53 -20 8 0 28 -7 45 -15 35 -16
106 -37 212 -61 39 -8 90 -22 115 -29 25 -7 79 -16 120 -19 41 -3 135 -14 209
-23 115 -14 150 -14 245 -4 61 7 131 14 156 16 108 8 217 23 235 32 11 6 47
14 80 17 87 10 230 53 308 92 37 19 74 34 80 34 7 0 37 13 68 29 30 16 66 32
80 36 22 7 121 62 243 136 26 16 74 50 105 75 31 24 66 52 79 62 120 88 366
335 432 432 13 19 30 39 37 43 7 4 13 14 13 22 0 7 9 24 20 37 92 110 232 366
279 513 13 39 31 88 42 110 10 22 19 47 19 56 0 9 9 42 20 75 62 180 96 483
86 768 -6 183 -20 280 -63 446 -43 168 -50 195 -61 220 -6 14 -20 57 -32 95
-23 71 -56 143 -126 273 -57 106 -65 120 -119 201 -28 41 -54 81 -60 90 -18
28 -129 165 -175 216 -110 121 -397 375 -424 375 -5 0 -27 15 -50 33 -23 18
-52 38 -66 45 -14 6 -53 30 -87 51 -35 22 -102 56 -150 76 -90 38 -128 54
-185 79 -115 51 -279 96 -426 116 -41 6 -81 14 -90 19 -37 19 -456 34 -537 19z
m450 -304 c148 -19 224 -33 246 -44 10 -6 36 -10 59 -10 22 0 51 -6 63 -14 12
-8 38 -17 57 -21 19 -4 45 -13 57 -21 12 -8 27 -14 33 -14 9 0 137 -58 250
-113 24 -12 71 -40 103 -62 32 -22 87 -58 122 -80 35 -22 88 -60 117 -84 104
-88 325 -320 372 -390 25 -39 50 -71 55 -71 5 0 14 -12 20 -27 6 -16 16 -37
23 -47 63 -97 117 -201 173 -333 29 -67 105 -314 116 -377 6 -34 18 -83 27
-111 25 -74 25 -594 0 -675 -9 -30 -19 -78 -22 -106 -4 -47 -46 -188 -101
-344 -32 -89 -34 -93 -44 -110 -5 -8 -21 -42 -37 -75 -15 -33 -31 -62 -35 -65
-3 -3 -21 -34 -40 -70 -18 -36 -49 -87 -68 -115 -19 -27 -45 -65 -57 -82 -99
-146 -397 -435 -510 -494 -21 -12 -48 -29 -59 -39 -21 -20 -118 -75 -200 -114
-145 -70 -253 -116 -271 -116 -11 0 -29 -7 -41 -15 -12 -9 -41 -19 -65 -24
-24 -5 -77 -16 -118 -25 -261 -55 -564 -72 -760 -41 -213 33 -378 68 -423 91
-16 8 -36 14 -45 14 -8 0 -36 9 -61 21 -25 11 -71 32 -101 46 -114 51 -217
108 -300 163 -127 85 -164 110 -170 119 -3 4 -32 29 -65 55 -89 71 -269 264
-328 352 -15 22 -35 49 -45 60 -18 19 -96 152 -135 229 -11 22 -24 47 -29 55
-4 8 -13 26 -19 40 -6 14 -17 36 -24 50 -7 14 -18 42 -25 63 -7 22 -18 51 -26
65 -8 15 -14 33 -14 41 0 18 -37 142 -57 191 -7 19 -17 69 -22 111 -5 41 -14
86 -21 100 -21 38 -19 548 2 609 9 25 19 77 22 115 4 39 14 80 22 92 7 12 14
35 14 50 0 15 9 46 18 68 10 22 28 74 41 115 22 72 54 152 88 215 74 139 161
281 203 333 27 34 50 65 50 70 0 11 118 132 129 132 5 0 13 9 16 20 8 25 217
207 305 265 36 24 91 62 123 84 31 23 60 41 63 41 3 0 46 20 97 44 121 58 187
86 202 86 7 0 18 6 24 14 7 8 31 18 54 21 23 4 51 14 62 21 11 8 37 14 58 14
21 0 48 5 59 11 24 13 91 25 251 43 65 8 120 16 122 18 9 9 315 -4 420 -18z"/>
                    <path d="M2574 4466 c-22 -11 -60 -36 -83 -55 -48 -38 -200 -215 -221 -258 -8
-15 -27 -43 -42 -61 -16 -18 -28 -38 -28 -45 0 -7 -26 -57 -58 -112 -32 -55
-64 -116 -72 -135 -7 -19 -19 -42 -26 -50 -7 -8 -15 -27 -19 -42 -4 -15 -13
-32 -21 -39 -8 -6 -14 -18 -14 -26 0 -8 -17 -45 -39 -81 -21 -37 -44 -85 -51
-107 -7 -22 -26 -67 -41 -101 -16 -34 -29 -64 -29 -69 0 -4 -16 -42 -36 -84
-20 -42 -44 -95 -55 -117 -11 -24 -16 -50 -12 -60 10 -29 388 -402 458 -453 6
-4 53 -45 105 -92 121 -107 151 -132 245 -199 43 -30 94 -69 114 -86 20 -17
68 -52 106 -77 39 -25 87 -58 107 -73 20 -16 80 -56 133 -89 52 -33 128 -84
167 -112 39 -29 76 -53 82 -53 6 0 37 -18 69 -40 31 -22 59 -40 62 -40 3 0 31
-18 63 -39 32 -22 69 -45 82 -51 14 -6 43 -21 65 -35 22 -13 52 -29 68 -36 15
-6 27 -14 27 -18 0 -5 33 -22 73 -40 39 -18 90 -40 112 -50 133 -61 166 -65
214 -25 52 44 66 152 36 289 -9 39 -18 86 -21 105 -3 19 -14 56 -25 82 -10 26
-19 56 -19 68 0 11 -6 31 -14 43 -8 12 -17 38 -21 57 -9 44 -61 202 -74 227
-5 10 -19 47 -32 83 -12 36 -26 70 -31 76 -8 11 -43 107 -55 149 -3 11 -16 44
-29 73 -13 29 -24 57 -24 62 0 5 -8 24 -19 42 -10 18 -29 60 -41 93 -13 33
-29 74 -35 90 -7 17 -25 61 -40 100 -15 38 -36 86 -46 105 -11 19 -19 42 -19
51 0 9 -6 22 -14 28 -8 7 -17 24 -20 39 -4 15 -14 43 -23 62 -9 19 -24 53 -34
75 -65 147 -235 493 -252 514 -15 18 -33 49 -55 96 -11 22 -30 54 -43 70 -14
17 -30 42 -38 56 -53 105 -206 264 -303 314 -61 32 -153 33 -214 1z"/>
                    <path d="M1657 2862 c-15 -15 -27 -37 -27 -48 0 -11 -7 -29 -15 -40 -15 -23
-51 -114 -92 -234 -14 -41 -34 -91 -44 -110 -11 -19 -19 -39 -19 -44 0 -5 -16
-50 -37 -100 -20 -50 -40 -104 -44 -121 -7 -30 -15 -54 -49 -150 -51 -144 -90
-318 -95 -426 -3 -64 0 -85 20 -127 13 -28 32 -55 44 -61 27 -15 81 -13 111 4
14 8 33 14 42 15 19 0 194 84 263 126 22 13 51 29 65 36 14 6 32 17 40 24 8 6
40 24 70 40 51 27 168 100 232 145 30 21 213 143 305 202 158 103 158 105 53
193 -41 35 -79 63 -84 63 -4 1 -34 23 -65 49 -31 26 -72 59 -91 74 -19 14 -51
41 -71 59 -20 19 -74 68 -120 109 -144 129 -269 253 -306 303 -19 26 -40 47
-47 47 -7 0 -24 -13 -39 -28z"/>
                </g>
            </svg>
            <div class="amigo-footer-left">${msg("amigo.copyright", .now?string("yyyy"))}</div>
        </div>

        <!-- RIGHT PANEL -->
        <div class="amigo-right">
            <#if realm.internationalizationEnabled && locale.supported?size gt 1>
                <nav class="amigo-language-switcher" aria-label="${msg("amigo.language")}">
                    <#list locale.supported as l>
                        <a href="${l.url}"
                           class="amigo-language-link<#if l.label == locale.current> is-active</#if>"
                           <#if l.label == locale.current>aria-current="page"</#if>>${l.label}</a>
                    </#list>
                </nav>
            </#if>
            <div class="amigo-form-card">
                <h2 class="amigo-welcome">${msg("amigo.welcome")}</h2>
                <p class="amigo-welcome-sub">${msg("amigo.welcomeSubtitle")}</p>

                <#if message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
                    <div class="amigo-alert amigo-alert-${message.type}" role="alert">
                        <span>${kcSanitize(message.summary)?no_esc}</span>
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
                               aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"/>
                        <#if messagesPerField.existsError('username','password')>
                            <span class="amigo-field-error">${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}</span>
                        </#if>
                    </div>

                    <div class="amigo-field">
                        <label for="password" class="amigo-label">${msg("password")}</label>
                        <input tabindex="2" id="password" class="amigo-input" name="password"
                               type="password" autocomplete="current-password"
                               placeholder="${msg("amigo.passwordPlaceholder")}"
                               aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"/>
                    </div>

                    <#if realm.rememberMe && !usernameHidden??>
                        <div class="amigo-remember-row">
                            <label class="amigo-checkbox">
                                <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox" <#if login.rememberMe??>checked</#if>>
                                <span>${msg("rememberMe")}</span>
                            </label>
                            <#if realm.resetPasswordAllowed>
                                <a tabindex="4" href="${url.loginResetCredentialsUrl}" class="amigo-link">${msg("doForgotPassword")}</a>
                            </#if>
                        </div>
                    <#elseif realm.resetPasswordAllowed>
                        <div class="amigo-remember-row amigo-remember-row-end">
                            <a tabindex="4" href="${url.loginResetCredentialsUrl}" class="amigo-link">${msg("doForgotPassword")}</a>
                        </div>
                    </#if>

                    <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth?has_content && auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                    <button tabindex="5" class="amigo-submit" name="login" id="kc-login" type="submit">${msg("doLogIn")}</button>
                </form>

                <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
                    <p class="amigo-signup-row">
                        ${msg("noAccount")}
                        <a tabindex="6" href="${url.registrationUrl}" class="amigo-link">${msg("doRegister")}</a>
                    </p>
                </#if>
            </div>
        </div>

    </div>
</body>
</html>
