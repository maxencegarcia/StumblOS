#!/usr/bin/env bash
# Copie les sources de src/ et assets/ vers build/config/ (n'efface rien).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/build/config"

# Listes de paquets
install -d "$DEST/package-lists"
cp -v "$ROOT"/src/package-lists/*.list.chroot "$DEST/package-lists/"

# Fichiers injectés dans le système après l'installation des paquets
install -d "$DEST/includes.chroot_after_packages"
cp -a "$ROOT/src/includes.chroot_after_packages/." "$DEST/includes.chroot_after_packages/"

# Fond d'écran : image hors dépôt, nommée <largeur>x<hauteur>.jpg comme Plasma l'attend
IMG="$ROOT/assets/private/fond.jpg"
SIZE="$(file -b "$IMG" | grep -oE '[0-9]{3,5}x[0-9]{3,5}' | head -1)"
install -D -m 644 "$IMG" "$DEST/includes.chroot_after_packages/usr/share/wallpapers/distro-default/contents/images/${SIZE}.jpg"
echo "Fond d'écran installé : ${SIZE}.jpg"
