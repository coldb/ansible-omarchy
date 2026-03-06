# Ansible Omarchy

## Rules

- Always update the `run` file's `tags` array when adding or removing Ansible tags. Make sure they sorted alphabetically.
- Always update `local.yaml` with `import_tasks` when adding or removing task files.
