# Phase192 correctness boundaries

This records the selected mechanisms and finite controls at the pre-native45
cutoff. [Selection01](../../selfhost/build/phase192/selection01.json) freezes
source SHA-256 `301435947ae813b64eebaf30610d2be4aa3be5b7ddd772bd0e68f1b6aac48c20`:
unary conversions/staging, shared addressing, canonical predicates and the
original H-region consumer. Scoped frames, path facts and wider floating regions
are excluded. Full native45, native reproduction and installed promotion are
separate gates; this document does not assert their completion.

## Selected contracts

| Mechanism | Required invariant and fallback |
|---|---|
| F32/U32 conversions | Admit only the exact runtime symbol/state/type/id/arity contract for op23 or58. Unary fallback reads offset0 only, so an eight-byte buffer suffices. Op23 zero-extends U32 before signed64 `CVTSI2SS`; op58 retains runtime `COMISS` behavior, sanitizes negative/out-of-range/NaN/infinite encodings before signed64 `CVTTSS2SI`, and publishes a zero-extended word. Signed32 conversion would fail above2^31. Only reserved r10/r11, xmm0/xmm1 and flags are clobbered. Arithmetic order and rounding points remain unchanged. |
| Operand staging | Reuse existing private-cell forwarding and global read/escape pruning after admitted operations become value nodes. Source mutation, overlap, unknown writes/calls and unresolved control boundaries invalidate facts. Setup facts never enter a loop iteration. Any remaining observation/escape retains necessary stores or the entire buffer. An operation being inline does not itself authorize deleting all prior stores. |
| Shared scaled address | At most16 original rows, exact whole-function use/write certificates, legal full-width scale/displacement, unchanged base/index/pointer and original memory order. Reject extra uses, U32 scale-wrap substitutions, parameters/setup dependencies and call/allocation/branch barriers. No load/store speculation or alias assumption. All original allocation/verifier dependencies remain. |
| Canonical predicates | Facts mean exactly integer0/1, not arbitrary nonzero truth. Writes replace destination facts; loads/offsets/allocations kill them; calls and unresolved joins forget them. Only certified pure copy diamonds and exact predicate comparisons simplify. Preserve each destination write, width, order and snapshot; no ownership or generic-Boolean ABI assumption. |
| H recursive regions | Query original `p114h_plan` from the checked shared context; preserve mode0 and complete-direct-worker precedence. Use its one-result, no-incoming/no-flags, arity1..8, clean/hygienic <=512-node body and <=8 closed-case admission. Do not fabricate `valid=true` or use the extended callable view. Any failed plan/availability/hygiene/emission check retains the original segment route. |

The H consumer translates to a local structured Again loop, not native CPU-stack
recursion. Snapshot arguments before parameter writes. Preserve frame-before-call,
FID/capture ordering, depth changes and continuation renaming. At depth zero,
return without popping the caller's frame; otherwise pop/read the FID, select its
exact case, pop/restore captures, bind result/pop status and resume. Unknown FIDs
keep the failure behavior. The public adapter retains argument loading and outer
runtime return. Original-body availability validation remains outside both routes;
generated worker/adapter references are also checked. Existing frame allocation,
call-clobber handling and parallel transfer lowering remain authoritative.

## Executed finite evidence

Counts below are observations per machine route, not distinct exhaustive inputs.
Each receipt binds its checked API, fixture and toolchain; these precede the
final selected source and do not automatically transfer native qualification.

| Receipt | Completed observations |
|---|---|
| [controls01](../../selfhost/build/phase192/controls01/report.json) | Float6 encoding/data checks;529,280 value/MXCSR observations each through direct ELF, rendered assembly and independent assembly. Staging27 data-only checks. Predicate11 data checks and1,331 independent C observations through each generated route. Original shared-address23 data checks cover the eight-row candidate. |
| [controls02](../../selfhost/build/phase192/controls02/report.json) | Shared-address v2:25 data checks including16-row admission/17-row refusal; twenty functions exercise joint/legacy/stack/oversize fallback placement, with2,400 independent C observations per direct/assembly route, including overlap, mutation, high bits and store-before-load. |
| [recursive-workers03](../../selfhost/build/phase192/recursive-workers03/report.json) | Six original-verifier/planner checks;84 independent C observations per route through depth100001. Check results, SP, rn, next, seq, reserved/environment fields, every state register and external caller stack guards, including depth zero. |
| [recursive-controls02](../../selfhost/build/phase192/recursive-controls02/report.json), [03](../../selfhost/build/phase192/recursive-controls03/report.json), [04](../../selfhost/build/phase192/recursive-controls04/report.json) | Completed rows compose six ordinary sources on both routes:02 supplies one/two/tree/ready,03 corrected sharing,04 corrected fallback. Reports02/03 remain incomplete overall. Actual admission probes show H-selected recursive owners and an old-H=0/view-H=0 dynamic-apply fallback. |

