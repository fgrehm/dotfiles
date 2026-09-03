# vanta-agent

Opt-in Vanta user agent for Omarchy hosts. During `chezmoi init`, Omarchy hosts are asked whether to install it; containers and non-Omarchy systems are never prompted.

The recipe downloads the pinned Vanta Debian payload, verifies its SHA-256 checksum, installs the agent under `/var/vanta`, installs its systemd service, and runs Vanta's interactive `vanta-setup` command. The service is enabled and started after setup.

The Vanta owner email and agent key are entered interactively and are not stored in this repository or chezmoi data.

## Troubleshooting

Check registration and diagnostics as root:

```bash
sudo /var/vanta/vanta-cli check-registration
sudo /var/vanta/vanta-cli doctor
```

If registration reports `INVALID_RE_ENROLLMENT`, reset the local enrollment state and register again with the current company Vanta key:

```bash
sudo /var/vanta/vanta-cli reset
sudo /var/vanta/vanta-cli register --secret="VANTA_KEY" --email="YOUR_EMAIL"
sudo systemctl restart vanta-agent
sudo /var/vanta/vanta-cli doctor
```

The key is available to Vanta admins in the setup instructions under `Option 3: MDM and Vanta Device Monitor`. Do not commit it or paste it into chat. Agent output is also written under `/var/vanta/log/`; service startup messages are available with `sudo journalctl -u vanta-agent`.

Upstream packaging: [AUR vanta-agent](https://aur.archlinux.org/packages/vanta-agent)
