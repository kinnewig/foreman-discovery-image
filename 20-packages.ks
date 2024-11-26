%packages --excludedocs --inst-langs en_US.utf8
# from lorax examples
@core
kernel
kernel-modules
kernel-modules-extra
grub2-efi
grub2
shim
syslinux
dracut-config-generic
-dracut-config-rescue
dracut-network
dracut-squash
tar
isomd5sum

postgresql

# required by lorax
dracut-live
# required by bootloader
centos-logos
memtest86+
biosdevname
vim-minimal

# Facter
rubygem-facter
ethtool
lldpad
net-tools
dmidecode
virt-what

# Foreman proxy
foreman-discovery-image-service
curl
wget
passwd
sudo
OpenIPMI
ipmitool
openssl
elfutils-libs

# Interactive discovery
foreman-discovery-image-service-tui
kexec-tools
kbd

# Debugging support
less
file

# SSH access
openssh-clients
openssh-server

# Starts all interfaces automatically for us
NetworkManager

# Used to update code at runtime
unzip

# Enable stripping
binutils

# For UEFI/Secureboot support
efibootmgr
grub2-efi
grub2-efi-x64
grub2-efi-x64-cdboot
shim
shim-x64

# Useful utilities for users who use FDI for image-based provisioning
grub2-tools
e2fsprogs
parted
mdadm
xfsprogs
e2fsprogs
bzip2
tcpdump

######################
# Packages to Remove #
######################
#
# Some ideas from:
#
# https://github.com/weldr/lorax/blob/rhel9-branch/share/templates.d/99-generic/runtime-cleanup.tmpl

-geoclue2

# Audio
-opus
-libtheora
-libvisual
-flac-libs
-gsm
-avahi-glib
-avahi-libs
-ModemManager-glib
-flac
-gstreamer-tools
-libsndfile
-pulseaudio*
-sound-theme-freedesktop
-speech-dispatcher

-checkpolicy
-selinux* # remove all selinux packages
-libselinux-utils
-fedora-release-rawhide
-usermode
-usermode-gtk
-pinentry

## no storage device monitoring
-device-mapper-event
-dmraid-events
-sgpio
-notification-daemon
-logrotate

# various other things we remove to save space
-avahi-autoipd
-coreutils-libs
-dash
-db4-utils
-diffutils
-firewalld
-info
-iptables
-jasper-libs
-libasyncns
-libXxf86misc
-libhbaapi
-libhbalinux
-libtiff
-linux-atm-libs
-lvm2-libs
-m4
-mailx
-makebootfat
-mingetty
-mobile-broadband-provider-info
-pkgconfig
-ppp
-pth
-rmt
-rpcbind
-squashfs-tools
-system-config-firewall-base
-tigervnc-license
-ttmkfdir
-xorg-x11-font-utils
-xorg-x11-server-common
-xml-common
-yum-utils
%end
