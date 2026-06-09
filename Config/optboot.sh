#!/bin/bash

# Diesel Linux Boot and Performance Optimization Script

echo "Applying boot optimizations..."

# 1. Disable unnecessary services
SERVICES_TO_DISABLE=(
    "NetworkManager-wait-online.service"
    "bluetooth.service"
    "cups.service"
    "avahi-daemon.service"
)

for service in "${SERVICES_TO_DISABLE[@]}"; do
    systemctl disable "$service" || echo "Service $service not found, skipping."
done

# 2. Optimize Systemd-journald
# Reduce log size to speed up disk I/O
sed -i 's/#SystemMaxUse=/SystemMaxUse=50M/' /etc/systemd/journald.conf

# 3. Kernel Parameter Optimizations
# Add performance tweaks to sysctl
cat <<EOF >> /etc/sysctl.conf
# Diesel Linux Performance Tweaks
vm.swappiness=10
vm.vfs_cache_pressure=50
net.core.rmem_max=16777216
net.core.wmem_max=16777216
EOF

# 4. Fast Boot (GRUB timeout)
sed -i 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=2/' /etc/default/grub
update-grub || true

# 5. Enable zRAM for better memory management
apt-get install -y zram-config

echo "Optimizations applied successfully."
