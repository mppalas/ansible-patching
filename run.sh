#!/bin/bash
# Runs the patching playbook and writes every step to logs/ansible_<date>.txt
# Usage: bash run.sh [ansible-playbook options]
#        INVENTORY=inventories/uat/hosts.ini bash run.sh --ask-vault-pass
cd "$(dirname "$0")"
export ANSIBLE_HOST_KEY_CHECKING=False
INVENTORY="${INVENTORY:-inventory.ini}"
mkdir -p logs
export ANSIBLE_LOG_PATH="logs/ansible_$(date +%Y-%m-%d_%H-%M-%S).txt"
echo "Inventory: $INVENTORY"
echo "Detailed log: $ANSIBLE_LOG_PATH"
ansible-playbook -i "$INVENTORY" playbook.yml "$@"

