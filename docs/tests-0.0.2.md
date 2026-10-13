# Tests de l'ISO stumblos 0.0.2

- Fichier : stumblos-0.0.2-372c343e33c5.iso
- SHA256 : 372c343e33c5952c4f8bafac435a3c9a5f303f161842731662758c56384c8b64
- Commit de la configuration : fcc08af
- Environnement de test : VM libvirt/KVM, UEFI sans Secure Boot, sans disque, 4 Go de RAM

## Validé
- Démarrage UEFI, autologin SDDM, session Plasma Wayland
- Compte `user` créé (paquet user-setup, ajouté après échec de v0.0.1)
- Locale fr_FR.UTF-8, clavier AZERTY (bureau et console), fuseau Europe/Paris
- Réseau : NetworkManager, accès Internet par NAT
- Hors-ligne : bureau en 10,5 s, identique avec ou sans réseau
- Firefox, VLC, terminal, Dolphin, Paramètres système lancés
- Japonais affiché dans Firefox (polices Noto CJK)

## Contrôle « sans installateur » (limites : recherche par noms connus)
- Absents : calamares, tasksel, debian-installer, gparted, partitionmanager
- Présents, non installateurs : user-setup (création de compte), fdisk, sfdisk, cfdisk, parted, mkfs.ext4
- Aucun lanceur d'installation dans les 96 lanceurs du menu (seul kfontinst, gestionnaire de polices)

## À tester
- Secure Boot, redémarrage, son, matériel réel

## BIOS (isolinux)
- Démarrage BIOS (SeaBIOS) dans une VM : bureau Plasma atteint, autologin OK

## Outils de disque présents
- parted est tiré par udisks2 (gestion des disques sous KDE) ; ce ne sont pas des installateurs
