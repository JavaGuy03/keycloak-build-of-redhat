ARG RHBK_IMAGE=registry.redhat.io/rhbk/keycloak-rhel9:26.6
FROM ${RHBK_IMAGE} AS builder

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_DB=postgres

WORKDIR /opt/keycloak

# Provider and theme must be present before augmentation.
COPY --chown=keycloak:keycloak --chmod=644 providers/keycloak-custom-provider.jar /opt/keycloak/providers/keycloak-custom-provider.jar
COPY --chown=keycloak:keycloak amigo /opt/keycloak/themes/amigo

RUN /opt/keycloak/bin/kc.sh build

FROM ${RHBK_IMAGE}
COPY --from=builder /opt/keycloak/ /opt/keycloak/

LABEL org.opencontainers.image.title="Amigo Red Hat build of Keycloak" \
      org.opencontainers.image.description="RHBK with the Amigo remote user provider and branded theme"

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
