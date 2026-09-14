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
  .\providers\keycloak-custom-provider-1.0-SNAPSHOT.jar `
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

Create a local `.env` from `.env.example`, set non-production values, then:

```powershell
docker build --pull -t keycloak-custom:dev .
docker compose up -d
```

The compose file is for development only. Production deployment uses the RHBK Operator template in [openshift/keycloak.example.yaml](openshift/keycloak.example.yaml).

## Before production

- Revoke the old internal API key at the identity API, generate a new value and update the `keycloak-remote-provider` OpenShift Secret. Restart the Keycloak Pods through the approved Operator rollout so the new environment value is loaded.
- Rotate the Redis password that previously appeared in repository history at the real Redis service, update every consuming application's Secret and restart those workloads. This SPI does not connect to Redis; that credential belongs to the mock/backend environment.
- Removing a value from the current files or rewriting Git history does not invalidate it. Rotation at the issuing service is mandatory; history cleanup is only a secondary containment step.
- Keep production values in the platform secret manager, not in `.env`, Realm exports, manifests or build arguments.

## Provider settings

Inject these variables into the Keycloak container:

| Variable | Required | Description |
|---|---|---|
| `AMIGO_VERIFY_API_URL` | yes | POST credential verification endpoint |
| `AMIGO_USER_API_URL` | yes | GET user-by-username base URL |
| `AMIGO_INTERNAL_API_KEY` | yes | Rotated internal API key |

Production identity endpoints must use HTTPS because the verify payload contains the user's password. Plain HTTP is disabled by default; local Compose explicitly opts in with `AMIGO_ALLOW_INSECURE_HTTP=true`.

Federated identities use the username as their external ID. The identity contract must therefore keep usernames immutable; add a user-by-immutable-ID contract before allowing username changes.

## Realm configuration

For an existing Realm:

1. Add the `vietinbank-user-storage` User Federation provider.
2. Set cache policy to `MAX_LIFESPAN` and max lifespan to `300000` milliseconds.
3. On each downstream client that needs application roles, add a multivalued `User Attribute` mapper from `external_roles` to the access-token claim `external_roles`. The sample Realm already configures this for `vietinbank-client`.
4. Select login theme `amigo` and enable locales `vi` and `en`.
5. Copy the built-in Browser Flow, replace the username/password form with `Remote Username Password Form`, then bind the copied flow.

The cache TTL is the maximum accepted staleness for profile, external-role and enabled-state data. Password validation always reaches the identity API.
Evict the Keycloak user cache when an external-role or account-state change must take effect before the TTL expires. External roles are signed into the JWT as metadata; downstream applications own authorization and no matching Realm Roles are required.

Downstream services must validate the token signature, issuer, audience and expiry before trusting `external_roles`. Already-issued JWTs remain valid until expiry, so the worst-case authorization staleness is approximately the user-cache TTL plus the access-token lifespan.

## OpenShift

See [openshift/README.md](openshift/README.md). The directory is a deployment template, so review environment-specific image, hostname, TLS, database and service URLs before `oc apply`.
