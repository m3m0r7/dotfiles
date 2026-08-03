---
name: docker-expert
description: Analyze, implement, or review Dockerfiles, Compose configurations, image builds, container runtime behavior, networking, persistence, and container security. Use only for Docker-scoped work, not general Kubernetes, CI, cloud, or database design.
---

# Docker Expert

Follow the project's runtime versions and deployment target instead of copying generic image tags or Compose templates.

## Inspect first

1. Read project guidance, build commands, package manifests, deployment configuration, and existing tests.
2. Find Dockerfiles, Compose files, `.dockerignore`, entrypoints, health checks, and CI build commands with `rg --files`.
3. Inspect the active Docker context and existing resources before running a command that creates, replaces, stops, or removes them.
4. Separate development, build, test, and production requirements.

For a production or security review, read `references/review-checklist.md`.

## Design

- Pin a supported runtime and base image compatible with the application. Verify time-sensitive recommendations in official documentation.
- Use multi-stage builds when they remove build-only tools or credentials from the runtime image.
- Order layers around stable dependency inputs and keep the build context minimal.
- Run as a non-root user where the workload permits it. Match file ownership and writable paths to that user.
- Use BuildKit or platform secret mechanisms. Do not place secrets in build arguments, image layers, repository files, or logs.
- Ensure every health-check command exists in the final image. Prefer an application-native check when minimal images omit shell tools.
- Use the current Compose Specification and `docker compose`. Add legacy syntax only when the target environment requires it.
- Treat volumes and databases as persistent data. Never run prune, volume removal, or destructive reset without explicit authorization.
- Use the project's architecture and platform requirements; do not default to Alpine, distroless, or multi-architecture builds without evidence.

## Validate

- Run the narrowest static check first, such as `docker compose config` or a Dockerfile linter already used by the project.
- Build only when required, with a task-specific tag that does not collide with existing images. Do not default to `--no-cache`.
- If runtime validation is needed, use a unique container and Compose project name, bounded resources, and non-production inputs.
- Verify process startup, signal handling, health status, exposed ports, filesystem permissions, logs, and expected persistence.
- Report image size and scanner results as evidence, not as automatic pass criteria.
- Remove or stop only resources created by the current task and only after resolving their exact identities.

Do not stop merely because the task crosses into CI, cloud, Kubernetes, or database concerns. Handle the Docker portion and report the remaining boundary unless an available skill covers it.
