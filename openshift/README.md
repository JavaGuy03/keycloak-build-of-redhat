# OpenShift deployment

This directory contains a template for RHBK Operator 26.6. Replace the image, hostname, database host and identity API service URLs before applying it.

Create runtime secrets without committing their values:

```bash
oc -n ssc3 create secret generic keycloak-db \
  --from-literal=username='<db-user>' \
  --from-literal=password='<db-password>'

oc -n ssc3 create secret generic keycloak-remote-provider \
  --from-literal=internal-api-key='<new-rotated-key>'

oc -n ssc3 create secret tls keycloak-tls \
  --cert=tls.crt \
  --key=tls.key
```

Before this deployment, revoke the old identity API key and rotate any Redis password that appeared in repository history. Redis is not used by the Keycloak SPI, so rotate it in the actual Redis/mock-backend environment and update all workloads that consume it. Updating files in Git is not a substitute for invalidating the old credentials at their issuing services. After changing Secret-backed environment variables, restart the affected workloads through the approved rollout process.

Build and push the immutable custom image before applying the CR:

```powershell
.\build.ps1 -Image quay.ocp.lab.local/dinhhb/keycloak-custom:1.0.0
docker push quay.ocp.lab.local/dinhhb/keycloak-custom:1.0.0
```

Then review and apply:

```bash
oc apply --dry-run=server -f openshift/keycloak.example.yaml
oc apply -f openshift/keycloak.example.yaml
oc -n ssc3 get keycloak,pods
```

The RHBK Operator version must remain on the 26.6 channel while this image uses RHBK 26.6. Use manual OLM approval for production upgrades. Configure a pull secret on the namespace service account when the target registry is private.

`AMIGO_USER_BY_ID_API_URL` is optional. Remove it from the CR until the identity API implements `GET <base-url>/{immutable-id}`. Without it, new users continue to use username-based external IDs.

The sample User Storage cache lifespan is five minutes (`MAX_LIFESPAN=300000`). Change it in the Realm User Federation settings based on the accepted maximum age for role, enabled state and profile data. Credentials are never cached.

Provision the approved role catalog before assigning those roles in the identity source. Copy `roles.example.txt` to an environment-owned file, replace the examples, then run:

```powershell
$env:KEYCLOAK_ADMIN_USERNAME = '<temporary-admin>'
$env:KEYCLOAK_ADMIN_PASSWORD = '<read-from-secret-manager>'
.\openshift\provision-realm-roles.ps1 `
  -KeycloakUrl https://keycloak.apps.example.com `
  -Realm vietinbank-demo `
  -RolesFile C:\secure-config\realm-roles.txt
Remove-Item Env:KEYCLOAK_ADMIN_PASSWORD
```

The script is idempotent and creates only missing roles. Do not use the example role names as a production authorization catalog without approval from the owning application teams.
