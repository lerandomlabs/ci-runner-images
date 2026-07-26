# syntax=docker/dockerfile:1
# Keep this base pin synchronized with the ARC runner image until a separately
# tested image release is promoted into the cluster.
ARG RUNNER_VERSION=2.336.0
FROM ghcr.io/actions/actions-runner:${RUNNER_VERSION}

ARG RUNNER_VERSION
ARG BUILD_DATE=unknown

LABEL org.opencontainers.image.title="Lerandomlabs backend ARC runner" \
      org.opencontainers.image.description="GitHub Actions runner with backend system dependencies preinstalled" \
      org.opencontainers.image.source="https://github.com/lerandomlabs/ci-runner-images" \
      org.opencontainers.image.base.name="ghcr.io/actions/actions-runner:${RUNNER_VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}"

# The upstream runner deliberately runs as the non-root `runner` user. Install
# the immutable system dependency contract during image construction, then
# restore that runtime identity for ARC.
USER root

COPY packages.txt /usr/local/share/backend-runner-packages.txt
COPY verify.sh /usr/local/bin/verify-backend-runner

RUN set -eux; \
    . /etc/os-release; \
    test "$ID" = ubuntu; \
    apt-get update; \
    apt-get install --yes --no-install-recommends ca-certificates curl; \
    curl --fail --silent --show-error --location \
      https://www.postgresql.org/media/keys/ACCC4CF8.asc \
      --output /usr/share/keyrings/apt.postgresql.org.asc; \
    echo "deb [signed-by=/usr/share/keyrings/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt ${VERSION_CODENAME}-pgdg main" \
      > /etc/apt/sources.list.d/pgdg.list; \
    apt-get update; \
    grep --extended-regexp --invert-match '^[[:space:]]*(#|$)' \
      /usr/local/share/backend-runner-packages.txt \
      | xargs --no-run-if-empty apt-get install --yes --no-install-recommends; \
    chmod 0755 /usr/local/bin/verify-backend-runner; \
    rm -rf /var/lib/apt/lists/*

USER runner
