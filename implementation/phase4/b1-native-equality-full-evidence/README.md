# Experimental derived-B1 complete-source evidence

`raw.tar.gz` preserves the full-source report, request/config/worker, actual
emitted compiler bytes, stdout/stderr, every consumed regular artifact, both
original fixed-point outputs, checked source/proofs, runtime/Base, validated
caches and read-only audit tools. Node remains an externally identified
executable; its exact path and hash are recorded rather than bundling it.

- Archive size: 2,235,625 bytes.
- SHA-256: `bd891fac5c6c874d95621c141f2e858af2f0d2b2c3de2d247db88fe1d8e21a8a`.
- Verified members: 255 regular files.

The archiver reopened the actual compressed archive and verified its complete
member set, safe relative paths, byte counts and SHA-256 values, then rechecked
source identities. The manifest maps each member to its original file identity.

Actual output: 1,143,517 bytes, SHA-256
`b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8`. It is byte-identical to both original checked fixed-point
outputs. This is one complete-source correctness observation through an
experimental derived B1. `newBootstrap:false` remains explicit. The archive
creates neither a fresh checked bootstrap nor a paired performance comparison.

Evidence can be inspected after extraction anywhere. Exact execution still
requires the recorded Node, canonical source/Base/runtime/tool paths and pinned
upstream inputs; relocation does not waive identity checks.
