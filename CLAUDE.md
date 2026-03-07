# Ansible Omarchy

## Rules

- Always update the `run` file's `tags` array when adding or removing Ansible tags. Make sure they sorted alphabetically.
- Always update `local.yaml` with `import_tasks` when adding or removing task files.
- Prefer using global facts from `setup.yaml` (e.g. `home_dir`, `username`, `dotfiles_dir`) instead of `ansible_env`. New facts can be added to `setup.yaml` when needed.
