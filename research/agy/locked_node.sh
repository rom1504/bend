#!/usr/bin/env bash
# Memory-safe serialized wrapper for heavy Node `batch_emit.mjs` / fuzzer runs (~3-4 GiB cap).
set -euo pipefail
export NODE_OPTIONS="--max-old-space-size=4096"
exec flock /tmp/agy_node_emit.lock /home/ai/.nvm/versions/node/v24.22.1/bin/node "$@"
