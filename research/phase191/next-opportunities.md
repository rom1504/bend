# Next opportunities after the frozen Phase191 candidate

The strongest next bounded mechanism is **composing the existing F32 arithmetic
path with its remaining checked float-to-word conversion**. This can remove an
actual operation dispatch on every numeric iteration and the private argument
buffer that currently separates otherwise inline arithmetic. Next, improve
shared-address and accumulator placement in the already call-free fold loop.
Map needs removal of repeated representation/ownership work across worker
boundaries; more call-argument moves alone have now failed their runtime screen.

This is a read-only assessment, not a proposal to change the frozen candidate.
No compiler, target or sampler was executed. Only ELF inspection, existing
metadata and the retained Phase191 research were used. No new framework is
proposed.

## Exact comparison and negative evidence

The selected products are `extra-dev-build01`, compared with the mature-C
products recorded by [`references01`](../../selfhost/build/phase191/references01/manifest.json).
The source pins agree for local-fold, numeric256 and map32. All six executable
hashes were rechecked against the two manifests. The selected manifest is
[here](../../selfhost/build/phase191/extra-dev-build01/programs.manifest.json).
These are current selected development products, not claims about the later
qualification image until root establishes that identity separately.

| Case | Selected ELF SHA-256 | Mature-C ELF SHA-256 |
| --- | --- | --- |
| local-fold | `a6c497bbb3e277dc6fbd613fa0c13181596e327b7a367fb080cd1c5d86a484c0` | `ddf9f48cb789b857115946cc18a79796f344e747094b6ceff2e6f1229c8a0ffc` |
| numeric256 | `c3aad530823020a95d06d4de4586be7b8bfc52f275ec0f33b2104a52f5a527d0` | `b6c3e8cf8c9c36ef81bd03a32a9d8aaa3838c03537cba2dea45baa5e7ba748e3` |
| map32 | `5f7765581256471780db213bb99c2a1e0da42ecaa42eb2831bc5e4bffb4a8976` | `287f716a811ab642cf26554d1946edb7d7e164e9ba916ec3f4137aea505489fb` |

The [extra screen](../../selfhost/build/phase191/extra-summary01.md) puts these
selected cases at approximately 2.425x, 3.237x and 4.550x C. Reaching C would
require approximately 58.8%, 69.1% and 78.0% less selected runtime respectively.
Those figures describe the remaining gap, not attainable optimization budgets.

The rejected [call-move experiment](../../selfhost/build/phase191/call-summary01.md)
removed all 1,071 recognized snapshot sites and 7,036 static RSP instructions
across eight development programs, while preserving every static call count.
[Its offline audit](../../implementation/phase191/call-transfer-audit.json)
confirms actual linked Map examples. Yet its same-screen geometric ratio moved
only 3.16500x to 3.14713x C, about 0.56%, and map worsened from 4.51573x to
4.61243x C, about 2.14%, with map/ray dispersion flags. Root rejected this
complexity for its negligible overall benefit. This is a direct warning against
using whole-program transport counts as a runtime proxy.

The selected numeric regression remains real: roughly +8% against Phase190.
[Machine audit02](extra-machine-work.md) finds identical normalized instructions
in its recurrence and repetition wrapper, plus the same runtime object.
Layout is a hypothesis, not an established explanation. The separate
[alignment ablation](../../selfhost/build/phase191/mini-summary01.md) did not fix
it: the aligned role is 1.11328x baseline versus 1.08429x for the selected role
in that screen. Alignment was rejected; do not rerun arbitrary padding searches
as a substitute for eliminating the operation below.

## First: complete the numeric F32 value path

Selected `$direct.p37.numeric` is 122 instructions overall. Its positive
iteration remains 85 instructions, including one `p111_rt_op` call, as recorded
in audit02. Fresh inspection places its header at `0x408409` and its operation
call at `0x40858b`.

The body already emits four scalar SSE arithmetic operations, but transports
values repeatedly between GPRs and XMM registers. Before those four operations
it also constructs two-word argument buffers: eight stores, eight buffer-address
LEAs and eight source materializations, although the nearby inline arithmetic
uses the corresponding registers/immediates directly. The subsequent conversion
stores one more word into the same private buffer and dispatches operation
`0x3a` with arity one. These observations identify the boundary to investigate;
removing the earlier stores still requires the existing effect/escape analysis
to establish their unobservability on every path.

The operation identity can be recovered without consulting compiler source:
`p111_rt_op` dispatches through a signed-offset table at `0x41d09c`.
Entry `0x3a`, at `0x41d184`, contains bytes `14 88 ff ff`, giving destination
`0x4158b0`. That block checks arity one, loads an F32, compares it against zero
and `2^32`, converts a permitted value with **64-bit** `cvttss2si`, and publishes
the low word. The two constants at `0x41d434` and `0x41d440` are bits
`0x00000000` and `0x4f800000`. Rejected/unordered values reach `0x41622d`, which
returns zero. This is the finite float-to-U32 conversion path; a plain signed
32-bit conversion would be wrong above `2^31`.

Mature C's corresponding `WL_FID_...p37.numeric` keeps the recurrence value in
XMM registers, hoists arithmetic constants, performs explicit conversion guards
and `cvttss2si` directly, and unrolls the loop by two. Its main repeated region
is around `0x9db0`–`0x9e2c`; there is no per-iteration generic operation call.
Do not compare its two iterations with one x86 iteration or assume identical
branch paths for exceptional floating inputs.

