require ${@bb.utils.contains('DISTRO_FEATURES', 'efi-secure-boot', 'recipes-kernel/linux/linux-yocto-efi-secure-boot.inc', '', d)}
