#!/bin/bash
cd "$(dirname "$0")"
LOG_ROOT="${LOG_ROOT:-/mnt/c/Users/mppalas/Documents/patching-logs}"
mkdir -p "$LOG_ROOT"
SUMMARY="$LOG_ROOT/all_environments_$(date +%Y-%m-%d_%H-%M-%S).txt"
FAILED_ENVS=()
for inv in inventories/*/hosts.ini; do
  [ -f "$inv" ] || continue
  env_name="$(basename "$(dirname "$inv")")"
  echo "=============== Environment: $env_name ==============="
  INVENTORY="$inv" bash run.sh "$@"
  rc=$?
  if [ $rc -eq 0 ]; then
    echo "$env_name: OK" | tee -a "$SUMMARY"
  else
    echo "$env_name: FAILED (exit code $rc)" | tee -a "$SUMMARY"
    FAILED_ENVS+=("$env_name")
  fi
done
echo
echo "Summary file: $SUMMARY"
if [ ${#FAILED_ENVS[@]} -gt 0 ]; then
  echo "Environments with failures: ${FAILED_ENVS[*]}"
  exit 1
fi
echo "All environments finished OK"
