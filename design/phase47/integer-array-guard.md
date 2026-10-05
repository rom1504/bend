# Proved integer-only private-array host guard

The root-owned saved-output diagnostic completed 45 samples with matching values.
Selecting the existing smaller integer hook set changed medians from 15.879 to
14.075 µs at 128 iterations, 62.061 to 60.348 µs at 4096, and 112.390 to 110.355 µs
at 8192. This suggests a modest fixed entry cost. It does not remove the observed
short-call regression or establish a checked-compiler result.

Add an optional `integerOnly=false` argument to `arrayViewHostGuard`. False keeps
the current full host check. True uses `regionHostGuard(true)`, which retains
current global identities, reflection, protocols, prototype key sets, imul, and
integer-validation hooks while omitting floating operations and DataView checks.
Both modes retain the existing non-null regionProof refusal, null Object prototype
parent, exact Array.fill and Number.isSafeInteger data descriptors, and old-path
fallback. Guard order remains fresh host proof before scalar inputs and source
metadata checks.

The smaller set alone is insufficient: proved U32.div emits `Math.floor(a/b)`.
Capture the standard Math.floor value at module initialization and check its own
data descriptor with captured reflection in integer mode. Do not read a changed
accessor. Keep imul in the existing smaller set. U32 bitwise/add/sub/mod/comparison
operations are host-free on canonical inputs; dynamic shifts and from_nat use
Number, to_nat uses BigInt, and array allocation uses Number/isSafeInteger/Array/
fill. All remain guarded. Unknown natives, F32 operations, and U32.to_f32 remain
outside the existing array executable-node audit.

Emit true only when all existing floating-use checks are false over the complete
admitted plan: canonical root signature, original root type/body, checked root
term(s), and every helper's canonical signature/type/body. An unused F32 input
still requires Math.fround/Number.isNaN during input validation, so signature
normalization is necessary even if no floating expression appears in the body.
Aliases must receive the same treatment. Tree admission supplies both checked
arms. A clean F32-bearing root may continue to use the raw-array representation
with the full guard; this is a guard subtype, not new source eligibility.

Use one compiler helper to print the guard choice and the same helper at ordinary
and tree entry. Thread the existing successful plan (and tree zero term) rather
than a mutable global mode or emitted-text inference. Mirror the runtime change
in runtime/js/core.mjs and the assembled runtime.mjs. Aim for about 20 added lines;
no new analysis framework or numeric benchmark threshold is warranted.

Independent controls must include an integer array loop using division, a division
helper, an otherwise identical root with unused F32/aliased F32 input, and both
entry routes. With changed Math.floor or an accessor, integer mode must refuse
before source operations and preserve old-path observations. Integer mode may
remain admitted under changed irrelevant Math.fround/Number.isNaN/DataView hooks;
full mode must continue to refuse those changes before live input validation.
Retain fill-to-Number late mutation, numeric prototype setters, source descriptor
mutation, error/reentry, and existing public storage controls. Require actual
mode/entry witnesses, then clean short/long timing against frozen tree05.
