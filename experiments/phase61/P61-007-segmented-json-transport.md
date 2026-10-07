# P61-007 — Raw state segments and JSON-owned validation

Retrospectively indexed after root-authorized design/prototype and before actual
candidate compiler throughput qualification; this file is not claimed preregistered.
Owner callbacks; independent reviewer phase44_review. Decision investigate.

**Hypothesis:** Exact raw book/state segment hashing plus a fresh-JSON-only span
walker removes state reserialization and traversal allocations, saving at least50ms
on Numeric first-request cache reading without changing compiler semantics.

**Invariant:** Compiler/Base/path/ABI/range/producer/schema and all literal/Lambda
checks remain. Invalid optional state means full-check fallback. Only JSON.parse-
owned acyclic private trees use the narrower walker; public aliases/cycles/getters
keep original validators. State is identity-bound trusted-local data, not a hostile
cache proof certificate. Native carrier is independently scoped in P61-006.

**Disproof:** Any changed cache admission, required span traversal, invalidation,
source diagnostic/output, or whole first-request regression; a decode-only gain
is insufficient. Binary V8 transport is deferred until this simpler factor is tested.

[Design](../../design/phase61/cache-transport.md) ·
[Current implementation and source/control lineage](../../implementation/phase61/cache-transport.md) ·
[Frame03 pins](../../selfhost/tools/performance/phase61/cache/frame2/source02.json).

Root-run controls08 passed56 host groups; combined carrier controls09 passed57.
Harness failures06/07 and their successors are preserved. These tests do not
establish source resume correctness or a speedup. Actual checked-source bootstrap,
source differential controls and request timings remain pending. Root executes
under its external resource guard; author ran static parsing only on CPU0.

Reproduce the focused current host test with
`node selfhost/tools/performance/phase61/cache/controls09.mjs NEW_PHASE61_OUT`.
Its pinned private copies contain the actual codec; no fake compiler receipt or
Bend checkpoint proof is generated. See the linked report for input identities.
No installed release or default contract change follows from these observations.
