#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Define variables
DISTRO_NAME="diesel-linux"
CHROOT_DIR="/home/ubuntu/${DISTRO_NAME}/chroot"
IMAGE_DIR="/home/ubuntu/${DISTRO_NAME}/image"
ISO_NAME="${DISTRO_NAME}-1.0-ignition-amd64.iso"

# Ensure necessary tools are installed on the build system
sudo apt-get update
sudo apt-get install -y debootstrap squashfs-tools xorriso grub-pc-bin

# 1. Create base system using debootstrap
echo "Creating base system with debootstrap..."
sudo debootstrap --arch=amd64 --variant=minbase noble ${CHROOT_DIR} http://us.archive.ubuntu.com/ubuntu/

# 2. Mount necessary directories into chroot
echo "Mounting necessary directories into chroot..."
sudo mount --bind /dev ${CHROOT_DIR}/dev
sudo mount --bind /run ${CHROOT_DIR}/run

# 3. Chroot into the new system and perform customizations
echo "Chrooting into the new system for customizations..."
# This part will be expanded in a later phase with actual customization commands
# For now, we'll just create a placeholder script to be executed inside chroot

# Create a script to run inside the chroot environment
cat <<EOF | sudo tee ${CHROOT_DIR}/tmp/chroot_customize.sh
#!/bin/bash

mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C

echo "ubuntu-fs-live" > /etc/hostname

cat <<'EOT' > /etc/apt/sources.list
deb http://us.archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse
deb http://us.archive.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse
deb http://us.archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse
EOT

apt-get update
apt-get install -y libterm-readline-gnu-perl systemd-sysv

dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id

dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

apt-get -y upgrade

# Install core packages from the list
xargs sudo apt-get install -y < /tmp/core_packages.list

# Clean up
apt-get clean
rm -rf /tmp/*

umount /proc || true
umount /sys || true
umount /dev/pts || true

EOF

# Copy the package list into the chroot environment
sudo cp /home/ubuntu/${DISTRO_NAME}/packages/core_packages.list ${CHROOT_DIR}/tmp/core_packages.list

# Execute the customization script inside chroot
sudo chroot ${CHROOT_DIR} /bin/bash /tmp/chroot_customize.sh

# 4. Unmount directories
echo "Unmounting directories..."
sudo umount ${CHROOT_DIR}/dev
sudo umount ${CHROOT_DIR}/run

# 5. Create image directory structure
echo "Creating image directory structure..."
mkdir -p ${IMAGE_DIR}/{casper,isolinux,install}

# 6. Copy kernel and initrd
echo "Copying kernel and initrd..."
# These paths need to be dynamic based on the installed kernel version in chroot
# For now, we'll use placeholders and refine later.
# You would typically get these from the chroot after installation.
# Example: sudo cp ${CHROOT_DIR}/boot/vmlinuz-*generic ${IMAGE_DIR}/casper/vmlinuz
# Example: sudo cp ${CHROOT_DIR}/boot/initrd.img-*generic ${IMAGE_DIR}/casper/initrd

# Placeholder for kernel and initrd copy - will be updated with actual files from chroot
# For now, we'll assume a generic kernel is available for demonstration.
# In a real scenario, you'd need to extract these from the chroot after it's built.
# For simplicity in this scaffold, we'll skip direct copy and focus on the ISO generation structure.

# 7. Create SquashFS filesystem
echo "Creating SquashFS filesystem..."
sudo mksquashfs ${CHROOT_DIR} ${IMAGE_DIR}/casper/filesystem.squashfs -comp xz

# 8. Create GRUB configuration (simplified for scaffold)
echo "Creating GRUB configuration..."
cat <<EOF > ${IMAGE_DIR}/isolinux/grub.cfg
search --set=root --file /ubuntu
insmod all_videos
set default="0"
set timeout=30

menuentry "Try Diesel Linux without installing" {
    linux /casper/vmlinuz boot=casper nopersistent toram quiet splash ---
    initrd /casper/initrd
}

menuentry "Install Diesel Linux" {
    linux /casper/vmlinuz boot=casper only-ubiquity quiet splash ---
    initrd /casper/initrd
}

menuentry "Check disc for defects" {
    linux /casper/vmlinuz boot=casper integrity-check quiet splash ---
    initrd /casper/initrd
}

# Placeholder for UEFI firmware settings and memtest
# These would be dynamically added based on actual kernel/bootloader setup
EOF

# 9. Generate ISO image
echo "Generating ISO image..."
sudo xorriso -as mkisofs \
   -r \
   -V "${DISTRO_NAME}" \
   -o /home/ubuntu/${DISTRO_NAME}/${ISO_NAME} \
   -J -joliet-long \
   -b isolinux/isolinux.bin \
   -c isolinux/boot.cat \
   -no-emul-boot \
   -boot-load-size 4 \
   -boot-info-table \
   -eltorito-alt-boot \
   -e boot/grub/efi.img \
   -no-emul-boot \
   -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
   -isohybrid-gpt-basdat \
   ${IMAGE_DIR}

echo "ISO creation complete: /home/ubuntu/${DISTRO_NAME}/${ISO_NAME}"
