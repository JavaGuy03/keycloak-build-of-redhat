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
.\build.ps1 -Image quay.ocp.lab.local/dinhhb/keycloak-custom:1.0.0
docker push quay.ocp.lab.local/dinhhb/keycloak-custom:1.0.0
```

The script runs provider tests, packages the JAR, copies it to `providers/keycloak-custom-provider.jar`, verifies its SHA-256 checksum and then builds the image. Dockerfile deliberately ignores the old snapshot-named JARs, preventing a stale provider from entering the image.

Use immutable release tags. For stricter reproducibility, pass an RHBK image pinned by digest:

```powershell
docker build --build-arg RHBK_IMAGE=registry.redhat.io/rhbk/keycloak-rhel9@sha256:<digest> -t <target-image> .
```

## Local run

Create a local `.env` from `.env.example`, set non-production values, then:

```powershell
.\build.ps1 -Image keycloak-custom:dev
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
| `AMIGO_USER_BY_ID_API_URL` | no | GET user-by-immutable-ID base URL |
| `AMIGO_INTERNAL_API_KEY` | yes | Rotated internal API key |

Production identity endpoints must use HTTPS because the verify payload contains the user's password. Plain HTTP is disabled by default; local Compose explicitly opts in with `AMIGO_ALLOW_INSECURE_HTTP=true`.

When the ID endpoint is configured, new federated identities use the immutable backend ID. Keep that endpoint available beyond the five-minute user cache TTL and across Pod restarts.

## Realm configuration

For an existing Realm:

1. Add the `vietinbank-user-storage` User Federation provider.
2. Set cache policy to `MAX_LIFESPAN` and max lifespan to `300000` milliseconds.
3. Provision all approved Realm Roles before assigning them in the source system.
4. Select login theme `amigo` and enable locales `vi` and `en`.
5. Copy the built-in Browser Flow, replace the username/password form with `Remote Username Password Form`, then bind the copied flow.

The cache TTL is the maximum accepted staleness for profile, role and enabled-state data. Password validation always reaches the identity API.
Evict the Keycloak user cache when a role or account-state change must take effect before the TTL expires.

## OpenShift

See [openshift/README.md](openshift/README.md). The directory is a deployment template, so review environment-specific image, hostname, TLS, database and service URLs before `oc apply`.
