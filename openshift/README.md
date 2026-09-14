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

Federated identities use the username as their external ID. The identity contract must keep usernames immutable; introduce a user-by-immutable-ID endpoint before allowing username changes.

The sample User Storage cache lifespan is five minutes (`MAX_LIFESPAN=300000`). Change it in the Realm User Federation settings based on the accepted maximum age for external roles, enabled state and profile data. Credentials are never cached.

Backend roles are emitted as the multivalued access-token claim `external_roles`. Downstream applications validate the JWT and own authorization; matching Realm Roles do not need to be provisioned in Keycloak. Configure the mapper only on clients or Client Scopes that are allowed to receive this metadata.
