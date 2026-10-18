# Phase107 claim boundaries

Read-only receipt/document review, 2026-10-18. No compiler or benchmark was run
for this audit. The coordinator's final report owns campaign completion; new
kernel/strength-reduction experiments still in progress are outside this note.

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

The [incumbent comparison](../../selfhost/build/phase107/legacy-latency02/report.json)
measures source-to-executable subprocess-wall sums of 0.376–0.390 seconds for
three native-QBE cases versus 0.584–0.624 seconds for the installed C/Clang path:
34.6–37.5% shorter. This satisfies the stated 25% goal on those three workloads,
with three paired rounds and independent outputs. It excludes initial
tool/package audit and image acquisition. No frozen, unrelated held-out source
campaign is established by these measurements; avoid claiming every original
1× success criterion is complete. The 28.345-second broader validation batch is
also distinct from a subsecond request and a universal ≤20-second edit loop.

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
point, or causal recursive acceleration. Constructed memory/closure IR is not
source-level admission of Bend memory/closure programs.

## Five metrics: precise statements

| Metric | Supported statement | Claim not established |
| --- | --- | --- |
| Generated-program speed | `measure07` measures 13 focused source/constructed-IR workloads against **raw experimental IR→Clang O2**; shared QBE is 2.65× faster than its raw QBE version but still 1.26× raw Clang time | Upstream Bend parity, representative 45-program speed, or universal runtime gain |
| B1 compilation speed | Source04 has measured native source-to-executable latency; kernel and warmed pipeline timings have separately named boundaries | A new matched upstream-built native B1 production scoreboard |
| B2 compilation speed | The installed compiler builds the experimental native image through C/Clang | A new QBE/Cranelift-built B2, same-source native fixed point, or refreshed production B2/upstream ratio |
| Conformance | Source/refusal, ABI, cache, independent model/native and mutation controls pass at their declared boundaries | Whole-language, GPU, scheduler or whole-compiler correctness; standalone IR validity is not memory safety |
| Simplicity | Shared IR and reusable Bend passes reduce architectural duplication opportunities; installed general compiler selection is unchanged | A demonstrated production line-count reduction or completed source census; the experimental implementation adds maintained code |

The [pipeline audit](../../selfhost/build/phase107/pipeline-audit01/report.json)
matches 69 complete IR/JSON products, including 61 valid and eight invalid
inputs, and records 3.57–9.70× faster warmed JS optimizer calls on four cases.
Those timings compare verification placement, retain final checks and exclude
cloning/serialization/emission. They neither measure generated-program speed nor
prove the omitted intermediate checks redundant for all inputs. The identical
native/JS kernel also compares compiled versions of Bend implementation code,
not the handwritten upstream TypeScript compiler.

## Historical prose to reconcile

- `backend-options.md` says no object cache has started and separate-object cache
  controls remain required. Mark these paragraphs historical and point to
  `native-real-cache02` and [supervision.md](supervision.md).
- `demand-inlining.md` says its candidate has no measurement; later `artifacts06`
  and `measure07` use demand-aware composition. Link those as composed results,
  without inventing a standalone pass ablation.
- `inlining.md` contains prepared/pending wording for entry-first, reachability
  and bootstrap-API comparison. Preserve the chronology but link the actual
  later receipts (`audit02`, `reach-audit01`, `compatibility11`) as appropriate.
- The original phase README's JS-only frontend, unlinked-image and future cache
  statements describe early work; its final replacement should lead with the
  native source04 path and retain those earlier results as history.

These distinctions permit a strong result: a working native experimental
backend, materially shorter measured source builds, composable optimization and
tested object reuse. They do not require presenting the larger migration or
recursive-improvement research program as finished.
