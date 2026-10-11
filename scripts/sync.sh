#!/usr/bin/env bash
# Copie les sources de src/ vers build/config/ (n'efface rien).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/build/config"

install -d "$DEST/package-lists"
cp -v "$ROOT"/src/package-lists/*.list.chroot "$DEST/package-lists/"
