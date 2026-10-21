# Phase118: the next opportunity is preserving complete regions

The selected broad screen is3.00893× upstream C, down from the same-run4.31651×
Phase117. That is substantial progress, not evidence that parity is one small
patch away. The remaining slowdown varies strongly by family. All estimates
below are hypotheses unless an explicit experiment is named.

## 1. Preserve scalar representation across complete private call regions

Ray-active variants remain about8–9× upstream. The frozen source/machine audit
in `selfhost/tools/performance/phase118/remaining-ray-audit.md` identifies
intersection and nearest-object computation as the dominant old profile regions.
Current intersection code still moves floats through integer Term registers:
49 GPR/XMM moves,19 floating arithmetic instructions and a2072-byte stack frame
in the inspected function. These counts are static evidence, not a cycle model.

Earlier private float-lane experiments reduced49 moves to25 and the frame to24
bytes, but improved active ray only12.77% and raytrace4.17%. A typed ABI by itself
is therefore not evidence for a2× or4× gain. The stronger experiment compares:

1. Unchanged internal boundaries with typed private arguments/results.
2. A bounded fused numeric region exposing the same functions together, with
   typed locals, constant propagation and exact F32 operations throughout.
3. The current general Term fallback and pinned upstream machine code.

Keep public/runtime boundaries generic. Preserve call order, rounding, NaN,
negative zero and Bool encoding. Use small independent numeric controls and the
existing ray variants, then transfer to an unrelated numeric workload. Compare
hot instructions and clean runtimes, not QBE text size. Reject the architecture
if larger regions only move conversions to a different boundary.

This is the highest-value generated-code investigation after the current native
qualification. The missing capability is joint representation and call-region
optimization, not another spelling of sqrt: the runtime already uses sqrtss on
the ordinary path. Old sqrt-specific samples were only29/906; generic runtime
operation dispatch has additional unattributed samples and cannot all be called
sqrt overhead.

## 2. Make ownership-aware lowering economical for the compiler itself

The selected eight-source hosted prepared-request cost is1.12501× Phase117;
its admitted optimization/emission entry is1.18662×. Faster generated programs
have not automatically made experimentation cheaper. Measure the generated
compiler before extrapolating that cost to a native successor.

The next cheap diagnostic should separate original lowering/verification,
observer/cold-fact derivation, worker checking, catalogue scans and rendering.
Reuse one immutable request within the measurement process while retaining its
source/runtime identity. Do not bypass the independent verifier or introduce a
persistent multi-version cache before demonstrating amortization. A source-scale
control is necessary: a predicate can be cheap on45 small programs yet exhaust
host stack on the compiler catalogue.

The architecture opportunity is a small shared semantic plan consumed by C and
QBE, with one ownership/effect analysis per request. Phase118 already projects
mature plans; further sharing must remove duplicated computation or decisions,
not merely add another IR and conversion layer. No estimated native gain is
claimed until new N1/N2 request measurements exist.

## 3. Remove intermediate construction, then its lifetime work

The updated profiles expose constructor extension, field access, allocation and
control after generic RFC wrappers fall. Allocation-only destination passing is
selected; consumed-cell reuse and a destination-slot cursor did not establish a
sufficient additional broad benefit. Avoid endlessly specializing helpers.

The100× scope remains a producer/consumer contract that removes an intermediate
list or tree and all its allocation/ownership operations. Try one ordinary
pipeline plus an unrelated text/tree producer. Preserve strictness, sharing,
effects, error order and stack safety. This is a capability experiment with high
semantic risk, not a promised100× speedup. It requires an independently checked
fallback and evidence that the intermediate really disappears.

## What to stop or defer

- Do not search the existing four policy choices harder: Phase115 established
  little useful diversity. Create a new legal optimization capability first.
- Do not select dead-scalar cleanup just because QBE becomes shorter. Its new
  Boolean projections grow the Mandelbrot hot loop97→99 instructions and cost
  8.05% more in the matched longer screen; lexer is neutral. The old adjacent
  comparison rule cannot rescue these sites because XOR1 is their immediate
  producer. Both the negative result and corrected host Bool driver are retained.
- Do not adopt the cursor or cell-reuse ABI for a tiny isolated list benefit.
- Do not repeat full emission for runtime-only changes. Authenticate and reuse
  QBE/object/executable artifacts, then retain original output gates.
- Do not promote a native image from hosted program timings alone. Image
  acquisition, self-emission, independent semantics and request cost are distinct.
- Do not call successive optimization commits recursive acceleration. That needs
  evidence that adopting the faster tool reduces future validated research cost,
  including its acquisition and qualification overhead.
