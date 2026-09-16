/* React owns authentication, profile forms and session actions. */
(() => {
    document.documentElement.classList.add("amigo-account");
    const start = async () => {
        document.body.dataset.pageId = "account";
        const element = document.getElementById("environment");
        if (!element) return;
        const environment = JSON.parse(element.textContent);
        if (!document.querySelector('link[data-amigo-favicon]')) {
            const icon = document.createElement("link");
            icon.rel = "icon";
            icon.type = "image/png";
            icon.dataset.amigoFavicon = "true";
            icon.href = `${environment.resourceUrl.replace(/\/$/, "")}/img/amigo-mark.png`;
            document.head.append(icon);
        }
        const storageKey = `amigo.account.locale.${environment.realm}`;
        const supported = ["vi", "en"];
        let language = supported.includes(environment.locale) ? environment.locale : "en";
        let messages = {};
        let dialog;
        let opener;
        let changing = false;
        const text = (key) => messages[`amigo.${key}`] || key;
        async function loadMessages(locale) {
            const base = environment.serverBaseUrl.replace(/\/$/, "");
            const response = await fetch(`${base}/resources/${encodeURIComponent(environment.realm)}/account/${locale}`, { credentials: "same-origin" });
            if (!response.ok) throw new Error("Account translations unavailable");
            return Object.fromEntries((await response.json()).map(({ key, value }) => [key, value]));
        }
        function remember(locale) {
            try { localStorage.setItem(storageKey, locale); } catch (_) { /* Storage can be disabled. */ }
        }
        function localize() {
            document.documentElement.lang = language;
            document.title = text("accountTitle");
            document.querySelectorAll("[data-amigo-message]").forEach((node) => { node.textContent = text(node.dataset.amigoMessage); });
            if (dialog) {
                dialog.querySelector("select").value = language;
                dialog.querySelector(".amigo-settings-close").setAttribute("aria-label", text("close"));
            }
        }
        function label(tag, key, className) {
            const node = document.createElement(tag);
            node.dataset.amigoMessage = key;
            node.textContent = text(key);
            if (className) node.className = className;
            return node;
        }
        const ICONS = {
            profile: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="3.25"/><path d="M5.5 19.2c.8-3.1 3.4-5.2 6.5-5.2s5.7 2.1 6.5 5.2"/></svg>',
            security: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3.5 5.5 6.2v5.1c0 4 2.8 7.6 6.5 8.7 3.7-1.1 6.5-4.7 6.5-8.7V6.2L12 3.5z"/></svg>',
            signin: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="10.5" width="14" height="9" rx="2"/><path d="M8.5 10.5V8.2a3.5 3.5 0 0 1 7 0v2.3"/></svg>',
            devices: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="5" width="16" height="11" rx="1.5"/><path d="M8 19h8M12 16v3"/></svg>',
            linked: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13.5 8.8 14.7a3 3 0 1 1-4.2-4.2l2.1-2.1a3 3 0 0 1 4.2 0"/><path d="M14 10.5 15.2 9.3a3 3 0 0 1 4.2 4.2l-2.1 2.1a3 3 0 0 1-4.2 0"/></svg>',
            apps: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="4" width="6.5" height="6.5" rx="1.2"/><rect x="13.5" y="4" width="6.5" height="6.5" rx="1.2"/><rect x="4" y="13.5" width="6.5" height="6.5" rx="1.2"/><rect x="13.5" y="13.5" width="6.5" height="6.5" rx="1.2"/></svg>',
            groups: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="8.5" r="2.4"/><circle cx="16" cy="9" r="2"/><path d="M4.8 18.5c.6-2.6 2.6-4.2 4.2-4.2 2 0 3.6 1.4 4.3 3.6"/><path d="M14.2 14.6c1.5-.2 3.2 1 3.8 3.9"/></svg>',
            orgs: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M4.5 20V7.5L12 4l7.5 3.5V20"/><path d="M9 20v-6h6v6"/></svg>',
            resources: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M4.5 8.5 12 4.5l7.5 4-7.5 4-7.5-4z"/><path d="M4.5 12.2 12 16.2l7.5-4"/><path d="M4.5 15.8 12 19.8l7.5-4"/></svg>',
            credential: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="5" width="16" height="14" rx="2"/><circle cx="9" cy="12" r="2"/><path d="M13 11h4M13 14h3"/></svg>',
            settings: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 12.9a7.7 7.7 0 0 0 0-1.8l1.7-1.3-1.6-2.8-2 .8a7.4 7.4 0 0 0-1.5-.9L15.6 4h-3.2l-.4 2.1c-.5.2-1 .5-1.5.9l-2-.8-1.6 2.8 1.7 1.3a7.7 7.7 0 0 0 0 1.8L4.9 14.2l1.6 2.8 2-.8c.5.4 1 .7 1.5.9l.4 2.1h3.2l.4-2.1c.5-.2 1-.5 1.5-.9l2 .8 1.6-2.8-1.7-1.3z"/></svg>',
            item: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><circle cx="12" cy="12" r="7.5"/></svg>'
        };
        function mark(kind) {
            const node = document.createElement("span");
            node.className = "amigo-icon";
            node.setAttribute("aria-hidden", "true");
            node.innerHTML = ICONS[kind] || ICONS.item;
            return node;
        }
        function iconKind(link) {
            const href = (link.getAttribute("href") || "").split("?")[0];
            if (href.includes("account-security/signing-in")) return "signin";
            if (href.includes("account-security/device-activity")) return "devices";
            if (href.includes("account-security/linked-accounts")) return "linked";
            if (href.includes("/applications")) return "apps";
            if (href.includes("/groups")) return "groups";
            if (href.includes("/organizations")) return "orgs";
            if (href.includes("/resources")) return "resources";
            if (href.includes("oid4vci")) return "credential";
            if (link.querySelector(".pf-v5-c-nav__toggle")) return "security";
            if (href.replace(/\/+$/, "").endsWith("/account")) return "profile";
            return "item";
        }
        function decorateNav() {
            document.querySelectorAll(".pf-v5-c-nav__link").forEach((link) => {
                if (link.querySelector(":scope > .amigo-icon")) return;
                link.insertBefore(mark(iconKind(link)), link.firstChild);
            });
        }
        function createDialog() {
            dialog = document.createElement("dialog");
            dialog.className = "amigo-settings-dialog";
            dialog.setAttribute("aria-labelledby", "amigo-settings-title");
            const heading = document.createElement("div");
            heading.className = "amigo-settings-heading";
            const title = label("h2", "settings");
            title.id = "amigo-settings-title";
            const close = document.createElement("button");
            close.type = "button";
            close.className = "amigo-settings-close";
            close.textContent = "\u00d7";
            close.setAttribute("aria-label", text("close"));
            close.addEventListener("click", () => dialog.close());
            heading.append(title, close);
            const languageLabel = label("label", "language");
            languageLabel.htmlFor = "amigo-account-language";
            const select = document.createElement("select");
            select.id = "amigo-account-language";
            select.add(new Option("Ti\u1ebfng Vi\u1ec7t", "vi"));
            select.add(new Option("English", "en"));
            select.value = language;
            const description = label("p", "languageDescription", "amigo-settings-description");
            const status = document.createElement("p");
            status.className = "amigo-settings-status";
            status.setAttribute("role", "status");
            select.addEventListener("change", async () => {
                const next = select.value;
                select.disabled = true;
                status.textContent = "";
                try {
                    messages = await loadMessages(next);
                    language = next;
                    remember(next);
                    changing = true;
                    window.dispatchEvent(new CustomEvent("languageChanged", { detail: { language: next } }));
                    changing = false;
                    localize();
                } catch (_) {
                    select.value = language;
                    status.textContent = text("languageError");
                } finally { select.disabled = false; }
            });
            dialog.append(heading, languageLabel, select, description, status);
            dialog.addEventListener("close", () => opener?.focus());
            document.body.append(dialog);
        }
        function enhance() {
            const sidebar = document.querySelector(".pf-v5-c-page__sidebar-body");
            if (sidebar && !sidebar.querySelector(".amigo-account-caption")) {
                sidebar.prepend(label("p", "accountTitle", "amigo-account-caption"));
                if (environment.features.isInternationalizationEnabled) {
                    const settings = document.createElement("div");
                    settings.className = "amigo-account-settings";
                    const button = document.createElement("button");
                    button.type = "button";
                    button.className = "amigo-settings-button";
                    button.setAttribute("aria-haspopup", "dialog");
                    button.append(mark("settings"), label("span", "settings"));
                    button.addEventListener("click", () => {
                        opener = button;
                        if (!dialog) createDialog();
                        dialog.showModal();
                    });
                    settings.append(button);
                    sidebar.append(settings);
                }
            }
            decorateNav();
        }
        try {
            let preference;
            try { preference = localStorage.getItem(storageKey); } catch (_) { /* Optional preference. */ }
            if (environment.features.isInternationalizationEnabled && supported.includes(preference)) language = preference;
            messages = await loadMessages(language);
            if (environment.features.isInternationalizationEnabled) window.dispatchEvent(new CustomEvent("languageChanged", { detail: { language } }));
            localize();
            enhance();
            let scheduled = false;
            const observer = new MutationObserver(() => {
                if (scheduled) return;
                scheduled = true;
                requestAnimationFrame(() => { scheduled = false; enhance(); });
            });
            const app = document.getElementById("app");
            if (app) observer.observe(app, { childList: true, subtree: true });
            window.addEventListener("languageChanged", async (event) => {
                const next = event.detail?.language;
                if (changing || !supported.includes(next)) return;
                try {
                    messages = await loadMessages(next);
                    language = next;
                    remember(next);
                    localize();
                } catch (_) { /* The native console owns its language state. */ }
            });
        } catch (error) { console.warn("Amigo account settings could not be loaded", error); }
    };
    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", start, { once: true });
    else start();
})();
