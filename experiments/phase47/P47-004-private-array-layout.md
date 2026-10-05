# P47-004: private raw Array representation

Date: 2026-10-04. Initial pre-build status: unchecked, unmeasured, investigate.
Append-only checkpoints below distinguish later validation from promotion.
Follows P47-001's3.656-times saved-output backing-view result. The length-cache
variant adds no useful gain and is not implemented.

Use the existing complete typed region proof plus a bounded executable-node
audit. Admit only scalar public inputs/results, in-root canonical Array.new,
get/set operations and proved inert scalar helpers. Refuse external arrays,
escaping/composite results, opaque/residual calls, array constructors/matching,
and unmodeled nodes. All arrays then originate and stay inside that region.

Carry the raw backing array through private helper arguments, projections and
get/set results. Preserve allocation position, both Number conversions, length
reads and alias writes. This representation avoids a runtime cache, registry or
invalidation protocol. An immutable private book marker selects only the new
helper closure's lowering; generic and old private paths use the original book.

A fresh host guard runs before ordinary input/dependency checks and never
short-circuits under an outer region proof. It checks the existing full host
contract plus Array.fill and Number.isSafeInteger. Changed allocation/conversion,
reflection or prototype hooks refuse the new path. Refusal falls through to the
original wrapper and its original checks, preserving their observations.

The initial implementation duplicates helper declarations for eligible roots,
retaining the exact old path. Record generated size and compile cost explicitly;
do not call this a source-size improvement. Production validation requires
independent renamed arrays, zero trips, alias writes, escaped/public storage,
callbacks, hook replacement/reentry and dependency mutation. Measured canaries
and independent family inputs must show the representation actually activates.

Reject on semantic mismatch or disproportionate guard/size/cost; retain failed
attempts. Detailed contract/review and results are in implementation/phase47.


## Ordered stores: array02 checkpoint

The clean saved-output public-call experiment separates representation, store
shape, loop aliasing, and entry-guard costs. Median times per call were 90.854 µs
for worker23, 84.207 µs for checked array01, 63.809 µs for ordered store statements,
86.680 µs for an invariant backing alias, 63.986 µs for both changes, and 73.694 µs
for an explicitly unsafe guard bypass. These are diagnostic variants; the useful
isolated store-shape gain is approximately 1.32× over array01. The invariant alias
has no supporting gain. Preserve the separate 3.656× batch result and its different
amortization context; neither ratio predicts a universal compiler improvement.
Raw evidence: `selfhost/build/phase47/array-public-timing01/report.json`.

The [ordered-store design](../../design/phase47/array-write-statements.md) lowers
canonical private `JNative Array.set` in existing statement continuations.
Capture the erased slot as null, then array, index, and value in source order;
perform the original Number conversion, length access, and store; deliver the
same array to the existing vector destination or return. Keep expression-only
contexts unchanged. The LLVM/Go lesson is to expose ordered operations explicitly;
this rule does not hoist, combine, or eliminate effects and needs no general SSA
or alias-analysis framework.

The isolated `source-array02` snapshot passed the checked build and the unchanged
24 independent value oracles plus 39 boundary controls. Independent static review
passed. Its maintained canary timing is a separate pending result at this checkpoint.
The runtime guard and raw representation proof are unchanged. No installed-release
claim follows from these focused checks.

## Native source-App normalization: array03 checkpoint

The saved-array01 compiler diagnostic completed successfully and reproduced the
130,967-byte local-row module exactly. Region validity, scalar signature, required
Array.new dependency, and all twenty helper suffix checks passed. The first false
App was native `Array.new`; the first false node was its erased `Ref U32` argument.
The audit recognized `JNative` but some existing typed plans retained source Apps.
These completed-result records include pending worklists, so later false ancestor
records are not independent rejection causes. Raw evidence:
`selfhost/build/phase47/array-admission01/report.json`.

The separate `source-array03` change recognizes an App only when the existing
`j_region_local_native` proves the exact native definition, element type,
telescope and saturation, with its original native dependency still guarded.
Only that proved erased operand may be skipped. After whole-region admission,
normalize such Apps to `JNative` across the private root and every nonnative
helper; preserve Ann/JUnpack type metadata and the entire old path. Merely
whitelisting without normalization would risk mixing ordinary handles and views.

The 186-line `array-view.bend` module at SHA
`a76d93ef549a3ab0d9146de24ce3ae108cfab064a25036ae24a21aede6bba9db`
passed independent static review, and array03's checked build passed. Acquisition
still produced the identical local-row module with zero raw roots. Thus the
coverage outcome is unresolved: this checkpoint has not demonstrated the intended
activation or any pair/edit-distance speed gain. The separate, unconsumed v2
saved-compiler diagnostic records native proof subfacts before another source
change. Require an actual activation witness, renamed multi-array/record controls,
and clean maintained timing before treating the extension as useful.

See [the safety contract](../../implementation/phase47/array-safety-plan.md),
[coverage findings](../../implementation/phase47/array-coverage.md), and
[store-shape report](../../implementation/phase47/array-write-statements.md).


## Known helper Apps: array04 source checkpoint

The separate array03 diagnostic also completed with identical output. Its native
Array.new proofs now all pass. The first remaining false App targets `dist`, an
already-collected nonnative helper whose planned body is Ann (fuel 8057); all
twenty helper suffix checks still pass. Raw evidence:
`selfhost/build/phase47/array-admission03/report.json`. The former Mat-only source
App rule was a second normalization restriction, independent of native ownership.

The next isolated source checkpoint accepts only collected nonnative Def helpers
with zero erased-prefix metadata, positive arity at most 32, and exactly that
many arguments. The complete typed region proof and executable helper audit stay
required. Normalize their source Apps to private JCall, including non-self calls
to countdown helpers. Preserve only the current Mat helper's own source App so
the existing Nat loop emitter retains its simultaneous tail transfer. Root bodies
have no such self-call exemption. Preserving every Mat-target App would be unsafe:
a non-self call from a raw root could reach ordinary public descriptor dispatch
with private raw storage.

This adds eleven lines to the previously frozen module (197 total) and no runtime
changes. Fresh two/four-array record controls already contain root-to-distinct
Mat calls, helper-mediated record transfer, Bool selection, and array-returning
stores; replay them on this candidate. At this source checkpoint, checked build,
activation, semantic replay, and timing are pending. Neither successful static
reasoning nor earlier candidate controls count as the new candidate's result.

## Final outcome — installed array06, 2026-10-05

The complete representation, ordered-store and call-normalization contract is
installed in array06, together with the separately recorded tree composition
and integer guard. Final checked emission, four independent Array control groups
and eight maintained suites pass. Exact installed source/API/runtime verification,
all 42 ordinary/relocated CLI checks and a separate 27-sample portable replay
also pass. The [installed-release receipt](../../selfhost/tools/performance/phase47/evidence/installed-release.json)
binds those identities; this does not assign later results to earlier snapshots.

The final 45-point/669-sample run improves equal-point execution from 3.085148×
to 2.919418× pinned TypeScript time. Fold at 8192 improves 1.583× to 0.956×
TypeScript, but the 128-step fold is 1.930× slower than worker23. The combined
source grows 247 physical Bend lines; generated libraries grow 100,476 bytes.
This is a qualified speed/size tradeoff with explicit small-workload overhead,
not a general simplification or all-program speedup. See
[full results](../../implementation/phase47/results.md),
[accounting](../../implementation/phase47/accounting.md),
[P47-005](P47-005-tree-array-composition.md) and
[P47-006](P47-006-integer-array-guard.md).
