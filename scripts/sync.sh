#!/usr/bin/env bash
# Copie les sources de src/ et assets/ vers build/config/ (n'efface rien).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/project.env"
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

# Fond de l'écran de connexion SDDM : chemin fixe, indépendant de la taille de l'image
install -D -m 644 "$IMG" "$DEST/includes.chroot_after_packages/usr/share/distro/sddm/background.jpg"
echo "Fond SDDM installé : usr/share/distro/sddm/background.jpg"

# Fond du menu GRUB (800x600, généré) : posé dans l'ISO via includes.binary
install -d "$DEST/includes.binary/boot/grub"
python3 "$ROOT/scripts/make-grub-splash.py" "$IMG" "$DEST/includes.binary/boot/grub/splash.png"
echo "Fond GRUB généré : includes.binary/boot/grub/splash.png"

# Hooks de l'étape binary : @DISTRO_LABEL@ remplacé par la valeur de project.env
install -d "$DEST/hooks/normal"
for HOOK in "$ROOT"/src/hooks/*.binary; do
    [ -e "$HOOK" ] || continue
    sed "s|@DISTRO_LABEL@|${DISTRO_LABEL}|g" "$HOOK" > "$DEST/hooks/normal/$(basename "$HOOK")"
    chmod 755 "$DEST/hooks/normal/$(basename "$HOOK")"
    echo "Hook installé : hooks/normal/$(basename "$HOOK")"
done
