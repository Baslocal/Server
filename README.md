# ActionPak for Servers


ActionPak for Servers is a Bash script designed to simplify various server setup and management tasks on Ubuntu server. It provides a menu-driven interface for performing common server configurations and installing essential tools.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Menu Options](#menu-options)


## Features

- 🖧 Server IP Configuration
- 🏷️ Name Server (Hostname Change)
- 🛡️ Wazuh Agent Installation
- 🦠 ClamAV Antivirus Installation
- 🕹️ Cockpit Web Console Installation
- 🔐 Keycloak Identity and Access Management Setup
- 🖥️ Kasm Workspaces Installation(Work in progress)

## Prerequisites

- Ubuntu-based system (some features may work on other Debian-based distributions)
- Sudo privileges
- Internet connection

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/Baslocal/Server.git
   ```
2. Change to the project directory:
   ```
   cd Server
   ```
3. Make the script executable:
   ```
   chmod +x Actionpak_server.sh
   ```


## Single command

```bash
# Check and install sudo if not present
if ! command -v sudo &> /dev/null; then
    apt-get update && apt-get install -y sudo
fi

# Check and install curl if not present
if ! command -v curl &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y curl
fi

# Download the script
sudo curl -s https://raw.githubusercontent.com/Baslocal/Server/main/Actionpak_server.sh -o actionpak.sh

# Make the script executable
sudo chmod +x actionpak.sh

# Run the script
sudo ./actionpak.sh
```

## Usage

Run the script with sudo privileges:

```
sudo ./Actionpak_server.sh
```

Follow the on-screen prompts to select and configure various options.

## Menu Options

### 1. Server IP Configuration
Configures a static IP address for the server using Netplan.

### 2. Name Server (Hostname Change)
Changes the server's hostname and updates the `/etc/hosts` file.

### 3. Wazuh Agent Installer
Installs and configures the Wazuh agent (version 4.8.1) for security monitoring.

### 4. ClamAV Installer
Installs ClamAV antivirus and its daemon, with an option to set up weekly scans.

### 5. Cockpit Installer
Installs the Cockpit web console for easy server management via a web browser.

### 6. Keycloak Installer
Sets up Keycloak (version 25.0.6) for identity and access management using Docker.

### 7. Kasm Installer
Installs Kasm Workspaces (version 1.15.0) for containerized application streaming.

### 8. Exit
Exits the script.

## Troubleshooting

If you encounter issues during installation:

1. Check the respective log files for each component.
2. Ensure your system meets all prerequisites.
3. Verify your internet connection.
4. For Kasm installation issues, you can try running the installation manually:
   ```
   cd /tmp/kasm_release && sudo bash install.sh
   ```

