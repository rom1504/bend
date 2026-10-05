# Current compiler: Phase51; Phase52 direct backend in progress

On 2026-10-05 the user authorized the [Phase52 direct-backend prototype](../design/phase52/direct-javascript.md),
then full implementation if the value is demonstrated. The one-hour prototype
and three-hour full implementation are requested planning checkpoints. Keep the
existing compatibility backend available and make the upstream-compatible direct
interface explicit. The [live report](../implementation/phase52/README.md) records
its gates. The prototype eight-point screen is 1.03522× TS versus same-run Phase51 5.23997×; full-corpus and semantic qualification are pending. No promotion yet.

Phase51 is installed; release verification, 42 CLI checks and portable replay
pass. See the [report](../implementation/phase51/README.md),
[results](../implementation/phase51/results.md),
[runtime proof guide](../docs/self_hosted/v8-guided-runtime.md) and
[portable benchmark guide](../selfhost/tools/performance/phase51/README.md).
Preserve all 103 unrelated starting files and closed historical evidence.
No PR comment is authorized. Phase51 is complete and its raw evidence is closed;
new work and target output belong exclusively to Phase52.

API: `c15718cbf3e744e47c0795d7d78db6351a61c21983f53ec9c722272782dba061`.
Runtime: `3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46`.
Target: `018751270e800bc222a93dad7f257083ee53a5f7` (after Bend2.0.34).

## What is selected

All RNFA04 representations remain. Only the IO application body moves to a
helper; contextual roots reuse a fresh String check through a private identity.
Argument slots are read before validation; only inert scalar predicates intervene
before dependency validation. Other checks and fallbacks remain. No permission
is cached across public calls. Bend code lines/definitions are unchanged; two
comments and six runtime lines are added. There is no new IR pass or name-based
program recognizer. See [accounting](../implementation/phase51/accounting.md).

Focused controls, all eight maintained suites and resolved agreement on 81 backend
outcomes pass: 69 execution passes, eight N/A, four shared failures. Native Clang permission
refusals are preserved and resolved by a 21-case retry. The 3,026-main/196-broader
frontend inventories remain historical. This is a checked B1 derivative, not a
new self-emitted fixed point. Native IO.args and broader GPU/proof validity remain
open. Counts have overlapping scopes; do not add them as unique tests.

## Current evidence

All 669 samples pass across 45 points / 23 sources. Fresh paired slowdown improves
3.007942× → 2.927825× TS by equal point (2.66% less time). Equal-source slowdown
improves 4.077637× → 3.929390×. Historical RNFA04 was 2.678937× in another run;
its unchanged output now measures 3.007942×. Do not chain ratios across campaigns.

34 medians improve, 11 regress; worst regression 2.65%. Unicode16/64 gain 1.242× /
1.083×. Evening gains 1.460× under the standard warmup but only 1.0477× after
32,768 fixed-work warmup calls. It contributes 31.1% of the net logarithmic gain;
the other 44 points gain 1.0192×. Evening allocation is flat at about 177 KB/call.
This is useful incremental progress, not typical-program or universal parity.

## What we learned and what to test next

1. **Guards:** Phase49/50 show guard dominance in 11/45 points, but below 5% in 16.
   Descriptor batching lost. Same-entry proof reuse works without weakening
   observations. The next major gain requires a source/runtime effect proof of
   fewer required checks or wider safe amortization. Dependency names alone do
   not justify omitting String checks; cross-call host permission is not cached.
2. **Generic transport:** IO-only extraction crosses V8's inlining threshold.
   Four-helper extraction also inlines but displaces useful force inlining and
   loses. Allocation remains. Investigate ordinary closure/vector/constructor
   transport with saved-output ablations and complete boundary controls before
   another compiler pass. Require actual hot-path activation and clean speed.
3. **Producer/consumer transport:** Expression allocation remains a distinct
   opportunity. Earlier tuple transport reduced allocations but introduced shared
   context loads/stores and lost speed. Test caller-local values before a broad
   convention; fewer constructors alone are not enough.
4. **Measurement:** Keep clean timings separate from profiles. Warmup-sensitive
   small effects need longer fixed-work checks. Use the existing short loops,
   one checked build and one final full comparison; full45 costs about 19 minutes.

The [Phase49 V8 investigation](../implementation/phase49/README.md),
[Phase50 all-point survey](../implementation/phase50/README.md),
[Phase48 remaining work](../implementation/phase48/remaining-opportunities.md) and
[compiler research](../research/compilers_architecture_and_techniques/README.md)
retain supporting evidence and rejected alternatives. Keep JavaScript primary;
the [JS/C study](../implementation/phase46/README.md) showed allocation/call
transport must improve before switching backend. No new compiler-throughput gain
is established in Phase51.
