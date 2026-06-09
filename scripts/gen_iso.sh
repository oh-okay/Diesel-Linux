#!/bin/bash

# Diesel Linux ISO Generation Script
# Based on Ubuntu 24.04 LTS (Noble Numbat)

set -e

# Configuration
DISTRO_NAME="Diesel Linux"
DISTRO_CODENAME="noble"
VERSION="1.0"
CODENAME="Ignition"
PROJECT_DIR="/home/ubuntu/diesel-linux"
CHROOT_DIR="${PROJECT_DIR}/chroot"
IMAGE_DIR="${PROJECT_DIR}/image"
ISO_NAME="diesel-linux-${VERSION}-${CODENAME}-amd64.iso"

# Ensure root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "--- Starting Diesel Linux Build Process ---"

# Install dependencies
apt-get update
apt-get install -y debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools isolinux

# 1. Bootstrap
if [ ! -d "${CHROOT_DIR}" ]; then
    echo "Bootstrapping minimal Ubuntu system..."
    mkdir -p "${CHROOT_DIR}"
    debootstrap --arch=amd64 --variant=minbase ${DISTRO_CODENAME} "${CHROOT_DIR}" http://archive.ubuntu.com/ubuntu/
fi

# 2. Copy customization scripts and assets into chroot
echo "Copying customization scripts and assets into chroot..."
cp "${PROJECT_DIR}/config/optimize_boot.sh" "${CHROOT_DIR}/tmp/optimize_boot.sh"
cp "${PROJECT_DIR}/config/apply_theming.sh" "${CHROOT_DIR}/tmp/apply_theming.sh"
cp "${PROJECT_DIR}/packages/core_packages.list" "${CHROOT_DIR}/tmp/core_packages.list"
cp "/home/ubuntu/diesel_linux_wallpaper.png" "${CHROOT_DIR}/tmp/diesel_linux_wallpaper.png"

# 3. Customization script for chroot
cat <<EOF > "${CHROOT_DIR}/tmp/customize.sh"
#!/bin/bash
set -e

# Basic setup
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts
export HOME=/root
export LC_ALL=C

# Configure repositories
cat <<EOT > /etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse
EOT

apt-get update
apt-get install -y systemd-sysv dbus

# Set hostname
echo "diesel-linux" > /etc/hostname

# Install essential live system packages
apt-get install -y \
    sudo \
    casper \
    discover \
    laptop-detect \
    os-prober \
    network-manager \
    net-tools \
    wireless-tools \
    locales \
    grub-common \
    grub-gfxpayload-lists \
    grub-pc \
    grub-pc-bin \
    grub2-common \
    grub-efi-amd64-signed \
    shim-signed \
    mtools \
    binutils \
    linux-generic

# Install Desktop Environment (XFCE for speed and performance)
apt-get install -y xfce4 xfce4-goodies lightdm

# Developer Tools
apt-get install -y git build-essential curl vim nano less python3 python3-pip docker.io docker-compose

# Apply boot optimizations
chmod +x /tmp/optimize_boot.sh
/tmp/optimize_boot.sh

# Apply theming
chmod +x /tmp/apply_theming.sh
/tmp/apply_theming.sh

# Final cleanup
apt-get autoremove -y
apt-get clean
rm -rf /tmp/optimize_boot.sh /tmp/apply_theming.sh /tmp/core_packages.list /tmp/diesel_linux_wallpaper.png

# Unmount
umount /proc
umount /sys
umount /dev/pts
EOF

chmod +x "${CHROOT_DIR}/tmp/customize.sh"

# 4. Execute chroot customization
echo "Executing chroot customization..."
mount --bind /dev "${CHROOT_DIR}/dev"
chroot "${CHROOT_DIR}" /tmp/customize.sh
umount "${CHROOT_DIR}/dev"

# 5. Prepare ISO image directory
echo "Preparing ISO image directory..."
rm -rf "${IMAGE_DIR}"
mkdir -p "${IMAGE_DIR}"/{casper,isolinux,install,boot/grub}

# 6. Extract Kernel and Initrd from chroot
echo "Extracting kernel and initrd..."
VMLINUZ=$(ls "${CHROOT_DIR}/boot/vmlinuz-"* | head -n 1)
INITRD=$(ls "${CHROOT_DIR}/boot/initrd.img-"* | head -n 1)

cp "${VMLINUZ}" "${IMAGE_DIR}/casper/vmlinuz"
cp "${INITRD}" "${IMAGE_DIR}/casper/initrd"

# 7. Create SquashFS
echo "Creating SquashFS (this may take a while)..."
mksquashfs "${CHROOT_DIR}" "${IMAGE_DIR}/casper/filesystem.squashfs" -comp xz -e boot

# 8. Create Bootloader Configs
echo "Configuring GRUB..."
cat <<EOF > "${IMAGE_DIR}/boot/grub/grub.cfg"
set default="0"
set timeout=10

menuentry "Diesel Linux ${VERSION} (${CODENAME}) - Live" {
    linux /casper/vmlinuz boot=casper quiet splash ---
    initrd /casper/initrd
}

menuentry "Install Diesel Linux" {
    linux /casper/vmlinuz boot=casper only-ubiquity quiet splash ---
    initrd /casper/initrd
}
EOF

# 9. Final ISO Generation
echo "Generating final ISO..."
xorriso -as mkisofs \
  -r -V "DIESEL_LINUX" \
  -o "${PROJECT_DIR}/${ISO_NAME}" \
  -J -joliet-long -l \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e boot/grub/efi.img \
  -no-emul-boot \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
  "${IMAGE_DIR}"

echo "Diesel Linux ISO created successfully at ${PROJECT_DIR}/${ISO_NAME}"
