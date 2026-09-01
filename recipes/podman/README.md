# podman

Installs Podman on Omarchy (Arch) for rootless, daemonless containers with Docker and Compose-compatible commands.

- Removes Docker, Docker Compose, Buildx, and `ufw-docker` before installing Podman
- Installs `podman`, `podman-compose`, and the `podman-docker` Docker CLI compatibility wrapper through `omarchy pkg add`
- Adds subordinate UID/GID ranges for rootless containers
- Enables user lingering so rootless containers can run in user services without a login session

Podman remains daemonless. The Docker-compatible `docker` command is translated to Podman, and `docker compose` uses Podman's Compose provider.

This recipe is intentionally skipped on Debian containers and VMs.

## Firewall notes

`ufw-docker` is not a drop-in solution for Podman. It manages Docker-specific firewall chains, while rootless Podman publishes ports through a userspace forwarder. Use normal UFW input rules for published host ports, and prefer loopback bindings such as `-p 127.0.0.1:8080:80` unless a service is intentionally public. Avoid `--network host` for untrusted containers.
