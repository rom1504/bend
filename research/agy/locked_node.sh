#!/usr/bin/env bash
# Memory-safe serialized wrapper for Node `batch_emit.mjs` / fuzzer / eval runs.
# Caps V8 heap to 1536 MiB by default (~60% lower RSS than 4 GiB) and serializes
# Node runs on `/tmp/agy_node_emit.lock` so small Node gates don't block behind
# long Bun/native builds (peak Bun 11G + Node 1.5G + n2 1.5G = 14G < 22G).
set -euo pipefail
MAX_MB="${AGY_NODE_MAX_MB:-1536}"
export NODE_OPTIONS="--max-old-space-size=${MAX_MB} --max-semi-space-size=32"
exec flock /tmp/agy_node_emit.lock /home/ai/.nvm/versions/node/v24.22.1/bin/node --stack-size=16384 "$@"
