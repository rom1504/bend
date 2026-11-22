#!/usr/bin/env bash
# Memory-safe serialized + time-bounded wrapper for `bun bend2/main.ts`.
# Serializes Bun (~11 GiB peak) on `/tmp/agy_bun_build.lock` so two Bun builds
# never stack to 22 GiB, while letting lightweight Node (1.5G) & n2 (1.5G) run.
set -euo pipefail
exec flock /tmp/agy_bun_build.lock timeout 90 /home/ai/bend2_agy/selfhost/.assets/bin/bun /home/ai/bend2_agy/bend2/main.ts "$@"
