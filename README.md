# ActionPak for Servers


ActionPak for Servers is a comprehensive Bash script designed to simplify various server setup and management tasks on Ubuntu-based systems. It provides a menu-driven interface for performing common server configurations and installing essential tools.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Menu Options](#menu-options)
- [Contributing](#contributing)
- [License](#license)

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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.


## Disclaimer

This script makes significant changes to your system. Always review the script and understand its actions before running it. Ensure you have backups of important data before making system-wide changes.
