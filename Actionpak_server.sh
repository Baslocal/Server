#!/bin/bash

# ActionPak for Servers by Bas (Non-Modular Version)

# Initial setup
echo "Performing initial setup..."
sudo apt update && sudo apt upgrade -y 
sudo apt-get install sudo -y
sudo apt install curl -y
sudo apt install net-tools -y
echo "Initial setup completed."

# Main menu
while true; do
    clear
    echo "===== ActionPak for Servers by Bas ====="
    echo "1. Server IP Configuration"
    echo "2. Name Server"
    echo "3. Wazuh Agent Installer"
    echo "4. ClamAV Installer"
    echo "5. Cockpit Installer"
    echo "6. Keycloak Installer"
    echo "7. Kasm Installer"
    echo "8. Exit"
    echo "========================================"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            echo "Configuring Static IP..."
            interface=$(ip route | grep default | awk '{print $5}')
            echo "Using network interface: $interface"
            read -p "Enter the desired IP address (e.g., 192.168.1.10): " ip_address
            read -p "Enter the gateway IP address: " gateway
            config_file="/etc/netplan/01-netcfg.yaml"
            echo "Creating Netplan configuration file: $config_file"
            sudo tee $config_file > /dev/null << EOL
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
      dhcp4: no
      addresses: [$ip_address/24]
      gateway4: $gateway
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOL
            echo "Applying Netplan configuration..."
            sudo netplan apply
            echo "IP configuration complete. New settings:"
            ip addr show $interface | grep inet
            ip route | grep default
            echo "Configuration has been set to persist across reboots."
            echo "The system will need to be rebooted to apply changes."
            ;;
        2)
            echo "Changing hostname..."
            read -p "Enter the new hostname for the server: " new_hostname
            sudo hostnamectl set-hostname "$new_hostname"
            sudo sed -i "s/127.0.1.1.*/127.0.1.1\t$new_hostname/" /etc/hosts
            echo "Hostname has been changed to $new_hostname"
            echo "The system will need to be rebooted to fully apply changes."
            ;;
        3)
            echo "Installing Wazuh Agent..."
            read -p "Enter the IP address of your Wazuh manager: " wazuh_manager_ip
            pcname=$(hostname)
            wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.8.1-1_amd64.deb
            sudo WAZUH_MANAGER="$wazuh_manager_ip" WAZUH_AGENT_NAME="$pcname" dpkg -i ./wazuh-agent_4.8.1-1_amd64.deb
            sudo systemctl daemon-reload
            sudo systemctl enable wazuh-agent
            sudo systemctl start wazuh-agent
            echo "Wazuh Agent has been installed and started."
            echo "Agent Name: $pcname"
            echo "Wazuh Manager IP: $wazuh_manager_ip"
            ;;
        4)
            echo "Installing ClamAV..."
            sudo apt-get update && sudo apt-get install -y clamav clamav-daemon
            sudo systemctl start clamav-daemon
            sudo systemctl enable clamav-daemon
            echo "ClamAV installed and started."
            read -p "Do you want to set up a weekly ClamAV scan? (y/n): " setup_weekly_scan
            if [[ "$setup_weekly_scan" =~ ^[Yy]$ ]]; then
                sudo tee /usr/local/bin/weekly_clamscan.sh > /dev/null << EOL
