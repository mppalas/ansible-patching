#!/bin/bash
# Runs the patching playbook and writes every step to logs/ansible_<date>.txt
cd "$(dirname "$0")"
export ANSIBLE_HOST_KEY_CHECKING=False
mkdir -p logs
export ANSIBLE_LOG_PATH="logs/ansible_$(date +%Y-%m-%d_%H-%M-%S).txt"
echo "Detailed log: $ANSIBLE_LOG_PATH"
ansible-playbook -i inventory.ini playbook.yml "$@"