The float observer compares the pinned real runtime with an integer IEEE-754
decomposition oracle, separate C value/exception references and independent
assembly. Coverage includes39 edges,4096 deterministic raw values, rounding
modes and DAZ/FTZ settings, poisoned upper words and destination/buffer aliases.
This is finite masked-MXCSR evidence for the pinned toolchain. No independent
unmasked trap-handler qualification or portable C floating-environment theorem
is claimed. The six source-control receipts compare complete frozen literal
outputs; their `oracleExecuted=false` means the separate Python oracle was not
rerun by those drivers.

## Retained failures and excluded experiments

The original eight-row address matcher passed finite checks yet missed the real
eleven-row fold chain; v2 raises only the bound to16. This structural failure is
retained, not relabeled as a correctness failure or a runtime win.

`recursive-controls01` was killed by the unchanged2GiB process-tree RSS guard
(2,222,202,880 bytes observed). Compiler IR remained live while children ran;
the v2 driver gives emission an explicit lifetime and collects the host before
spawning children. It keeps the API/Base live and records host memory. This is a
harness residency fix, not a compiler or target memory improvement; no cap rose.
The initial sharing fixture put a local binding inside `do IO`; its corrected
version moves it before that block. The initial fallback duplicated a closure
using an invalid `+` parameter; v2 threads the linear closure to one base-case
application and uses a duplicable Boolean for the unchanged arithmetic oracle.
Both original failed sources and receipts remain. Worker attempts01/02 failed
checked-API/fixture-identity admission;03 is the completed worker gate.

Scoped frame expansion remains excluded after its mixed three-case screen and
compilation overhead. Its default-off refactor matches all three original H
objects exactly ([identity](../../selfhost/build/phase192/scoped-default-identity01.json)).
Review found exact allocation size alone insufficient: experimental v2 requires
exactly one definition across parameters and nested setup/body. The first
reentry observer called retained `p111_rt_frame` before runtime activation;
its active-descriptor lookup caused a failure in
[scoped-reentry01](../../selfhost/build/phase192/scoped-reentry01/report.json).
The [v2 observer](../../selfhost/tests/phase192/scoped-reentry-controls-v2.md)
activates a complete descriptor through public `p111_rt_main`, retaining the
real helper and the same84 result/state/stack observations. **Its machine gate
is pending at this document's cutoff; no passing scoped reentry claim is made.**

Path facts passed17 compiler-data checks and2,873 C observations per route in
[path-controls01](../../selfhost/build/phase192/path-controls01/report.json), but
lack measured production runtime benefit and are excluded. Wider XMM regions
are also excluded: reused mixed integer/F32 names still prevent the intended
hot placement. These exclusions do not change the existing selected XMM plan.

## Trust boundary

Original H verification/admission is executable compiler checking reused from
the established planner. It is not an independently checked theorem of the new
x86 consumer. Typed controls can exercise refusal data outside ordinary source
admission; source controls establish a different, valid-source boundary. Direct
ELF and assembly share the selected typed sequence, so agreement between them
does not independently validate selection. Independent C/integer/assembly
oracles and complete state sentinels reduce that common-mode risk within their
finite domains. Source acceptance, finite execution, machine identity, native
reproduction, timing and BendTT proof remain separate claims; this phase adds
no whole-compiler or H-consumer equivalence theorem.

## Later executed gates

The complete maintained selected source passes independent upstream checking in
`source-check01`. The final corrected six-source catalog now passes together in
`recursive-controls05`, including direct ELF and assembly routes. The correctly
activated runtime observer in `scoped-reentry02` passes84 observations per route,
including complete stack capture/FID contents and caller-state bytes. The
scoped optimization is still excluded for profitability. Its original observer
failure and missing-runtime-activation diagnosis remain retained.

All45 selected hosted-emission programs pass the frozen output oracles in
`selected-build01`; final native qualification is reported separately in the
main report. This addendum supersedes the earlier pending status only for these
explicitly named gates.
