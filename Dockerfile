FROM registry.redhat.io/rhbk/keycloak-rhel9:26.6 AS builder

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_DB=postgres

WORKDIR /opt/keycloak

# Copy SPI providers
COPY providers/*.jar /opt/keycloak/providers/

# Bổ sung: Copy Theme vào trong Image
COPY amigo /opt/keycloak/themes/amigo

# Chạy build để Quarkus index SPI và Theme vào server
RUN /opt/keycloak/bin/kc.sh build

FROM registry.redhat.io/rhbk/keycloak-rhel9:26.6
COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]