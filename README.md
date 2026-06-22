# Computer setup

## Triggering script on new computer

To trigger the script without first cloning the repository run the following. This will install the required dependencies and clone the coldb/ansible-omarchy repository. And trigger the ansible-runbook with the `install` tag. 

## Before running make sure to run

```bash
omarchy-refresh-pacman edge
```

## Install with

```bash
curl -sSL https://raw.githubusercontent.com/coldb/ansible-omarchy/main/ansible-run | sh
```

## Running from a clone

Use `./run`, not `ansible-playbook` directly. The wrapper installs the required Ansible collections, including `kewlfft.aur`, into the repo-local collection path before starting the playbook.
