#!/bin/bash
cd "$(dirname "$0")"
export ANSIBLE_HOST_KEY_CHECKING=False
INVENTORY="${INVENTORY:-inventory.ini}"
LOG_ROOT="${LOG_ROOT:-/mnt/c/Users/mppalas/Documents/patching-logs}"
ENV_NAME="${ENV_NAME:-$(basename "$(dirname "$INVENTORY")")}"
[ "$ENV_NAME" = "." ] && ENV_NAME="default"
STAMP="$(date +%d-%m-%YT%H-%M-%S)"
ENV_DIR="$LOG_ROOT/$ENV_NAME"
STAGE="$(mktemp -d)"
mkdir -p "$ENV_DIR" logs
export ANSIBLE_LOG_PATH="$ENV_DIR/$ENV_NAME-detailed-$STAMP.txt"
export ANSIBLE_CALLBACKS_ENABLED="community.general.log_plays"
export ANSIBLE_LOG_FOLDER="$STAGE"
MARKER="$(mktemp)"
echo "Environment: $ENV_NAME"
echo "Inventory: $INVENTORY"
echo "Logs folder: $ENV_DIR"
export AWS_PROFILE="${AWS_PROFILE:-ansible-patching}"
aws sts get-caller-identity >/dev/null 2>&1 || aws sso login --use-device-code
ansible-playbook -i "$INVENTORY" playbook.yml "$@"
RC=$?
for f in "$STAGE"/*; do
  [ -f "$f" ] || continue
  host="$(basename "$f" .txt)"
  if [ "$host" != "localhost" ]; then
    cp "$f" "$ENV_DIR/$host-$STAMP.txt"
  fi
done
REPORT="$(find logs -maxdepth 1 -name 'patching_*.txt' -newer "$MARKER" 2>/dev/null | head -1)"
if [ -n "$REPORT" ]; then
  cp "$REPORT" "$ENV_DIR/$ENV_NAME-summary-$STAMP.txt"
  rm -f "$REPORT"
fi
rm -rf "$STAGE" "$MARKER"
exit $RC
