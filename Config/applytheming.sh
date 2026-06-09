#!/bin/bash

# Diesel Linux Theming and Branding Script

echo "Applying Diesel Linux branding..."

# 1. Install Wallpaper
mkdir -p /usr/share/backgrounds/diesel-linux
cp /tmp/diesel_linux_wallpaper.png /usr/share/backgrounds/diesel-linux/default_wallpaper.png

# 2. Set Default Wallpaper for XFCE
# This needs to be done via xfconf-query or by editing xml files in /etc/skel
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

# 3. Custom Plymouth Theme (Boot Splash)
# This is a simplified placeholder. A real theme would involve a directory in /usr/share/plymouth/themes/
echo "Diesel Linux - Ignition" > /etc/issue

# 4. Custom Terminal Prompt
cat <<EOF >> /etc/skel/.bashrc

# Diesel Linux Custom Prompt
export PS1="\[\033[01;34m\]diesel\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]\$ "
EOF

echo "Theming applied successfully."
