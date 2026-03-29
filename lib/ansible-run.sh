# Shared ansible run logic.
# Expects: tags=() array set by caller, working directory is repo root.

all_tags=()
vault_tags=()

for entry in "${tags[@]}"; do
  tag="${entry%%:*}"
  all_tags+=("$tag")
  if [[ "$entry" == *":vault" ]]; then
    vault_tags+=("$tag")
  fi
done

verbosity=""
if [[ "$1" =~ ^-v{1,4}$ ]]; then
  verbosity="$1"
  shift
fi

if [ -n "$1" ]; then
  requested_tags="$1"
  shift
else
  fzf_list=()
  for entry in "${tags[@]}"; do
    tag="${entry%%:*}"
    if [[ "$entry" == *":vault" ]]; then
      fzf_list+=("$tag (vault)")
    else
      fzf_list+=("$tag")
    fi
  done

  selected_entries=$(printf '%s\n' "${fzf_list[@]}" | fzf --multi --prompt="Select tags: ")

  if [ -z "$selected_entries" ]; then
    echo "No tags selected."
    exit 1
  fi

  requested_tags=$(echo "$selected_entries" | sed 's/ (vault)//g' | paste -sd,)
fi

needs_vault=false
IFS=',' read -ra selected <<< "$requested_tags"
for sel in "${selected[@]}"; do
  for vt in "${vault_tags[@]}"; do
    if [[ "$sel" == "$vt" ]]; then
      needs_vault=true
      break 2
    fi
  done
done

extra_flags=()
if $needs_vault; then
  extra_flags+=("--ask-vault-pass")
fi

ansible-galaxy collection install -r ansible/collections/requirements.yaml

ansible-playbook ansible/local.yaml -i ansible/inventory.ini --tags "$requested_tags" --ask-become-pass ${verbosity} "${extra_flags[@]}" "$@"
