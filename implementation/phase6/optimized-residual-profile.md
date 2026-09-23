# Residual profile of the consolidated compiler

One bounded diagnostic completed at 2026-09-23 02:39:44 UTC and emitted the
exact expected 138,371-byte compiler-core library, SHA-256
`016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186`.
The API is the actual Phase 5 optimized release, `e2b5463678a2…`, with frozen
final05 host/runtime and canonical pinned Base. All recorded inputs are unchanged.
This is a profile, not a controlled timing comparison: broad backend correctness
work overlapped, and instrumentation/pre-discovery change the request boundary.
The unchanged bounded launcher completed in 24.012 seconds under its 180-second cap.

The plan [P6-001](../../experiments/phase6/P6-001-optimized-residual-profile.md)
was written before launch, but its manually entered02:50 timestamp was an error:
actual launch was02:39:20.468 and finish02:39:44.484UTC. The original plan bytes
remain unchanged; a separately dated correction is retained in the evidence.

## What is still expensive

| Exclusive sampled function/category | Share of sampled interval |
| --- | ---: |
| Generated `run_loop` trampoline |18.80%|
| Garbage collector |9.67%|
| Guarded native `String.eq` |5.75%|
| Main closure in `core_subst_stable` |3.36%|
| Generic `kc` choice |3.35%|
| Core term construction `kt` |2.77%|
| `String.starts_with` |2.65%|

These are exclusive profiler labels, not independently removable fractions.
Anonymous closure attribution comes from inspecting the exact generated source
at the recorded line. Sampling intervals can include descheduling and cannot
establish CPU percentages under concurrent work. Lower-ranked frames and raw
samples are retained; this table does not aggregate hidden costs into a claim.

The top-level check call took7.058seconds and annotation5.125seconds in this
instrumented request; loading1.979, library emission1.969, parsing1.141 and layout
0.864seconds. These spans include ABI handling. They describe this 60,909-byte
component, not whole-source speed or an optimization ceiling. Total observed
request was19.776seconds; prior source/profile timings must not be divided into
this observation to invent an improvement.

## Mechanism and next test

In the upstream-generated optimized compiler, `kc` still receives two freshly
constructed `run_clo` functions. `core_subst_stable` nests these for Var,
children, App and canonical-shape decisions. The trampoline then calls `kc`,
which returns another bounce to the chosen closure. The existing equality
specialization removes comparison reconstruction but leaves this control flow.
The Bend self-emitter already lowers proven choice patterns directly, so this
specific issue concerns the chosen bootstrap-generated default. It is distinct
from public H's staged matcher arguments and the previously rejected private
substitution-worker pilot.

P6-002 tests a source-level way to expose direct Boolean branches to the pinned
bootstrap emitter, while retaining every check/traversal in its old order. Its
first checked build rejects matching a locally bound Boolean; this is retained,
and the next candidate must use explicit helper parameters as required by the
language. No source change is promoted by the profile. General memoization,
whole-AST representation changes and unchecked generated rewrites do not follow
from these samples.

The [next performance design](../../design/phase6/residual-performance.md)
ranks branch lowering, repeated immutable facts and identifier/index work, with
separate invariants and cheap falsifiers. The established whole-source ratio
remains6.03× TypeScript until a new controlled full-source experiment says otherwise.

## Preservation and review

[The durable archive](profile-evidence/manifest.json) preserves 25 historical file
identities in 23 objects (1,003,774 compressed bytes), including raw V8 samples,
exact output, consumed APIs/host/tools, configuration and timestamp correction.
[Independent review](profile-and-release-review.md) recomputes the seven table
shares from all 1,761 samples/time deltas and verifies their actual source frames.
All archived objects and original input bytes were rechecked.