**Bounded hypothesis:** extend the existing inline-operation and floating-value
contracts to this unary conversion, preserving the exact zero/out-of-range/NaN
behavior. Then let the established private-buffer and XMM passes eliminate the
now-unneeded staging. Start with conversion plus effect precision, not unrolling
or floating reassociation. The current recurrence's multiply/subtract order and
F32 rounding points must remain intact.

**Ceiling and risk:** no numeric physical profile was captured, so a runtime
percentage is not established. The immediate visible ceiling is one generic
call/return/dispatch and its staging per iteration, plus up to 24 preceding
buffer-construction instructions if their unobservability is proven. Continued
XMM placement is a second, separable opportunity. A 20–40% numeric runtime
reduction is a useful screening hypothesis, not a prediction or speedup claim;
it would still leave roughly 1.94–2.59x C at the current ratio. Implementation
risk is medium: conversion edges, NaNs, signed zero, infinities, values around
`2^31`/`2^32`, FP exception behavior, width publication and real-call barriers
need independent controls. Reject if it merely deletes cold code, leaves the
conversion dispatch in the actual loop, changes any edge result, or fails a
balanced runtime screen. Do not infer that fixing this structural gap explains
the separate +8% layout-sensitive regression.

## Second: the fold's shared scale and accumulator copies

Fresh selected disassembly of `$product.fold.loop` has header `0x4091f5`,
positive body `0x409232` and backedge `0x40927a`. Together they contain the same
23-instruction, call-free positive iteration described in
[machine audit01](machine-work.md), with no frame accesses.

The masked index is copied to `%r8`, explicitly multiplied by four, then used
with scale one for both load and store. The loaded word goes through `%r11`;
the accumulator is copied into `%rdi`, added, and copied back to `%r9`.
Mature C's actual loop `[0xf880,0xf8b2)` uses 15 instructions for **two** elements,
including direct indexed memory-add operations and a store for each element.

**Bounded hypothesis:** permit one shared scaled-address definition to feed a
load and a store, and preserve the accumulator's assigned home through the
load/add/copy pattern. This needs exact def/use and mutation checks for the small
window; it does not require more global colors or loop unrolling. A narrower
first experiment can target the explicit multiply while leaving all data reads,
stores and loop-state semantics unchanged.

**Ceiling and risk:** the obvious scale/copy cleanup is several instructions
per element, not the whole 2.425x gap. A 10–25% runtime screen is a hypothesis;
it cannot be derived from 23 versus 7.5 instructions because dependencies,
memory operations and unrolling differ. Full C-like loop generation is only an
aspirational bound until measured. Risk is low-to-medium for exact bounded
selection, higher for sinking/reusing values across mutation or reordering
loads/stores. Reject if the actual loop retains its multiply/copy chain or if
independent wrapped-index and base/value-alias controls fail. Unrolling belongs
after these simpler transforms demonstrate a remaining measured bottleneck.

## Map: representation boundaries, with an explicit small-leaf ceiling

The [existing physical profile](profile-assessment.md) is for Phase190 and Both,
not the selected Extra product. In Both, borrowed `Map.bit.go` is about 9.11%
of weighted samples, ownership/product helpers 17.69%, `p111_rt_op` 3.94%, and
`Map.ins.go`/`Map.seek.go` about 4.62%/4.34%. Unknown samples remain in the
2.13% denominator. These are approximate leaf shares, not disjoint source-owner
times or precise forecasts for Extra.

The selected large insertion worker still has 411 calls and 113 conditional
branches despite 199 removed frame loads. Its size does not prove hotness.
C's `WL_FID_...Map.bit.go` has a direct tagged-string traversal backedge
`0x166e0`–`0x1672a`; the heap-layout cases retain their required tests and loads.
Its later result path allocates/publishes a pair, with an allocation-miss call.
Thus C also has real representation and ownership work: calling all of its
`WL_*` functions scheduler overhead would be the grouping error already
identified in the profile assessment.

**Next mechanism to investigate:** eliminate a temporary product or redundant
constructor/field round-trip across a frequently executed private helper
boundary, using an existing ownership/layout contract. Prefer one complete
producer/consumer boundary whose frequency can be established. Merely shortening
its ABI argument transport is now an experimentally rejected explanation.
Do not weaken tag/ownership checks, assume a unique heap object without proof,
or repeat broad owned-take inlining without addressing the earlier negative
results retained in Phase186.

**Ceiling and risk:** even eliminating the entire measured bit-worker leaf at
zero replacement cost would yield only about 1.10x total speedup under unchanged
Both attribution; eliminating all ownership/product helper leaf time would give
about 1.21x. These are deliberately impossible best-case leaf ceilings, not
predictions. They cannot close a 4.55x C gap independently. A successful broad
representation change could affect generated callers as well, so those figures
do not cap a complete cross-boundary transformation. That project is higher
risk and needs its own exact-product profile and bounded ownership proof before
implementation. It ranks below the visible per-iteration numeric dispatch and
the fold's small, call-free selection window.

The frozen candidate should finish qualification unchanged. These are the next
experiments to prioritize, not additional Phase191 promotion requirements.
