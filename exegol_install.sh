#!/bin/bash

## Installation Script for Exegol
## Tested on Ubuntu 24.04.2, Fedora 41, Debian 12, Arch Linux. 

# Exit the script immediately if any command fails
set -e  

# Detect the package manager (apt, pacman, dnf, yum, or zypper)
if command -v apt >/dev/null; then
    PKG_MANAGER="apt"
elif command -v pacman >/dev/null; then
    PKG_MANAGER="pacman"
elif command -v dnf >/dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum >/dev/null; then
    PKG_MANAGER="yum"
elif command -v zypper >/dev/null; then
    PKG_MANAGER="zypper"
else
    echo "No compatible package manager detected. Aborting."
    exit 1
fi

echo "Detected package manager: $PKG_MANAGER"

# Update the system and install prerequisites
case "$PKG_MANAGER" in
    apt)
        sudo apt update -y && sudo apt upgrade -y
        sudo apt install -y git curl python3 python3-pip
        ;;
    pacman)
        sudo pacman -Syu --noconfirm
        sudo pacman -S --noconfirm git curl python3 python-pip
        ;;
    dnf)
        sudo dnf -y update
        sudo dnf install -y git curl python3 python3-pip
        ;;
    yum)
        sudo yum -y update
        sudo yum install -y git curl python3 python3-pip
        ;;
    zypper)
        sudo zypper refresh
        sudo zypper install -y git curl python3 python3-pip
        ;;
esac


# Install Docker
if ! command -v docker &>/dev/null; then
    echo "Installing Docker..."
    if [ "$PKG_MANAGER" = "pacman" ]; then
        sudo pacman -S --noconfirm docker
    else
        curl -fsSL "https://get.docker.com/" | sh
    fi
else
    echo "Docker is already installed."
fi

# Clone the Exegol repository
if [ ! -d "/$(pwd)/Exegol" ]; then
    git clone "https://github.com/ThePorgs/Exegol"
else
    echo "Exegol repository already exists."
fi

# Install Python dependencies
sudo python3 -m pip install --requirement "Exegol/requirements.txt" --break-system-packages --ignore-installed

# Create a symbolic link for exegol
sudo ln -sf "/$(pwd)/Exegol/exegol.py" "/usr/local/bin/exegol"

# Add alias for Exegol
if ! grep -q "alias exegol" ~/.bash_aliases 2>/dev/null; then
    echo "alias exegol='sudo -E $(which exegol)'" >> ~/.bash_aliases
fi
source ~/.bashrc

# Start docker.service
sudo systemctl start docker.service

echo "Exegol Installation complete!"
