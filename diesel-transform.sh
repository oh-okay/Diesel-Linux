#!/bin/bash

# Diesel Linux Transformation Script
# This script transforms a standard Ubuntu installation into Diesel Linux.

set -e

# --- Configuration ---
DIESEL_WALLPAPER_URL="https://raw.githubusercontent.com/oh-okay/Diesel-Linux/main/diesel_linux_wallpaper.png"
DIESEL_LOGO_URL="https://raw.githubusercontent.com/oh-okay/Diesel-Linux/main/diesel_linux_logo.png"

# --- Functions ---
log_info() {
    echo -e "\e[32m[INFO]\e[0m $1"
}

log_warn() {
    echo -e "\e[33m[WARN]\e[0m $1"
}

log_error() {
    echo -e "\e[31m[ERROR]\e[0m $1"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run this script with sudo: sudo ./diesel-transform.sh"
        exit 1
    fi
}

install_packages() {
    log_info "Updating package lists..."
    apt update
    log_info "Installing core and developer packages..."
    apt install -y \
        xfce4 xfce4-goodies lightdm lightdm-gtk-greeter \
        git build-essential curl vim nano less python3 python3-pip \
        docker.io docker-compose zram-config
}

apply_optimizations() {
    log_info "Applying boot and system optimizations..."

    # Disable unnecessary services
    SERVICES_TO_DISABLE=(
        "NetworkManager-wait-online.service"
        "bluetooth.service"
        "cups.service"
        "avahi-daemon.service"
    )

    for service in "${SERVICES_TO_DISABLE[@]}"; do
        systemctl disable "$service" || log_warn "Service $service not found or already disabled, skipping."
    done

    # Optimize Systemd-journald
    log_info "Optimizing systemd-journald..."
    sed -i 's/#SystemMaxUse=/SystemMaxUse=50M/' /etc/systemd/journald.conf

    # Kernel Parameter Optimizations
    log_info "Applying kernel parameter tweaks..."
    cat <<EOF >> /etc/sysctl.conf
# Diesel Linux Performance Tweaks
vm.swappiness=10
vm.vfs_cache_pressure=50
net.core.rmem_max=16777216
net.core.wmem_max=16777216
EOF
    sysctl -p

    # Fast Boot (GRUB timeout)
    log_info "Setting GRUB timeout to 2 seconds..."
    sed -i 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=2/' /etc/default/grub
    update-grub

    log_info "Optimizations applied. A reboot is recommended for full effect."
}

apply_theming() {
    log_info "Applying Diesel Linux branding and theming..."

    # Download and install wallpaper
    log_info "Downloading and setting wallpaper..."
    mkdir -p /usr/share/backgrounds/diesel-linux
    wget -O /usr/share/backgrounds/diesel-linux/default_wallpaper.png "${DIESEL_WALLPAPER_URL}"

    # Set Default Wallpaper for XFCE for new users
    mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml
    cat <<EOF > /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="image-path" type="string" value="/usr/share/backgrounds/diesel-linux/default_wallpaper.png"/>
        <property name="last-image" type="string" value="/usr/share/backgrounds/diesel-linux/default_wallpaper.png"/>
      </property>
    </property>
  </property>
</channel>
EOF

    # Custom Plymouth Theme (Boot Splash) - simplified
    log_info "Setting boot splash message..."
    echo "Diesel Linux - Ignition" > /etc/issue

    # Custom Terminal Prompt for new users
    log_info "Configuring custom terminal prompt..."
    cat <<EOF >> /etc/skel/.bashrc

# Diesel Linux Custom Prompt
export PS1="\[\033[01;34m\]diesel\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]\$ "
EOF

    log_info "Theming applied. New users will see the changes upon login."
}

# --- Main Execution ---
check_root

log_info "Starting Diesel Linux Transformation..."

install_packages
apply_optimizations
apply_theming

log_info "Diesel Linux Transformation Complete! Please reboot your system for all changes to take full effect."
log_info "You can now enjoy your developer-focused Diesel Linux experience."
