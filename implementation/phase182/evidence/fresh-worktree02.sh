#!/usr/bin/env bash
set -euo pipefail
p182_root=/home/ai/bend2/build/publish/bend
p182_tree=$p182_root/selfhost/build/phase182/fresh-tree02
p182_commit=$(git rev-parse HEAD)
git worktree add --detach --no-checkout "$p182_tree" "$p182_commit"
git -C "$p182_tree" sparse-checkout init --cone
git -C "$p182_tree" sparse-checkout set selfhost/src selfhost/manifests selfhost/dist selfhost/tools/build selfhost/tests/compiler selfhost/tests/phase149
git -C "$p182_tree" checkout --detach "$p182_commit"
python3 -B selfhost/tools/build/fresh-worktree.py --origin "$p182_root" --worktree "$p182_tree" --commit "$p182_commit" --out "$p182_tree/selfhost/build/qualification"