#!/bin/bash
freshclam
clamscan -r / | grep FOUND >> /var/log/clamav/weekly_scan.log
EOL
                sudo chmod +x /usr/local/bin/weekly_clamscan.sh
                echo "0 2 * * 0 root /usr/local/bin/weekly_clamscan.sh" | sudo tee -a /etc/crontab > /dev/null
                echo "Weekly ClamAV scan has been set up to run every Sunday at 2:00 AM."
            else
                echo "Weekly scan setup skipped."
            fi
            ;;
        5)
            echo "Installing Cockpit..."
            . /etc/os-release
            if [ "$ID" != "ubuntu" ]; then
                echo "This script is intended for Ubuntu systems only."
            else
                sudo apt update
                if apt-cache policy | grep -q "${VERSION_CODENAME}-backports"; then
                    echo "Installing Cockpit from backports..."
                    sudo apt install -y -t ${VERSION_CODENAME}-backports cockpit
                else
                    echo "Installing Cockpit from the main repository..."
                    sudo apt install -y cockpit
                fi
                echo "Cockpit has been successfully installed."
                echo "You can access it by opening a web browser and navigating to:"
                echo "https://$(hostname -I | awk '{print $1}'):9090"
                echo "Use your system user account credentials to log in."
            fi
            ;;
        6)
            echo "Installing Keycloak..."
            KEYCLOAK_VERSION="25.0.6"
            KEYCLOAK_ADMIN="admin"
            KEYCLOAK_ADMIN_PASSWORD="admin"
            KEYCLOAK_PORT="8080"
            if ! command -v docker &> /dev/null; then
                echo "Docker is not installed. Installing Docker..."
                if [ -f /etc/os-release ]; then
                    . /etc/os-release
                    case "$ID" in
                        ubuntu|debian)
                            sudo apt update && sudo apt install -y docker.io
                            ;;
                        centos|rhel|fedora)
                            sudo yum install -y yum-utils
                            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                            sudo yum install -y docker-ce docker-ce-cli containerd.io
                            ;;
                        *)
                            echo "Unsupported distribution. Please install Docker manually."
                            continue
                            ;;
                    esac
                    sudo systemctl start docker
                    sudo systemctl enable docker
                    sudo usermod -aG docker $USER
                    echo "Docker installed successfully."
                else
                    echo "Unable to determine OS distribution. Please install Docker manually."
                    continue
                fi
            fi
            IP_ADDRESS=$(hostname -I | awk '{print $1}')
            sudo docker run -d -p ${KEYCLOAK_PORT}:8080 \
                -e KEYCLOAK_ADMIN=${KEYCLOAK_ADMIN} \
                -e KEYCLOAK_ADMIN_PASSWORD=${KEYCLOAK_ADMIN_PASSWORD} \
                --name keycloak \
                quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} start-dev
            echo "Waiting for Keycloak to be ready..."
            while ! curl -s http://localhost:${KEYCLOAK_PORT} > /dev/null; do
                sleep 5
            done
            echo "Keycloak setup complete!"
            echo "Keycloak is running on IP: ${IP_ADDRESS}"
            echo "Admin Console: http://${IP_ADDRESS}:${KEYCLOAK_PORT}/admin"
            echo "Default admin credentials:"
            echo "Username: ${KEYCLOAK_ADMIN}"
            echo "Password: ${KEYCLOAK_ADMIN_PASSWORD}"
            echo "IMPORTANT: Please change the admin password after logging in."
            ;;
        7)
            echo "Installing Kasm..."
            if ! command -v docker &> /dev/null; then
                echo "Docker is not installed. Please install Docker first."
                continue
            fi

            # Install Docker Compose
            echo "Installing Docker Compose..."
            sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            if ! command -v docker-compose &> /dev/null; then
                echo "Failed to install Docker Compose. Please install it manually."
                continue
            fi
            echo "Docker Compose installed successfully."

            cd /tmp
            if [ ! -f kasm_release_1.15.0.06fdc8.tar.gz ]; then
                echo "Downloading Kasm..."
                curl -O https://kasm-static-content.s3.amazonaws.com/kasm_release_1.15.0.06fdc8.tar.gz
                if [ $? -ne 0 ]; then
                    echo "Failed to download Kasm. Please check your internet connection and try again."
                    continue
                fi
            fi
            if [ ! -d kasm_release ]; then
                echo "Extracting Kasm..."
                tar -xf kasm_release_1.15.0.06fdc8.tar.gz
                if [ $? -ne 0 ]; then
                    echo "Failed to extract Kasm. Please check if the downloaded file is corrupted."
                    continue
                fi
            fi
            echo "Running Kasm installation..."
            sudo bash kasm_release/install.sh -e << EOF
y
y
admin
password
password
EOF
            if [ $? -eq 0 ]; then
                echo "Kasm installation completed successfully."
                echo "Default user 'admin' has been created with password 'password'."
                echo "Please change this password immediately after logging in."
                IP_ADDRESS=$(hostname -I | awk '{print $1}')
                echo "You can access Kasm by opening a web browser and navigating to:"
                echo "https://${IP_ADDRESS}"
            else
                echo "An error occurred during Kasm installation."
                echo "Please check the log file for more details: /tmp/kasm_install.log"
                echo "You can try running the installation manually with:"
                echo "cd /tmp/kasm_release && sudo bash install.sh"
            fi
            ;;
        8)
            echo "Exiting script. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac

    read -p "Press Enter to continue..."
done
