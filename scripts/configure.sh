#!/usr/bin/env bash
# Génère la configuration live-build dans build/ (aucun téléchargement).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/project.env"

cd "$ROOT/build"

lb config \
  --distribution trixie \
  --architecture amd64 \
  --binary-image iso-hybrid \
  --debian-installer none \
  --archive-areas "main non-free-firmware" \
  --iso-volume "${DISTRO_NAME^^}_${DISTRO_VERSION//./_}" \
  --iso-application "${DISTRO_NAME}" \
  --image-name "${DISTRO_NAME}" \
  --checksums sha256 \
  --bootappend-live "boot=live components locales=fr_FR.UTF-8 keyboard-layouts=fr timezone=Europe/Paris"
