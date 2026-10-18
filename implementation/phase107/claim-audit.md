# Phase107 claim boundaries

Read-only receipt/document review, 2026-10-18. No compiler or benchmark was run
for this audit. This note covers the closed receipts linked below, including the
final source gate. Later kernel/strength-reduction experiments retain their own
reports and are not silently included in these conclusions.

## Ambition ladder

The [1×/10×/100× design](../../design/phase107/native-ir-ambition-ladder.md)
uses those labels for scope, not measured speed factors.

**1×: the core useful-backend milestone is achieved.** Ordinary checked Bend
source lowers automatically to Nx IR; Bend implements lowering, optimization
and QBE emission. C and Cranelift consume the same experimental representation.
The current native source04 image performs the frontend without Bun on ordinary
QBE requests. One-time image acquisition still uses the installed compiler and
Clang. The real compiler's ASCII classification definitions are source inputs,
not hand-reconstructed IR algorithms.

The [native source controls](../../selfhost/build/phase107/native-controls03/report.json)
close with 32 graph/text comparisons, 180 independent output observations,
14 refusal observations and six live-Base controls. The selected set contains
eight admitted source cases and six deliberate unsupported families. This is a
finite scalar-language surface, not full language conformance. Its failed
`native-controls01` and `native-controls02` predecessors remain failed; only
the `03` report supplies this completed result.

The subsequent [held-out source gate](heldout-source-gate.md) froze three new
families and independent expectations in commit `8b3fba0` before any execution.
[Heldout01](../../selfhost/build/phase107/heldout01/report.json) passes all six
raw/fast QBE builds and 196 exact output checks without adaptation or exclusions.
Its receipt hash is `d33025b99f6617b83769c9ff2a3a7427c167a471f9bfab532c22b07745b173b7`.
The tested source set therefore has eleven admitted cases/families and the six
previous refusal families; the latter were not rerun in this new gate. It tests
fixed native image04, not every newer research optimization policy.

The [incumbent comparison](../../selfhost/build/phase107/legacy-latency02/report.json)
measures source-to-executable subprocess-wall sums of 0.376–0.390 seconds for
three native-QBE cases versus 0.584–0.624 seconds for the installed C/Clang path:
34.6–37.5% shorter. This satisfies the stated 25% goal on those three workloads,
with three paired rounds and independent outputs. It excludes initial
tool/package audit and image acquisition. The separate frozen source gate above
supplies final held-out correctness evidence, not a speed result or retroactive
held-out evaluation of policy selection. Its complete external guard costs 4.332s.
The 28.345-second broader validation batch remains distinct from a subsecond
request and a universal ≤20-second edit loop.

**10×: useful seeds, not the destination.**

- [Native object-cache controls](../../selfhost/build/phase107/native-real-cache02/report.json)
  pass 12 compilations/120 outputs. In raw unit mode a same-path helper edit
  rebuilds the changed helper while retaining runtime, entry and unaffected
  functions. ABI-salt changes invalidate program units; corrupt artifacts rebuild.
  Warm compilation reruns the frontend and lowering, then relinks. This is
  machine-object reuse, not incremental type checking or a persistent compiler.
- The cache experiment records unit backend work falling from 0.187s cold to
  0.00565s warm, but complete outer requests only fall from 0.568s to 0.377s.
  These are individual controls, not repeated estimates. Cold runner construction
  is included; raw units and optimized whole-object mode have different policies.
- Actual compiler helpers and a native optimizer kernel are exercised. A
  representative allocation-heavy compiler module, production ownership/runtime
  integration, arbitrary effects and general mutual-tail behavior remain absent.

**100×: architectural ingredients only.** Composable policies, explicit budgets,
verified reuse, independent semantic controls and scoped helper laws support a
future research system. They do not establish the design's train/held-out budget
search and payback gate, three independent compiler-edit campaign, verified
borrowing transformation, protected autonomous evaluator, QBE self-hosting fixed
point, or causal recursive acceleration. The [three-edit seed](../../experiments/phase107/P107-011-compiler-edit-replay.md)
was explicitly declined at preflight because the existing fixture contains only
two actual compiler helpers. Constructed memory/closure IR is not source-level
admission of Bend memory/closure programs. The final held-out correctness gate
does not substitute for a train/held-out optimization-search experiment.

## Five metrics: precise statements

| Metric | Supported statement | Claim not established |
| --- | --- | --- |
| Generated-program speed | `measure07` measures 13 focused source/constructed-IR workloads against **raw experimental IR→Clang O2**; shared QBE is 2.65× faster than its raw QBE version but still 1.26× raw Clang time | Upstream Bend parity, representative 45-program speed, or universal runtime gain |
| B1 compilation speed | Source04 has measured native source-to-executable latency; kernel and warmed pipeline timings have separately named boundaries | A new matched upstream-built native B1 production scoreboard |
| B2 compilation speed | The installed compiler builds the experimental native image through C/Clang | A new QBE/Cranelift-built B2, same-source native fixed point, or refreshed production B2/upstream ratio |
| Conformance | Source/refusal, ABI, cache, independent model/native and mutation controls pass at their declared boundaries; three frozen new source families add six builds/196 exact outputs on image04 | Whole-language, GPU, scheduler or whole-compiler correctness; standalone IR validity is not memory safety; the final gate does not retest every newer optimization policy |
| Simplicity | Shared IR and reusable Bend passes reduce architectural duplication opportunities; installed general compiler selection is unchanged | A demonstrated production line-count reduction; the experimental implementation adds maintained code and this audit supplies no new source census |

The [pipeline audit](../../selfhost/build/phase107/pipeline-audit01/report.json)
matches 69 complete IR/JSON products, including 61 valid and eight invalid
inputs, and records 3.57–9.70× faster warmed JS optimizer calls on four cases.
Those timings compare verification placement, retain final checks and exclude
cloning/serialization/emission. They neither measure generated-program speed nor
prove the omitted intermediate checks redundant for all inputs. The identical
native/JS kernel also compares compiled versions of Bend implementation code,
not the handwritten upstream TypeScript compiler.

## Historical prose and closing status

The final [phase report](README.md) supersedes its early JS-only/unlinked-image
checkpoint. Backend investigation paragraphs about unstarted caches describe
their earlier checkpoint; the implemented result is `native-real-cache02` and
[supervision.md](supervision.md). The inlining, demand and effectful notes now
link their later closing receipts while retaining the preparation history.
Hypotheses P107-001/002/003/005/006 likewise separate original predictions,
finite qualification and the measured or unestablished benefit. In particular,
`artifacts06`/`measure07` are composed results, not individual pass ablations.

These distinctions permit a strong result: a working native experimental
backend, materially shorter measured source builds, composable optimization and
tested object reuse. They do not require presenting the larger migration or
recursive-improvement research program as finished.
