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
            if (!sidebar || sidebar.querySelector(".amigo-account-caption")) return;
            sidebar.prepend(label("p", "accountTitle", "amigo-account-caption"));
            if (!environment.features.isInternationalizationEnabled) return;
            const settings = document.createElement("div");
            settings.className = "amigo-account-settings";
            const button = label("button", "settings", "amigo-settings-button");
            button.type = "button";
            button.setAttribute("aria-haspopup", "dialog");
            button.addEventListener("click", () => {
                opener = button;
                if (!dialog) createDialog();
                dialog.showModal();
            });
            settings.append(button);
            sidebar.append(settings);
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
            observer.observe(document.getElementById("app"), { childList: true, subtree: true });
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
