<#assign amigoCommon = url.resourcesPath + "/../../common/amigo">
<!DOCTYPE html>
<html lang="${(locale.currentLanguageTag)!'vi'}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${msg("amigo.loginTitle")} | ${(realm.displayNameHtml!realm.displayName)!"Amigo"}</title>
    <link rel="icon" href="${amigoCommon}/img/amigo-mark.png" type="image/png">
    <link rel="stylesheet" href="${amigoCommon}/css/brand.css?v=20260925-01">
    <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css?v=20260925-01">
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

            <div class="amigo-form-wrap">
                <div class="amigo-form-card">
                    <div class="amigo-form-head">
                        <span class="amigo-form-rule" aria-hidden="true"></span>
                        <h2 class="amigo-welcome">${msg("amigo.welcome")}</h2>
                        <p class="amigo-welcome-sub">${msg("amigo.welcomeSubtitle")}</p>
                    </div>

                    <#if message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
                        <div class="amigo-alert amigo-alert-${message.type}" role="alert">
                            <span class="amigo-alert-icon" aria-hidden="true">
                                <#if message.type == 'success'>
                                    <svg viewBox="0 0 20 20" fill="currentColor" width="16" height="16"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
                                <#else>
                                    <svg viewBox="0 0 20 20" fill="currentColor" width="16" height="16"><path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/></svg>
                                </#if>
                            </span>
                            <span class="amigo-alert-copy">${kcSanitize(message.summary)?no_esc}</span>
                        </div>
                    </#if>

                    <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">
                        <#assign currentRealmName = (realm.name)!''>
                        <#if currentRealmName == "momo-demo">
                            <#assign defaultDest = "momo">
                        <#elseif currentRealmName == "vnpay-demo">
                            <#assign defaultDest = "vnpay">
                        <#else>
                            <#assign defaultDest = "ipay">
                        </#if>

                        <#-- Khi login lỗi, Keycloak trả về username dạng "user@momo" -> phát hiện destination từ đó -->
                        <#assign savedUsername = (login.username!'')>
                        <#if savedUsername?contains("@") && !savedUsername?contains(".")>
                            <#assign detectedDest = savedUsername?keep_after_last("@")?lower_case>
                            <#if detectedDest == "momo" || detectedDest == "vnpay" || detectedDest == "ipay">
                                <#assign defaultDest = detectedDest>
                            </#if>
                        </#if>

                        <div class="amigo-dest">
                            <label class="amigo-dest-legend" id="destination-label">${msg("amigo.destinationLabel")!"Đích đến xác thực"}</label>
                            <input type="hidden" id="destination" name="destination" value="${defaultDest}">
                            
                            <div class="amigo-dropdown" id="destination-dropdown">
                                <button type="button" class="amigo-dropdown-trigger" id="destination-trigger" aria-haspopup="listbox" aria-expanded="false" aria-labelledby="destination-label destination-trigger">
                                    <div class="amigo-dropdown-selected" id="dropdown-selected-content">
                                        <#if defaultDest == "momo">
                                            <img class="amigo-dest-logo" src="${url.resourcesPath}/img/momo-logo.png" alt="MoMo" aria-hidden="true">
                                            <span class="amigo-dest-copy">
                                                <span class="amigo-dest-name">${msg("amigo.destinationMomoName")!"Ví MoMo"}</span>
                                                <span class="amigo-dest-meta">${msg("amigo.destinationMomoMeta")!"Ví điện tử · Thanh toán di động"}</span>
                                            </span>
                                        <#elseif defaultDest == "vnpay">
                                            <img class="amigo-dest-logo" src="${url.resourcesPath}/img/vnpay-logo.png" alt="VNPAY" aria-hidden="true">
                                            <span class="amigo-dest-copy">
                                                <span class="amigo-dest-name">${msg("amigo.destinationVnpayName")!"VNPAY"}</span>
                                                <span class="amigo-dest-meta">${msg("amigo.destinationVnpayMeta")!"Cổng thanh toán · Thẻ & QR"}</span>
                                            </span>
                                        <#else>
                                            <img class="amigo-dest-logo" src="${url.resourcesPath}/img/vietinbank-logo.png" alt="iPay VietinBank" aria-hidden="true">
                                            <span class="amigo-dest-copy">
                                                <span class="amigo-dest-name">${msg("amigo.destinationIpayName")!"iPay Core Bank"}</span>
                                                <span class="amigo-dest-meta">${msg("amigo.destinationIpayMeta")!"VietinBank · Tài khoản ngân hàng"}</span>
                                            </span>
                                        </#if>
                                    </div>
                                    <span class="amigo-dropdown-arrow" aria-hidden="true">
                                        <svg viewBox="0 0 20 20" fill="currentColor" width="18" height="18"><path fill-rule="evenodd" d="M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z" clip-rule="evenodd"/></svg>
                                    </span>
                                </button>

                                <div class="amigo-dropdown-menu" id="destination-menu" role="listbox" aria-labelledby="destination-label">
                                    <button type="button" class="amigo-dropdown-item<#if defaultDest == 'ipay'> is-selected</#if>" data-dest="ipay" role="option" aria-selected="<#if defaultDest == 'ipay'>true<#else>false</#if>" tabindex="-1">
                                        <img class="amigo-dest-logo" src="${url.resourcesPath}/img/vietinbank-logo.png" alt="iPay VietinBank" aria-hidden="true">
                                        <span class="amigo-dest-copy">
                                            <span class="amigo-dest-name">${msg("amigo.destinationIpayName")!"iPay Core Bank"}</span>
                                            <span class="amigo-dest-meta">${msg("amigo.destinationIpayMeta")!"VietinBank · Tài khoản ngân hàng"}</span>
                                        </span>
                                        <svg class="amigo-dest-check" viewBox="0 0 20 20" fill="currentColor" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
                                    </button>

                                    <button type="button" class="amigo-dropdown-item<#if defaultDest == 'momo'> is-selected</#if>" data-dest="momo" role="option" aria-selected="<#if defaultDest == 'momo'>true<#else>false</#if>" tabindex="-1">
                                        <img class="amigo-dest-logo" src="${url.resourcesPath}/img/momo-logo.png" alt="MoMo" aria-hidden="true">
                                        <span class="amigo-dest-copy">
                                            <span class="amigo-dest-name">${msg("amigo.destinationMomoName")!"Ví MoMo"}</span>
                                            <span class="amigo-dest-meta">${msg("amigo.destinationMomoMeta")!"Ví điện tử · Thanh toán di động"}</span>
                                        </span>
                                        <svg class="amigo-dest-check" viewBox="0 0 20 20" fill="currentColor" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
                                    </button>

                                    <button type="button" class="amigo-dropdown-item<#if defaultDest == 'vnpay'> is-selected</#if>" data-dest="vnpay" role="option" aria-selected="<#if defaultDest == 'vnpay'>true<#else>false</#if>" tabindex="-1">
                                        <img class="amigo-dest-logo" src="${url.resourcesPath}/img/vnpay-logo.png" alt="VNPAY" aria-hidden="true">
                                        <span class="amigo-dest-copy">
                                            <span class="amigo-dest-name">${msg("amigo.destinationVnpayName")!"VNPAY"}</span>
                                            <span class="amigo-dest-meta">${msg("amigo.destinationVnpayMeta")!"Cổng thanh toán · Thẻ & QR"}</span>
                                        </span>
                                        <svg class="amigo-dest-check" viewBox="0 0 20 20" fill="currentColor" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <div class="amigo-field">
                            <label for="username" class="amigo-label">
                                <#if !realm.loginWithEmailAllowed>${msg("username")}
                                <#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}
                                <#else>${msg("email")}</#if>
                            </label>
                            <div class="amigo-input-group">
                                <span class="amigo-input-icon" aria-hidden="true">
                                    <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" width="18" height="18"><path d="M16 17v-1.5a3.5 3.5 0 0 0-3.5-3.5h-5A3.5 3.5 0 0 0 4 15.5V17"/><circle cx="10" cy="7" r="3.5"/></svg>
                                </span>
                                <#assign cleanInitialUsername = (login.username!'')>
                                <#if cleanInitialUsername?contains("@") && !cleanInitialUsername?contains(".")>
                                    <#assign cleanInitialUsername = cleanInitialUsername?keep_before("@")>
                                </#if>
                                <input tabindex="1" id="username" class="amigo-input has-icon" name="username" value="${cleanInitialUsername}"
                                       type="text" autofocus autocomplete="username"
                                       placeholder="${msg("amigo.usernamePlaceholder")}"
                                       aria-invalid="<#if messagesPerField.existsError('username','password')>true<#else>false</#if>"/>
                            </div>
                            <#if messagesPerField.existsError('username','password') && !(message?has_content)>
                                <span class="amigo-field-error">${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}</span>
                            </#if>
                        </div>

                        <div class="amigo-field">
                            <label for="password" class="amigo-label">${msg("password")}</label>
                            <div class="amigo-input-group">
                                <span class="amigo-input-icon" aria-hidden="true">
                                    <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" width="18" height="18"><rect x="4" y="9" width="12" height="9" rx="2"/><path d="M7 9V6a3 3 0 0 1 6 0v3"/></svg>
                                </span>
                                <input tabindex="2" id="password" class="amigo-input has-icon has-toggle" name="password"
                                       type="password" autocomplete="current-password"
                                       placeholder="${msg("amigo.passwordPlaceholder")}"
                                       aria-invalid="<#if messagesPerField.existsError('username','password')>true<#else>false</#if>"/>
                                <button type="button" class="amigo-password-toggle" id="toggle-password-btn" aria-label="${msg("amigo.showPassword")!"Hiện mật khẩu"}" tabindex="-1">
                                    <svg class="icon-eye" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="18" height="18" aria-hidden="true"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                    <svg class="icon-eye-off" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="18" height="18" aria-hidden="true" style="display:none;"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
                                </button>
                            </div>
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

                    <div class="amigo-trust-banner">
                        <svg class="amigo-trust-icon" viewBox="0 0 20 20" fill="currentColor" width="16" height="16" aria-hidden="true">
                            <path fill-rule="evenodd" d="M2.166 4.999A11.954 11.954 0 0010 1.944 11.954 11.954 0 0017.834 5c.11.65.166 1.32.166 2.001 0 5.225-3.34 9.67-8 11.317C5.34 16.67 2 12.225 2 7c0-.682.057-1.35.166-2.001zm11.541 3.708a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                        </svg>
                        <div class="amigo-trust-text">
                            <strong>${msg("amigo.securityTitle")!"Bảo mật cấp doanh nghiệp"}</strong>
                            <span>${msg("amigo.securityDesc")!"Mã hóa SSL 256-bit chuẩn quốc tế & xác thực tập trung"}</span>
                        </div>
                    </div>

                    <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
                        <p class="amigo-signup">
                            ${msg("noAccount")}
                            <a tabindex="6" href="${url.registrationUrl}" class="amigo-link">${msg("doRegister")}</a>
                        </p>
                    </#if>
                </div>

                <div class="amigo-support-bar">
                    <svg class="amigo-support-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="15" height="15" aria-hidden="true">
                        <circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/>
                    </svg>
                    <span>${msg("amigo.needHelp")!"Gặp sự cố khi đăng nhập?"}</span>
                    <a href="mailto:support@amigo.vn" class="amigo-support-link">${msg("amigo.contactSupport")!"Liên hệ IT Helpdesk"}</a>
                </div>

                <footer class="amigo-footer-links">
                    <a href="#" class="amigo-footer-link">${msg("amigo.terms")!"Điều khoản dịch vụ"}</a>
                    <span class="amigo-footer-dot">•</span>
                    <a href="#" class="amigo-footer-link">${msg("amigo.privacy")!"Chính sách bảo mật"}</a>
                    <span class="amigo-footer-dot">•</span>
                    <span class="amigo-footer-meta">Amigo SSO IAM</span>
                </footer>
            </div>
        </main>
    </div>

    <script>
        (function() {
            var form = document.getElementById('kc-form-login');
            var destInput = document.getElementById('destination');
            var usernameInput = document.getElementById('username');

            // Dropdown controls
            var dropdown = document.getElementById('destination-dropdown');
            var trigger = document.getElementById('destination-trigger');
            var menu = document.getElementById('destination-menu');
            var selectedContent = document.getElementById('dropdown-selected-content');
            var items = Array.prototype.slice.call(document.querySelectorAll('.amigo-dropdown-item'));

            function toggleDropdown(open) {
                if (!dropdown) return;
                var isOpen = typeof open === 'boolean' ? open : !dropdown.classList.contains('is-open');
                dropdown.classList.toggle('is-open', isOpen);
                if (trigger) {
                    trigger.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
                }
            }

            function selectDestination(item, closeMenu) {
                if (!item) return;
                items.forEach(function(el) {
                    el.classList.remove('is-selected');
                    el.setAttribute('aria-selected', 'false');
                });
                item.classList.add('is-selected');
                item.setAttribute('aria-selected', 'true');

                var dest = item.getAttribute('data-dest');
                if (destInput) destInput.value = dest;

                // Cập nhật hiển thị lên trigger box
                var copyNode = item.querySelector('.amigo-dest-copy');
                var logoNode = item.querySelector('.amigo-dest-logo');
                if (selectedContent && copyNode && logoNode) {
                    selectedContent.innerHTML = '';
                    selectedContent.appendChild(logoNode.cloneNode(true));
                    selectedContent.appendChild(copyNode.cloneNode(true));
                }

                if (closeMenu) {
                    toggleDropdown(false);
                    if (trigger) trigger.focus();
                }
            }

            if (trigger) {
                trigger.addEventListener('click', function(e) {
                    e.stopPropagation();
                    toggleDropdown();
                });
            }

            items.forEach(function(item) {
                item.addEventListener('click', function(e) {
                    e.stopPropagation();
                    selectDestination(item, true);
                });
            });

            // Click outside to close
            document.addEventListener('click', function(e) {
                if (dropdown && !dropdown.contains(e.target)) {
                    toggleDropdown(false);
                }
            });

            // Escape key to close
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape' && dropdown && dropdown.classList.contains('is-open')) {
                    toggleDropdown(false);
                    if (trigger) trigger.focus();
                }
            });

            if (form && destInput && usernameInput) {
                form.addEventListener('submit', function() {
                    var dest = destInput.value || 'ipay';
                    var rawUser = usernameInput.value.trim();
                    // Gắn @destination vào username để SPI biết route đến đúng backend tương ứng
                    if (rawUser && rawUser.indexOf('@') === -1 && rawUser.indexOf(':') === -1) {
                        usernameInput.value = rawUser + '@' + dest;
                    }
                });
            }

            var toggleBtn = document.getElementById('toggle-password-btn');
            var passwordInput = document.getElementById('password');
            if (toggleBtn && passwordInput) {
                var eyeIcon = toggleBtn.querySelector('.icon-eye');
                var eyeOffIcon = toggleBtn.querySelector('.icon-eye-off');
                toggleBtn.addEventListener('click', function(e) {
                    e.preventDefault();
                    var isPassword = passwordInput.getAttribute('type') === 'password';
                    if (isPassword) {
                        passwordInput.setAttribute('type', 'text');
                        if (eyeIcon) eyeIcon.style.display = 'none';
                        if (eyeOffIcon) eyeOffIcon.style.display = 'block';
                        toggleBtn.setAttribute('aria-label', '${msg("amigo.hidePassword")!"Ẩn mật khẩu"}');
                    } else {
                        passwordInput.setAttribute('type', 'password');
                        if (eyeIcon) eyeIcon.style.display = 'block';
                        if (eyeOffIcon) eyeOffIcon.style.display = 'none';
                        toggleBtn.setAttribute('aria-label', '${msg("amigo.showPassword")!"Hiện mật khẩu"}');
                    }
                    passwordInput.focus();
                });
            }
        })();
    </script>
</body>
</html>
