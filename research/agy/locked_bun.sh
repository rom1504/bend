#!/usr/bin/env bash
# Memory-safe serialized + time-bounded wrapper for `bun bend2/main.ts`.
# Shares `/tmp/agy_heavy_mem.lock` with `locked_node.sh` so concurrent agents
# never stack Bun (~3 GiB) + Node (~1.5 GiB) RSS and trigger systemd MemoryHigh.
set -euo pipefail
exec flock /tmp/agy_heavy_mem.lock timeout 60 /home/ai/bend2_agy/selfhost/.assets/bin/bun /home/ai/bend2_agy/bend2/main.ts "$@"
