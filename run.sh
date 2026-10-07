#!/bin/bash
cd "$(dirname "$0")"
export ANSIBLE_HOST_KEY_CHECKING=False
INVENTORY="${INVENTORY:-inventory.ini}"
LOG_ROOT="${LOG_ROOT:-/mnt/c/Users/mppalas/Documents/patching-logs}"
ENV_NAME="${ENV_NAME:-$(basename "$(dirname "$INVENTORY")")}"
[ "$ENV_NAME" = "." ] && ENV_NAME="default"
STAMP="$(date +%Y-%m-%d_%H-%M-%S)"
ENV_DIR="$LOG_ROOT/$ENV_NAME"
RUN_DIR="$ENV_DIR/_runs/$STAMP"
mkdir -p "$RUN_DIR/servers" logs
export ANSIBLE_LOG_PATH="$RUN_DIR/ansible_detailed.txt"
export ANSIBLE_CALLBACKS_ENABLED="community.general.log_plays"
export ANSIBLE_LOG_FOLDER="$RUN_DIR/servers"
MARKER="$(mktemp)"
echo "Environment: $ENV_NAME"
echo "Inventory: $INVENTORY"
echo "Logs folder: $ENV_DIR"
ansible-playbook -i "$INVENTORY" playbook.yml "$@"
RC=$?
for f in "$RUN_DIR"/servers/*; do
  [ -f "$f" ] || continue
  case "$f" in
    *.txt) ;;
    *) mv "$f" "$f.txt"; f="$f.txt" ;;
  esac
  host="$(basename "$f" .txt)"
  if [ "$host" != "localhost" ]; then
    mkdir -p "$ENV_DIR/$host"
    cp "$f" "$ENV_DIR/$host/$STAMP.txt"
  fi
done
REPORT="$(find logs -maxdepth 1 -name 'patching_*.txt' -newer "$MARKER" 2>/dev/null | head -1)"
[ -n "$REPORT" ] && mv "$REPORT" "$RUN_DIR/summary_report.txt"
TMP_TAR="$(mktemp --suffix=.tar.gz)"
tar czf "$TMP_TAR" -C "$RUN_DIR" .
mv "$TMP_TAR" "$RUN_DIR/share.tar.gz"
rm -f "$MARKER"
echo "Shareable archive: $RUN_DIR/share.tar.gz"
exit $RC
