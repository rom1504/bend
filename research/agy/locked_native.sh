#!/usr/bin/env bash
# Memory-safe serialized wrapper for heavy native self-hosted compiler runs (`n2`).
# Serializes heavy `n2` builds (~1.5 GiB) on `/tmp/agy_native_build.lock`.
set -euo pipefail
exec flock /tmp/agy_native_build.lock "$@"
