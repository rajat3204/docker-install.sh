#!/bin/bash

set -euo pipefail

# Progress bar function
progress_bar() {
    echo -ne "Progress ====>                     (33%)\r"
    sleep 0.3
    echo -ne "Progress =============>            (66%)\r"
    sleep 0.3
    echo -ne "Progress ========================> (100%)\r"
    echo -ne '\n'
}

echo -e "\n$(tput setaf 1)$(tput bold)Removing Old Docker$(tput sgr0)\n"
sudo apt-get purge -y docker-ce docker-ce-cli docker-compose-plugin containerd.io || true
sudo apt-get autoremove -y
progress_bar

echo -e "\n$(tput setaf 1)$(tput bold)Removing Old Docker-Compose$(tput sgr0)\n"
if command -v docker-compose &> /dev/null; then
    sudo rm -f "$(which docker-compose)"
    echo "Old docker-compose binary removed."
fi
progress_bar

echo -e "\n$(tput setaf 1)$(tput bold)Installing Latest Docker & Docker-Compose$(tput sgr0)\n"

# Update packages
sudo apt-get update -qq
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repo
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine, CLI, Compose plugin, and Buildx
sudo apt-get update -qq
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker "$USER"

progress_bar
echo -e "\n$(tput setaf 2)$(tput bold)DOCKER & DOCKER-COMPOSE Installed Successfully!!!$(tput sgr0)\n"
echo "👉 Please log out & log back in (or run 'exec su - $USER') to use Docker without sudo."

# Verify installation
docker --version
docker compose version
