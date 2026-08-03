# Docker Review Checklist

Use the sections that match the requested review.

## Build

- Dependency inputs are copied before frequently changing source files.
- Build-only dependencies and credentials do not reach the runtime stage.
- `.dockerignore` excludes repository metadata, local caches, secrets, and unrelated artifacts.
- Package-manager caches use BuildKit cache mounts or are removed from the same layer.
- The final image contains every runtime library and command used by the entrypoint and health check.

## Runtime and security

- The base image and application runtime are supported and pinned at the project's chosen precision.
- The process runs with the minimum required user, capabilities, writable paths, and network exposure.
- Secrets enter through the deployment platform and do not persist in image history or logs.
- The entrypoint forwards signals and the main process exits cleanly.
- Health checks distinguish process availability from dependency failures without exposing sensitive data.
- Resource limits, restart policy, and read-only filesystem settings match the deployment platform.

## Compose and networking

- `docker compose config` resolves without warnings that affect the target environment.
- Service readiness is explicit where startup order matters.
- Host ports are published only when external access is required.
- Internal services use scoped networks and service discovery rather than hard-coded addresses.
- Environment-specific overrides do not silently weaken production settings.

## Data and operations

- Persistent paths use intentional named volumes, bind mounts, or external storage.
- Upgrade, backup, restore, and rollback behavior is defined before changing a stateful service.
- Validation commands use unique project, image, container, network, and volume names.
- Cleanup targets only resources created by the validation run.

## Evidence

- Record the exact build target, platform, image digest or tag, and relevant size comparison.
- Check runtime logs and health state after exercising the expected request path.
- Record scanner name, database timestamp, severity policy, and accepted exceptions.
