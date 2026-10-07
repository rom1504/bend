# Campaign-stable verification successor

Current proposal: `make-method-v5.py`, producing a fresh method directory such as
`selfhost/build/phase61/latency-method04-v2`. The initial `make-method-v4.py` and
`latency-method04` remain a source-only precursor. Neither runner was executed.
The successor derives exact pinned method03 bytes and records every replacement.

Method03 reads the 123,655,872-byte Node binary through repeated runner and worker
input lists. Those reads are outside the compiler clocks but consume campaign
wall time. Validation identified six list checks per sample worker/launch; the
CPU/allocation helper additionally hashes Node for its diagnostic receipt.
Reported process-wall minus compiler-clock remainder is not a hash-only measure.
No savings have been measured for this proposal.

The new runner performs a full SHA for Node and fixed method/support tools at
campaign setup, records canonical path plus `dev`, `ino`, `size`, `mtimeNs`, and
`ctimeNs`, and verifies these exact stat values whenever those inputs are checked.
The worker verifies the same facts, exact `process.execPath`, and the existing
stack/heap arguments. `NODE_OPTIONS` must be absent. Diagnostics reuse this pinned
Node identity after a fresh stat check, retaining the original receipt fields.
The runner performs a final full SHA and stat check even after campaign failure;
failed final verification makes the campaign incomplete/failed. Other existing
verification calls remain full hashes.

The stable set contains only Node, this runner/worker/setup/profile, and the fixed
adapter/workflow/process/inventory/support/profile tools. Candidate API, driver,
Base, both runtimes, staged caches, current source/imports, upstream compiler
files, bindings, catalog, raw expected outputs, and qualification receipts remain
actively hashed. Preparation reuse still joins exact original image/config/case
facts; older method03 tool paths not in the new stable set remain fully hashed.
This is an accidental-change detector in the trusted local campaign model, not a
certificate against adversarial privileged filesystem changes.

No compiler import or request is added to runner setup. Private Base disk-cache
priming retains its excluded preparation scope. Every sample retains a fresh
process, explicit import/API load, one first ordinary request, configured later
requests, unchanged rotation and resource limits, and exact prepared-byte oracle.
CPU/allocation still capture import plus API load plus exactly one first request;
validation and hash/file writes remain outside inspector capture. Clean compiler
clocks and diagnostic clocks retain their definitions. Worker/process wall and
preflight costs use this different verification protocol and must be labeled.

Root can use the generated runner with unchanged method03 arguments and a fresh
output, including retained `--preparations .../preparation/report.json`. Run one
existing Numeric/Map clean screen first, then separately test CPU/allocation if
needed. Require all rows/expected bytes and final stable verification; preserve
any refusal. The factory is data-only; no measured result is implied by successful
factory generation or syntax checks.
