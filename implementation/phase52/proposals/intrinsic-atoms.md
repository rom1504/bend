# Candidate05 hot-path audit and an unapplied intrinsic experiment

2026-10-05. This records the initially **unapplied, uncompiled and unexecuted**
proposal. Its exact candidate05 source inputs and patch hash are
in [intrinsic-atoms.json](intrinsic-atoms.json); the proposed change is
[intrinsic-atoms.patch](intrinsic-atoms.patch). The evaluation-order design is
in [intrinsic-next.md](../intrinsic-next.md).

After independent static review, the parent authorized applying the patch to
the maintained core/calls sources for candidate06. A separately preserved
[erased-suffix supplement](intrinsic-terminal-erasure.patch) applies the same
terminal-native fact when only erased formals remain. Both passed independent
static review; the [applied-source receipt](intrinsic-atoms-applied.json) records
the exact hashes before any build. Build, semantic and timing outcomes are
separate parent-owned gates; none is claimed by this note.

## Observed generated shapes

Inspected saved candidate05 modules under
`selfhost/build/phase52/prepared-direct05-full/modules/`, paired to the exact
TypeScript entries in `selfhost/build/phase52/reference01/manifest.json`.
These counts are static named intrinsic call sites inside the named functions;
they are not execution counts or evidence that V8 retains the calls.

| Candidate module / function | Direct line | Intrinsic call sites | Sites accepted by proposed atom grammar | Reference shape |
| --- | ---: | ---: | ---: | --- |
| mandelbrot / `mit` | 502 | 12 | 6 | U32 arithmetic and `Math.imul` inline, ordinary `asr8`/`sel` calls retained. |
| mandelbrot / `asr8` | 495 | 3 | 2 | Shifts and bitwise-or inline. |
| raytrace / `isect5` | 579 | 17 | 11 | Ordered local `Math.fround` arithmetic; no F32 native wrapper calls. |
| raytrace / `trace` | 847 | 113 | 50 | F32 operations inline through the ordinary recursive body. |
| local-row and editdist / `cell`, `cell.f1`–`cell.f4`, `row` | 531–596 | 12 each | 10 each | Direct Array tuple/access expressions and U32 arithmetic. |

The counts use the current, unchanged candidate05 argument strings. Inlining
an inner call does not make its resulting compound expression an atom, so the
prototype deliberately leaves outer nested calls intact.

For example, `mit` currently evaluates
`$jd$U32_46_mul(zr,zr)` inside ordinary `asr8`. The reference passes
`Math.imul(zr,zr) >>> 0` directly. In `cell`, the candidate calls the native
`Array.get` wrapper before the ordinary continuation helper; the reference
constructs `{$:"Tuple",fst:b,snd:b[j%b.length]}` at the caller. This can expose
tuple elimination and remove inline-budget demand, but it is a hypothesis until
the proposed compiler derivative is measured.

There is a separate raytrace difference. Reference `sx`, `sy`, `sz`, `sr` and
`skr` (lines 256–273) read five constant tables with `Math.min(i,8)`. Candidate05
(lines 621–682) selects numeric rows and executes conversions/arithmetic such as
`U32.to_f32`, `fl` and `F32.sub` in the chosen arm. This experiment does not add
constant tables or evaluate those source expressions at compile time. Therefore
the approximately twofold reported batch0 raytrace gap cannot be attributed to
wrapper calls from this inspection alone.

The parent reported preliminary candidate05/TS batch0 ratios of 1.756 for
mandelbrot, 2.068 for raytrace, 1.401 for local-pair and 1.415 for editdist.
These motivate inspection, not a causal or final full-corpus performance claim.

## Proposed source delta

`core.bend` adds one branch at `jd_call`: ask the unchanged `jd_intrinsic`
admission/template machinery only when every supplied generated value has one
of these exact forms:

- A decimal integer, `true`, `false`, or `null`.
- A generated `$a` or `$eta` name followed by one or more decimal digits.
- The exact emitted `JD_USE:id` wrapper around `$xid`, with the same numeric id.

The final rule preserves the original physical-line usage marker. It refuses
the same wrapper around `$JD.View` conversions, projected fields, global names,
calls, compound expressions, strings, negative numbers and floating expressions.
Those exclusions are conservative, not statements that every excluded form is
effectful. No workload name is tested.

An admitted template receives the original inert value strings, is wrapped in
parentheses, and omits the eliminated callee's `JD_REF`. All argument metadata
remains present. An unknown template or non-atomic operand emits the old named
call with its old bounce policy and reference marker. Intrinsic definitions
remain available for selected exports and actual surviving callers.

One `calls.bend` adjustment is necessary for declaration pruning: an exact
saturated native intrinsic adds no tail edge. The existing analysis already
treats its body as terminal native code, but currently still records incoming
source edges. Keeping those edges after `JD_REF` pruning would make the final
`jd_calls_context` refuse a missing native declaration. This proposal removes
only that redundant analysis edge; overapplication and unknown calls keep their
current analysis. Surviving runtime calls still retain their declarations via
`JD_REF` independently.

No operand is hoisted, no new IIFE is introduced, no operation is reordered or
constant-folded, and no wrapper/runtime ABI changes. The patch intentionally
does not solve full expression-to-statement lowering.

## First checks and stopping rule

Before targets, independently review the exact generated-form grammar and
native tail-edge change. Build once if authorized. Inspect actual output for
inlined leaf operations, surviving compound-operand calls, unchanged ordinary
source functions and correct exported/dead declaration handling.

Run the existing direct semantic controls plus focused inert/complex operands,
same-named source definitions, repeated operands, conditional templates,
partial application, Array aliasing and Math accessor ordering. Complex or
effectful operands must remain calls; a test should demonstrate that refusal.
Keep the known NaN/table discrepancy separate and visible.

Only then run a paired short screen for the four inspected sources plus
ordinary numeric/closure canaries. If it produces no useful gain, retain the
negative result and do not grow this classifier into an expression optimizer.
If it succeeds, the complete corpus and acquisition cost still decide promotion.

## Saved-module identities

| Module | Candidate05 SHA-256 | Reference SHA-256 |
| --- | --- | --- |
| mandelbrot | `9a6be9ed9bdf85ea815789ae0907a697ddc8305141ac66a4359cdd64a8e1f7db` | `037f070e948ab7701364b7413c624bca4327db0bc6171ac4523b906d2ae9e222` |
| raytrace | `58881611b19d1e4f773170317a4de8d7663002227e86a8664808434f94686cf8` | `87bd526f04705416db047a31eb4ccc186f1c90f5c911f57736a3216a7629ddd2` |
| local-row / local-pair | `5837ee6abfcdfd28655c2a4e275354f5d4d7d7eaad6be5f0b09eeb6f694174c9` | `e303d7add56bca3c62ab3a7d636f01b65007556f5a80d43d59f94018b4154de6` |
| editdist | `a3c3a11ee31596de02b07a5846852bac6638f7db2050bf02216c2fef563c98ff` | `33721b7770aa4e367896cf1b842cc8ec309dced3a2608e25c5709217474eabc6` |
