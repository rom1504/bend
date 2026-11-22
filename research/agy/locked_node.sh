#!/usr/bin/env bash
# Memory-safe serialized wrapper for Node `batch_emit.mjs` / fuzzer / eval runs.
# Uses a shared heavy-RAM lock with `locked_bun.sh` so Bun + Node never stack
# RSS against systemd MemoryHigh, and caps V8 heap to 1536 MiB by default
# (override via AGY_NODE_MAX_MB=<mb> only for solo full-compiler probes).
set -euo pipefail
MAX_MB="${AGY_NODE_MAX_MB:-1536}"
export NODE_OPTIONS="--max-old-space-size=${MAX_MB} --max-semi-space-size=32"
exec flock /tmp/agy_heavy_mem.lock /home/ai/.nvm/versions/node/v24.22.1/bin/node --stack-size=16384 "$@"
