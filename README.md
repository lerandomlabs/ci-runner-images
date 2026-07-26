# CI runner images

This repository owns OCI images used by Lerandomlabs GitHub Actions Runner
Controller (ARC) scale sets. It is intentionally separate from Kubernetes
manifests: an image release has its own source pin, package contract, security
rebuild cadence, and benchmark evidence.

## Images

| Image source | Purpose | Base |
| --- | --- | --- |
| `images/backend-runner` | System dependencies required by backend `master` CI jobs | `ghcr.io/actions/actions-runner:2.336.0` |

The backend runner is a derived ARC runner, not a generic Ubuntu image. It
preserves the upstream runner layout, `runner` UID/GID, Docker client, and
runner hooks expected by ARC's manual DIND Pod template.

It bakes the backend's system APT dependency union into an OCI layer. This
avoids unpacking and configuring those packages in every ephemeral runner Pod.
The backend workflow must retain a portable fallback installer for GitHub-hosted
or other runners; it may fast-path when the requested packages are already
installed.

## Local build and verification

The production CI pool is x86_64. Build and verify that platform explicitly:

```bash
docker buildx build --platform linux/amd64 --load \
  --tag local/backend-runner:dev images/backend-runner
docker run --rm --platform linux/amd64 \
  --entrypoint bash local/backend-runner:dev \
  -lc verify-backend-runner
```

Do not use an unreviewed mutable tag in ARC. A tested image is promoted by
immutable digest in the Kubernetes repository.

## Release policy

- The upstream `actions-runner` version is pinned in the Dockerfile.
- Dependabot proposes runner-base updates; review them as runner upgrades.
- A scheduled build refreshes APT security updates but does not change the
  cluster's pinned image digest.
- GitHub Actions publishes Linux/amd64 candidates to GHCR with provenance and
  SBOM metadata.
- An image must pass an ARC canary plus a backend-master benchmark before its
  digest replaces the active runner image.

The Docker build cache for backend application images is a separate concern:
this runner image removes host-tool installation work, but it does not persist
the per-job DIND daemon's BuildKit image store.
