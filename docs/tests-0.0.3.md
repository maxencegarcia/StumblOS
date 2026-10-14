# Tests de l'ISO stumblos 0.0.3

- Fichier : stumblos-0.0.3-fc97f071ce4f.iso
- Changement par rapport à 0.0.2 : fond d'écran par défaut (dossier distro-default)
- Environnement de test : VM libvirt/KVM, UEFI sans Secure Boot, sans disque

## Validé
- Le fond s'affiche par défaut pour le compte `user`

## Limites connues
- Image source en 1095x730 : sera agrandie sur un écran plus grand
- Image gardée hors Git (assets/private/), licence : All rights reserved
- Pas encore de test sur matériel réel ni en Secure Boot
