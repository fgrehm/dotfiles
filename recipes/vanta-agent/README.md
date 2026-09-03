# vanta-agent

Opt-in Vanta user agent for Omarchy hosts. During `chezmoi init`, Omarchy hosts are asked whether to install it; containers and non-Omarchy systems are never prompted.

The recipe downloads the pinned Vanta Debian payload, verifies its SHA-256 checksum, installs the agent under `/var/vanta`, installs its systemd service, and runs Vanta's interactive `vanta-setup` command. The service is enabled and started after setup.

The Vanta owner email and agent key are entered interactively and are not stored in this repository or chezmoi data.

Upstream packaging: [AUR vanta-agent](https://aur.archlinux.org/packages/vanta-agent)
