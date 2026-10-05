# Server patching with Ansible

Updates Linux and Windows servers one at a time (serial: 1).

## Run

    export ANSIBLE_HOST_KEY_CHECKING=False
    ansible-playbook -i inventory.ini playbook.yml

Useful options:
- `--limit linux-laptop`  run only one server
- `--check`               dry run, changes nothing
- `--syntax-check`        validate the YAML only

## How it works

Per server: install updates -> reboot only if needed -> check again ->
repeat until nothing is left (max 4 reboots) -> print
"<host>: all updates are done. Rounds used: N" -> next server.
If a server fails, the run stops and shows which machine and step failed.

## Files

- playbook.yml           two plays: Linux and Windows
- tasks/linux_round.yml  one update round (loops itself)
- tasks/os_RedHat.yml    dnf update + needs-restarting check
- tasks/os_Debian.yml    apt update + /var/run/reboot-required check
- tasks/linux_done.yml   success message
- tasks/linux_fail.yml   fails if updates are still being installed after 5 rounds
- inventory.ini          real hosts and passwords (NOT in git)
- inventory.example.ini  template without secrets

## Windows categories

SecurityUpdates, CriticalUpdates, UpdateRollups

