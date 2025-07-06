#!/bin/bash

# This script installs or upgrades the host for running Ansible playbooks using ansible-pull.
set -e

# Navigate to the parent dir of this script
cd "$(dirname "$0")/.."

# Ensure latest changes have been pulled
git pull

# Install necessary packages
sudo apt-get update
sudo apt-get install -y git pipx

sudo pipx ensurepath
source ~/.bashrc

# Install Ansible using pipx
pipx install --include-deps ansible

# Install Ansible Galaxy requirements
ansible-galaxy install -r ./ansible/requirements.yaml

# Install Ansible collections
ansible-galaxy collection install -r ./ansible/requirements.yaml

# Run the Ansible playbook
ansible-playbook ./ansible/playbook.yaml -i localhost, --connection=local