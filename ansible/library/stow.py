#!/usr/bin/python

from ansible.module_utils.basic import AnsibleModule
import os


def is_stowed(source_dir, target_dir):
    """Check if all entries in source_dir are correctly stowed to target_dir.

    Stow uses tree folding: if a directory in the target contains only links
    from one package, stow creates a single symlink to the directory rather
    than individual file symlinks. We must account for this by checking
    whether the resolved target path lands inside the source tree.
    """
    for entry in os.listdir(source_dir):
        source_path = os.path.join(source_dir, entry)
        target_path = os.path.join(target_dir, entry)

        if os.path.islink(target_path):
            if os.path.realpath(target_path) == os.path.realpath(source_path):
                continue
            return False
        elif os.path.isdir(target_path) and os.path.isdir(source_path):
            # Stow split this directory — recurse to check children.
            if not is_stowed(source_path, target_path):
                return False
        else:
            # Missing, or real file where symlink should be.
            return False

    return True


def force_remove_conflicts(source_dir, target_dir):
    """Remove non-symlink files/dirs at target paths that conflict with stow."""
    removed = []
    for entry in os.listdir(source_dir):
        source_path = os.path.join(source_dir, entry)
        target_path = os.path.join(target_dir, entry)

        if os.path.islink(target_path):
            continue
        elif os.path.isdir(target_path) and os.path.isdir(source_path):
            removed.extend(force_remove_conflicts(source_path, target_path))
        elif os.path.exists(target_path):
            os.remove(target_path)
            removed.append(target_path)

    return removed


def main():
    module = AnsibleModule(
        argument_spec=dict(
            folders=dict(type="list", elements="str", required=True),
            target=dict(type="str", default=None),
            dotfiles_dir=dict(type="str", required=True),
            force=dict(type="bool", default=False),
        ),
        supports_check_mode=True,
    )

    folders = module.params["folders"]
    target = module.params["target"] or os.path.expanduser("~")
    dotfiles_dir = module.params["dotfiles_dir"]
    force = module.params["force"]

    changed = False
    actions = []

    for folder in folders:
        source_dir = os.path.join(dotfiles_dir, folder)

        if not os.path.isdir(source_dir):
            module.fail_json(msg="Source directory does not exist: %s" % source_dir)

        if is_stowed(source_dir, target):
            continue

        changed = True

        if not module.check_mode:
            if force:
                removed = force_remove_conflicts(source_dir, target)
                for path in removed:
                    actions.append("removed %s" % path)

            rc, stdout, stderr = module.run_command(
                ["stow", "-R", "-t", target, folder],
                cwd=dotfiles_dir,
            )
            if rc != 0:
                module.fail_json(
                    msg="stow failed for folder '%s': %s" % (folder, stderr),
                    rc=rc,
                    stdout=stdout,
                    stderr=stderr,
                )

        actions.append("stowed %s" % folder)

    module.exit_json(
        changed=changed,
        msg="; ".join(actions) if actions else "all folders already stowed",
    )


if __name__ == "__main__":
    main()
