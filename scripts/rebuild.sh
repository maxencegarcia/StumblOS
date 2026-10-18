#!/usr/bin/env bash
# Reconstruit l'ISO
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/project.env"

LOG="$ROOT/out/build-$(date +%Y%m%d-%H%M).log"

# Refuse de démarrer si montage sous build/
if mount | grep -F "$ROOT/build" > /dev/null; then
  echo "Des montages subsistent sous $ROOT/build : abandon." >&2
  exit 1
fi

cd "$ROOT/build"

# Nettoyage
sudo lb clean

# Configuration puis synchronisation
"$ROOT/scripts/configure.sh"
"$ROOT/scripts/sync.sh"

# Construction
sudo lb build 2>&1 | tee "$LOG"

# Archivage de l'ISO avec version et début du hash
ISO="$ROOT/build/${DISTRO_NAME}-amd64.hybrid.iso"
HASH="$(sha256sum "$ISO" | cut -c1-12)"
DEST="$ROOT/out/${DISTRO_NAME}-${DISTRO_VERSION}-${HASH}.iso"
cp "$ISO" "$DEST"
sha256sum "$DEST"
echo "ISO archivée : $DEST"
echo "Journal : $LOG"
