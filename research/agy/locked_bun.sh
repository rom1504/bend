#!/usr/bin/env bash
# Memory-safe serialized + time-bounded wrapper for `bun bend2/main.ts`.
# Valid compiler.bend builds finish in ~18-25s (~2-4 GiB); runaway type-check loops
# blow up RAM after ~45-60s. `flock` prevents concurrent builds; `timeout 60` stops
# any runaway loop well before OOM.
set -euo pipefail
exec flock /tmp/agy_bun_build.lock timeout 60 /home/ai/bend2_agy/selfhost/.assets/bin/bun /home/ai/bend2_agy/bend2/main.ts "$@"
