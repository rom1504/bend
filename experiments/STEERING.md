# Current frontier: Phase61 architectural compiler speed

**Installed Phase58 last01 remains verified and unchanged.** Direct JavaScript
is the default; explicit legacy JavaScript and native C remain available. Compiler
algorithms execute Bend source, without TypeScript fallback or a fabricated
checked sidecar on emitted B2. No PR comments or goal creation are authorized.

The user now authorizes ambitious compiler-speed improvements implemented in
Bend with maintained correctness. This supersedes Phase60's information-only
scope for new Phase61 work; prior survey results and closed evidence are not
rewritten. Root owns architectural design, source integration, target scheduling
and promotion. No Phase61 outcome is credited at this registration checkpoint.

[Registered hypotheses](phase61/) · [Research map](../implementation/phase61/research-map.md) ·
[Completed survey](../implementation/phase60/README.md) ·
[Installed release](../implementation/phase58/README.md).

## Baseline and established evidence

Selected installed attempt: `selfhost/build/phase58/checked-last01`.
Checked/derived B1 API: `641381f638f1f4c1c8b349bef06502b42738c1c7feff0391f2e09b90f4ef282a`.
Source: `85454aab7a6ef25d1e78970b1c24d68ac2a90a23a4b39b64a30de311c2fc5091`.
Qualified B2/B3: `a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081`.
Upstream `018751270e800bc222a93dad7f257083ee53a5f7`; Node 24.18.0.
Both runtimes, ordinary driver and 17 native modules retain Phase56 bytes.

Phase58 retains constructor field placement, allocation-free intermediate query
misses/checked-owner fallback, exact scalar residual provenance, proved literal
continuations, bounded dependency deduplication and shared SCC workers. Its
all-literal/computed rollback tradeoff and queue-budget failures stay historical.
No width cutoff is selected. Complete source semantics, unsafe trust refusal and
fixed point remain distinct from kernel validity. Known TS NaN oracle defects
are explicit; a new candidate mismatch is not waived through that history.

The final Phase58 program corpus passed 23 sources / 45 points / 669 samples;
new/old equal-point ratio 0.985287, no point >10% regression. This is generated-
program timing, separate from the current compiler-request objective. Source
size and emitted-image size measure different things; no simplification claim.

Phase60 is complete/archived, not a compiler update: 138 clean processes / 552
requests across all 23 sources give combined-first equal-source B2/TS 2.461297,
range 2.103–3.049×. Every source is slower; later windows still warm. Checking/
completion is largest on 22/23 (611–726 ms); cache/identity adds 188–212 ms.
The ABI2 validated prefix is unused; cached parsed IR cannot resume checked state.
TS also checks Base, so rechecking alone does not explain the relative gap.

At the descriptive 5% self-family threshold, index CPU/allocation occurs on 23/23,
substitution allocation 22/23, String allocation 18/23, refs/uses 8/23. Metadata
is smaller (CPU 4/23; allocation none above 5%). Families, ancestor bins and wall
stages overlap: do not add or call them removable fractions. All 46 CPU count
views remain valid; 38 weighted views admit / 8 refuse. TS missing-node allocation
138,000 bytes remains unknown and in the denominator. Original reader failure
is retained. [Phase60 archive](../selfhost/tools/performance/phase60/artifacts/raw/publication.json)
passes reopened/member verification; raw writers closed 05:42:28 UTC October 7.

## Registered next work, before outcomes

1. **P61-001: complete checked frontend state.** Test verified Base-world/output/
   specialization/fresh/provenance extension against full checking. Reject stale
   seed identity, changed declarations/diagnostics or cross-request contamination.
   A source-only prefix skip is not this proposal.
2. **P61-002: compact owned contexts.** Count index width/visits, replacements and
   reconstruction before changing representation. Preserve dependent binders,
   quantities, source origins, beta-reduction and aliases. `core_rebuild` means
   no variable occurrence does not prove a subtree can be returned unchanged.
3. **P61-003: structured emission/ref transport.** Avoid demonstrated render/
   scan/render work only with equivalent structured dependency/use facts.
   Preserve demand/order/FFI, shared SCC capture/reentry and existing budgets.
4. **P61-004: efficient falsification loop.** Reuse Numeric recurrence + MapSet
   first-only, then add active raytrace with two rotated rounds. Prior measured
   whole CLI costs 17.53 s / 49.51 s exclude preparation/image generation and
   are not future guarantees. Lexer/Evening stay held out; all 23 stay the broad
   acceptance population. Do not install B2 merely to obtain a private fast loop.

Each record names the cheapest disproof. Implementation remains in Bend; one
changed factor and a real checked image precede independent focused controls and
clean latency/allocation comparison. New representations can change internals,
but exact public values/events/diagnostics/provenance/ownership must qualify.
Use current input/output identities where unchanged; explicit semantic comparison
is required where emitted bytes intentionally differ.

## Working limits and next review

No quantified Phase61 benefit or source promotion yet. Larger investigations are
now authorized, not limited to Phase60 counter collection. Review ownership/state
and demand contracts before expensive builds, then review focused failures and
clean contrasting screens before broad integration. Root sets the next target
allocation; records do not silently add jobs or a time budget.

Heavy jobs remain serial under one process-tree guard on CPU3 with private staging,
fresh paths and explicit resources. Data/source work avoids interference with
measurements. Preserve all 103 unrelated files, closed Phase58–60 (and earlier)
evidence, installed artifacts, rejected attempts and consumed producer bytes.
All new raw belongs to Phase61. Installed release stays unchanged until root
admits a selected candidate's semantic/B2/native/legacy/performance and release
qualification. Stage explicit owned paths only.
