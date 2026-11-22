#!/usr/bin/env bash
# Memory-safe wrapper for heavy native self-hosted compiler runs (`n2`).
# Shares `/tmp/agy_heavy_mem.lock` with `locked_bun.sh` and `locked_node.sh`
# so heavy native compiles don't stack RSS with Bun/Node builds.
set -euo pipefail
exec flock /tmp/agy_heavy_mem.lock "$@"
