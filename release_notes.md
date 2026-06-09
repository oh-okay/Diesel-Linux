# Diesel Linux 1.0 "Ignition" - Release Notes

## Overview

We are thrilled to announce the release of **Diesel Linux 1.0 "Ignition"**, a brand new, developer-focused Linux distribution built on the stable and reliable foundation of Ubuntu 24.04 LTS (Noble Numbat). Designed with performance, efficiency, and developer productivity in mind, Ignition provides a streamlined and optimized environment for all your computing and development needs.

## Key Features and Improvements

*   **Ubuntu 24.04 LTS Base:** Enjoy the latest features, security updates, and long-term support from the Ubuntu ecosystem.
*   **XFCE Desktop Environment:** A lightweight, fast, and highly customizable desktop experience that prioritizes performance without sacrificing usability.
*   **Optimized Boot Times:** Significant efforts have been made to reduce boot times through intelligent service management and kernel parameter tuning, ensuring you get to your work faster.
*   **Developer Toolchain Pre-installed:**
    *   **Version Control:** Git
    *   **Build Essentials:** `build-essential` package for compiling software
    *   **Programming Languages:** Python 3, Node.js
    *   **Containerization:** Docker, Docker Compose
    *   **Text Editors/IDEs:** Vim, Nano, Less
    *   **Web Utilities:** Curl
*   **Sleek and Modern Theming:** A custom dark theme and professional wallpaper provide a visually appealing and comfortable workspace, designed to reduce eye strain during long coding sessions.
*   **Enhanced Stability:** Leveraging the LTS nature of Ubuntu, Diesel Linux offers a rock-solid platform for critical applications and development projects.
*   **ZRAM Enabled:** Improved memory management and responsiveness through the use of zRAM.

## Installation: Transform Your Ubuntu into Diesel Linux

Diesel Linux is designed for easy adoption on existing Ubuntu 24.04 LTS installations. Instead of a traditional ISO installation, you can transform your current Ubuntu system into Diesel Linux by running a single script. This script automates the installation of all necessary developer tools, applies performance optimizations, and sets up the Diesel Linux branding and theme.

### How to Transform Your System

1.  **Download the Diesel Transformation Script:**
    ```bash
    ![Diesel Linux Logo](https://raw.githubusercontent.com/oh-okay/Diesel-Linux/main/diesel_linux_logo.png)
    ```
2.  **Make the script executable:**
    ```bash
    chmod +x diesel-transform.sh
    ```
3.  **Run the transformation script (as root):**
    ```bash
    sudo ./diesel-transform.sh
    ```

**Important:** A system reboot is highly recommended after running the script to ensure all changes, especially boot optimizations and desktop environment settings, take full effect.

## System Requirements

*   **Processor:** 64-bit processor (AMD64)
*   **RAM:** 2 GB minimum (4 GB recommended for development)
*   **Disk Space:** 20 GB minimum (50 GB recommended for development)
*   **Operating System:** Existing Ubuntu 24.04 LTS installation

## Known Issues

*   Initial boot on some hardware configurations might take slightly longer as the system adapts.
*   Some proprietary drivers may require manual installation post-setup.

## Feedback and Support

Your feedback is invaluable! Please report any issues or suggest improvements via our GitHub repository (link to be added) or community forums (link to be added).

Thank you for choosing Diesel Linux!

**The Diesel Linux Team**
