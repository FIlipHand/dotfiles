#!/usr/bin/env bash
#
# Symlinks the config directories in this repo (kitty/, nvim/, tmux/, ...)
# into ~/.config, backing up any existing real files first.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

link_file() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        return
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP_DIR/$(dirname "${dest#"$TARGET_DIR"/}")"
        mv "$dest" "$BACKUP_DIR/${dest#"$TARGET_DIR"/}"
        echo "Backed up $dest -> $BACKUP_DIR/${dest#"$TARGET_DIR"/}"
    fi

    ln -s "$src" "$dest"
    echo "Linked   $dest -> $src"
}

for dir in "$REPO_DIR"/*/; do
    name="$(basename "$dir")"
    [ "$name" = ".git" ] && continue

    while IFS= read -r -d '' file; do
        rel="${file#"$REPO_DIR"/}"
        link_file "$file" "$TARGET_DIR/$rel"
    done < <(find "$dir" -type f -print0)
done

if [ -d "$BACKUP_DIR" ]; then
    echo
    echo "Existing files were backed up to $BACKUP_DIR"
fi
