#!/bin/env bash
# vim: ft=bash
# Only x86_64/amd64 is supported. Checksums are pinned for this arch only.
arch="$(uname -m)"
if [ "$arch" != "x86_64" ] && [ "$arch" != "amd64" ]; then
  echo "error: unsupported architecture '$arch' (only x86_64/amd64 is supported)" >&2
  exit 1
fi
