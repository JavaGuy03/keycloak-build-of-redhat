# Amigo RHBK custom image

Optimized Red Hat build of Keycloak 26.6 image containing:

- Remote User Storage SPI and custom Browser authenticator.
- Base VN/EN message theme `amigo-base` packaged in the provider JAR.
- Branded login/account theme `amigo`, with login inheriting `amigo-base`.
- Health and metrics support enabled at image build time.

## Prerequisites

- Java 17 and Maven available on `PATH`.
- Docker authenticated to `registry.redhat.io`.
- Access to the Red Hat GA Maven repository.
- Access to the target Quay/Harbor registry.

## Build

Run from this directory:

```powershell
Push-Location ..\keycloak-custom-provider
mvn clean verify
Pop-Location

Copy-Item `
  ..\keycloak-custom-provider\target\keycloak-custom-provider-1.0-SNAPSHOT.jar `
  .\providers\keycloak-custom-provider.jar `
  -Force

docker build --pull `
  -t quay.ocp.lab.local/dinhhb/keycloak-custom:1.0.0 `
  .
docker push quay.ocp.lab.local/dinhhb/keycloak-custom:1.0.0
```

The Maven command runs provider tests and packages the JAR. Always copy the newly built JAR into `providers` before building the image so a stale provider is not included.

Use immutable release tags. For stricter reproducibility, pass an RHBK image pinned by digest:

```powershell
docker build --build-arg RHBK_IMAGE=registry.redhat.io/rhbk/keycloak-rhel9@sha256:<digest> -t <target-image> .
```

## Local run

Set infrastructure-only values in the current shell. These are not SPI settings:

```powershell
$env:KC_DB_PASSWORD="<local-db-password>"
$env:KEYCLOAK_ADMIN_PASSWORD="<local-admin-password>"
$env:KEYCLOAK_IMAGE="keycloak-custom:dev"

docker build --pull -t keycloak-custom:dev .
docker compose up -d
```

Local Compose does not require a `.env` file. Provider URLs, API key, cache, timeout and protection settings are managed only in User Federation.

Start this Compose project first so it creates `keycloak-build-of-redhat_kc-net`, then start `authenticate-spring-demo`. Local host ports are Keycloak `8085` and mock API `8888`; container-to-container SPI calls use the mock service name on the shared network.

The compose file is for development only. Production deployment uses the RHBK Operator template in [openshift/keycloak.example.yaml](openshift/keycloak.example.yaml).

## Before production

- Revoke the old internal API key at the identity API, generate a new value and enter it in the User Federation provider settings. The value is stored in the Keycloak database, so restrict access to Keycloak administration, database storage and backups.
- Rotate the Redis password that previously appeared in repository history at the real Redis service, update every consuming application's Secret and restart those workloads. This SPI does not connect to Redis; that credential belongs to the mock/backend environment.
- Removing a value from the current files or rewriting Git history does not invalidate it. Rotation at the issuing service is mandatory; history cleanup is only a secondary containment step.
- Do not place the SPI API key in `.env`, Realm exports, manifests or build arguments. Manage it through the restricted User Federation administration workflow.

## Provider settings

Configure all SPI values in **Realm -> User Federation -> vietinbank-user-storage**. Runtime environment variables do not override these settings.

For local Docker, use `http://authenticate-spring-demo:8888/api/internal/verify` and `http://authenticate-spring-demo:8888/api/internal/users`, then enable `Allow insecure HTTP`. Both services must be attached to `keycloak-build-of-redhat_kc-net`.

For OpenShift, use the identity service DNS name with HTTPS, keep `Allow insecure HTTP` disabled and enter the rotated internal API key through the restricted Keycloak Admin Console. Production identity endpoints must use HTTPS because the verify payload contains the user's password.

Federated identities use the username as their external ID. The identity contract must therefore keep usernames immutable; add a user-by-immutable-ID contract before allowing username changes.

## Realm configuration

For an existing Realm:

1. Add the `vietinbank-user-storage` User Federation provider.
2. Enter both identity API URLs and the internal API key. Enable insecure HTTP only for local development.
3. Set cache policy to `MAX_LIFESPAN` and max lifespan to `300000` milliseconds.
4. Set request timeout to `3` seconds, maximum concurrent requests to `64`, circuit-breaker threshold to `5` and open time to `10` seconds. Tune these values in User Federation for each environment.
5. Enable the provider only after all required settings have been saved successfully. The sample Realm leaves it disabled intentionally.
6. On each downstream client that needs application roles, add a multivalued `User Attribute` mapper from `external_roles` to the access-token claim `external_roles`. The sample Realm already configures this for `vietinbank-client`.
7. Select login theme `amigo`, enable Internationalization, add supported locales `vi` and `en`, then choose the default locale.

The login page uses Keycloak message bundles and includes a locale selector. OIDC clients may preselect the language with `ui_locales=vi` or `ui_locales=en`; browser-flow errors from the custom authenticator are rendered in that same locale. The account theme is packaged separately and can be selected as `amigo`, but this change only localizes the login experience; account-page message coverage should be completed as a separate step.

Theme files and provider bundles are baked into the image. After changing either one, rebuild and recreate the local Keycloak container with `docker compose -f docker-compose.yaml up -d --build --force-recreate keycloak`. The login stylesheet has a versioned URL so browsers fetch the updated CSS after deployment.

The login brand panel uses `amigo/common/resources/img/amigo-identity-scene.png`, generated from the Amigo mark shape. Shared brand images, Inter fonts and `brand.css` live in `amigo/common/resources`; keep that folder with the theme when building the image. The form area remains plain for contrast and readability.
8. Copy the built-in Browser Flow, replace the username/password form with `Remote Username Password Form`, then bind the copied flow.

Realm import is create-only. Rebuilding the image does not update a Realm that already exists in PostgreSQL, so apply new provider settings, protocol mappers and authentication-flow changes through the Admin Console, `kcadm.sh` or a controlled Realm migration.

The cache TTL is the maximum accepted staleness for profile, external-role and enabled-state data. Password validation always reaches the identity API.
Evict the Keycloak user cache when an external-role or account-state change must take effect before the TTL expires. External roles are signed into the JWT as metadata; downstream applications own authorization and no matching Realm Roles are required.

The backend contract must return `4001` for invalid credentials, `4002` for a disabled account, `4003` for a temporarily locked account, `5000+` for service failures and `9001` for a rejected internal API key. Contract drift can otherwise turn a business authentication failure into a configuration or availability error.

Downstream services must validate the token signature, issuer, audience and expiry before trusting `external_roles`. Already-issued JWTs remain valid until expiry, so the worst-case authorization staleness is approximately the user-cache TTL plus the access-token lifespan.

## OpenShift

See [openshift/README.md](openshift/README.md). The directory is a deployment template, so review environment-specific image, hostname, TLS, database and service URLs before `oc apply`.
