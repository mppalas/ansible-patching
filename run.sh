#!/bin/bash
cd "$(dirname "$0")"
export ANSIBLE_HOST_KEY_CHECKING=False
INVENTORY="${INVENTORY:-inventory.ini}"
mkdir -p logs

STAMP="$(date +%Y-%m-%d_%H-%M-%S)"
export ANSIBLE_LOG_PATH="logs/ansible_${STAMP}.txt"
MARKER="$(mktemp)"

echo "Inventory: $INVENTORY"
echo "Detailed log: $ANSIBLE_LOG_PATH"

ansible-playbook -i "$INVENTORY" playbook.yml "$@"
RC=$?

# Bundle the logs of THIS run into one shareable file
SHARE="logs/share_${STAMP}.tar.gz"
REPORT="$(find logs -name 'patching_*.txt' -newer "$MARKER" 2>/dev/null | head -1)"
if [ -n "$REPORT" ]; then
  tar czf "$SHARE" "$REPORT" "$ANSIBLE_LOG_PATH"
else
  tar czf "$SHARE" "$ANSIBLE_LOG_PATH"
fi
rm -f "$MARKER"
echo "Shareable logs: $SHARE"

exit $RC
