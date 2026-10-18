#!/usr/bin/env bash
# Télécharge les ressources externes listées dans assets/external.manifest,
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$ROOT/assets/external.manifest"
DL="$ROOT/assets/downloads"
PIN=0
[ "${1:-}" = "--pin" ] && PIN=1

install -d "$DL"
PENDING=0

while IFS='|' read -r NAME FILE URL SIZE SHA; do
    case "$NAME" in ''|'#'*) continue ;; esac
    DEST="$DL/$FILE"

    if [ ! -f "$DEST" ]; then
        echo "Téléchargement : $NAME -> $FILE"
        wget -q --show-progress -O "$DEST.part" "$URL" </dev/null
        GOT_SIZE="$(stat -c %s "$DEST.part")"
        if [ "$GOT_SIZE" != "$SIZE" ]; then
            echo "ERREUR : $NAME fait $GOT_SIZE octets, le manifeste en attend $SIZE. Fichier laissé : $DEST.part" >&2
            exit 1
        fi
        mv "$DEST.part" "$DEST"
    fi

    GOT_SHA="$(sha256sum "$DEST" | cut -d' ' -f1)"
    if [ "$SHA" = "A_EPINGLER" ]; then
        if [ "$PIN" = 1 ]; then
            sed -i "s/^\(${NAME}|[^|]*|[^|]*|[^|]*|\)A_EPINGLER\$/\1${GOT_SHA}/" "$MANIFEST"
            echo "Épinglé : $NAME  sha256=$GOT_SHA"
        else
            echo "A ÉPINGLER : $NAME  sha256=$GOT_SHA  (relance avec --pin pour l'écrire dans le manifeste)" >&2
            PENDING=1
        fi
    elif [ "$GOT_SHA" != "$SHA" ]; then
        echo "ERREUR : sha256 de $NAME différent du manifeste." >&2
        echo "  attendu : $SHA" >&2
        echo "  obtenu  : $GOT_SHA" >&2
        echo "  Fichier laissé en place : $DEST" >&2
        exit 1
    else
        echo "OK : $NAME ($FILE)"
    fi
done < "$MANIFEST"

[ "$PENDING" = 0 ] || exit 2

# osu!lazer extraction de l'AppImage
OSU_FILE="$(awk -F'|' '$1=="osu"{print $2}' "$MANIFEST")"
OSU_CACHE="$ROOT/assets/cache/osu"
if [ -n "$OSU_FILE" ] && [ ! -d "$OSU_CACHE/squashfs-root" ]; then
    echo "Extraction de l'AppImage d'osu!lazer..."
    install -d "$ROOT/assets/cache"
    TMP="$(mktemp -d "$ROOT/assets/cache/osu-extract.XXXXXX")"
    chmod +x "$DL/$OSU_FILE"
    ( cd "$TMP" && "$DL/$OSU_FILE" --appimage-extract >/dev/null )
    install -d "$OSU_CACHE"
    mv "$TMP/squashfs-root" "$OSU_CACHE/squashfs-root"
    rmdir "$TMP"
    echo "Extrait dans : assets/cache/osu/squashfs-root"
fi
