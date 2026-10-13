#!/usr/bin/env bash
# Reconstruit l'ISO : nettoyage, configuration, synchronisation, construction, archivage.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/project.env"

LOG="$ROOT/out/build-$(date +%Y%m%d-%H%M).log"

# Refuse de démarrer si un montage subsiste sous build/
if mount | grep -F "$ROOT/build" > /dev/null; then
  echo "Des montages subsistent sous $ROOT/build : abandon." >&2
  exit 1
fi

cd "$ROOT/build"

# 1. Nettoyage (garde le cache de paquets) : sudo, car chroot/ appartient à root
sudo lb clean

# 2. Configuration puis synchronisation, APRÈS le nettoyage
"$ROOT/scripts/configure.sh"
"$ROOT/scripts/sync.sh"

# 3. Construction : sudo pour les montages et le chroot
sudo lb build 2>&1 | tee "$LOG"

# 4. Archivage de l'ISO avec version et début du hash
ISO="$ROOT/build/${DISTRO_NAME}-amd64.hybrid.iso"
HASH="$(sha256sum "$ISO" | cut -c1-12)"
DEST="$ROOT/out/${DISTRO_NAME}-${DISTRO_VERSION}-${HASH}.iso"
cp "$ISO" "$DEST"
sha256sum "$DEST"
echo "ISO archivée : $DEST"
echo "Journal : $LOG"
