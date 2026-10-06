#!/bin/bash
cd "$(dirname "$0")"
export ANSIBLE_HOST_KEY_CHECKING=False
INVENTORY="${INVENTORY:-inventory.ini}"
mkdir -p logs

STAMP="$(date +%Y-%m-%d_%H-%M-%S)"
export ANSIBLE_LOG_PATH="logs/ansible_${STAMP}.txt"

# One log file per server (every step, success or failure)
HOSTLOGS="logs/hosts_${STAMP}"
mkdir -p "$HOSTLOGS"
export ANSIBLE_CALLBACKS_ENABLED="community.general.log_plays"
export ANSIBLE_LOG_FOLDER="$HOSTLOGS"

MARKER="$(mktemp)"

echo "Inventory: $INVENTORY"
echo "Detailed log: $ANSIBLE_LOG_PATH"
echo "Per-server logs: $HOSTLOGS/"

ansible-playbook -i "$INVENTORY" playbook.yml "$@"
RC=$?

# Give every per-server log a .txt extension
for f in "$HOSTLOGS"/*; do
  [ -f "$f" ] && case "$f" in *.txt) ;; *) mv "$f" "$f.txt" ;; esac
done

# Bundle the logs of THIS run into one shareable file
SHARE="logs/share_${STAMP}.tar.gz"
REPORT="$(find logs -maxdepth 1 -name 'patching_*.txt' -newer "$MARKER" 2>/dev/null | head -1)"
if [ -n "$REPORT" ]; then
  tar czf "$SHARE" "$REPORT" "$ANSIBLE_LOG_PATH" "$HOSTLOGS"
else
  tar czf "$SHARE" "$ANSIBLE_LOG_PATH" "$HOSTLOGS"
fi
rm -f "$MARKER"
echo "Shareable logs: $SHARE"

exit $RC
