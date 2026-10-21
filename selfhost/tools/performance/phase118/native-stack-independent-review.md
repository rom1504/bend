# Independent source review: catalogue stack safety

Reviewed `native-stack-safe.bend` SHA256
`1c071404bcc0f7fe14b0aa746876d5a1221b5a007d8340acea6b87290b230ab3`
and `native-stack-controls.bend` SHA256
`77ce73eb696febbe691ae4b235c716f1c732d6bbbd87f82ddb009988a97a0806`
against the selected `float-source01/compiler.bend`. No compiler, controls,
target program, stack-failure reproducer, or benchmark was executed by this
reviewer. This records source reasoning, not generated-loop qualification.

The transport catalogue/body/function folds preserve the original strict
Boolean predicates, including the exact transition-plus-return terminal case.
An accumulator represents conjunction of the already visited prefix; scalar
and branch predicates execute in their original order. Nested branch traversal
still recurses. Constructor/cold filters and replacements retain their exact
predicates and output order by reversing each prefix into the accumulator and
reversing once on completion. No capability, hot-bit policy, source authority,
or verifier is weakened.

Projection preserves statement/function order and the first diagnostic.
`p118b_project_call`, its failure path, and all recursively projected branches
always return `fresh=0` and `calls=[]`; dropping those intermediate fields in the
new accumulator therefore matches the original `p113d_join`/`p113d_branch`
composition. Worker construction preserves candidate order, skips the same
ineligible plans, and stops at the first nonempty worker error. The original
derived-worker structural check remains in place.

One initial discrepancy was corrected before these hashes were frozen:
effect-definition permission initially accumulated false while evaluating later
definitions. The original permission stops on its first refusal. The revised
valid-first helper returns false before a later lookup, with direct self tail
recursion after each admitted definition. Its native-first predicate is exact:
`nc_native_def`, else `nc_foreign` with unchanged trusted **and** filled
`Foreign` membership, else `Def` plus unchanged `no_effect_terms`. It neither
admits untrusted/unfilled/unknown providers nor changes the whitelist or `Rwt`
refusal. The valid-first parameter order also avoids matching a later parameter
before an earlier one in this Bend checker.

No remaining concrete semantic defect was found in these reviewed changes.
Generated JavaScript must still confirm actual loop lowering for the direct
self calls; source tail position alone is not execution evidence. Deep term or
branch structure and unchanged mature helpers can still recurse. The earlier
full acquisition lacked `error.stack`, so these hazards are not a proven
retrospective location of that exception. Ordinary complete-output/exact-QBE
gates and a separately successful full native acquisition remain necessary.

Revision 2 (`native-stack-safe-v2.bend`, SHA256
`db08e5a0cb691fa4a87ca9fe1386978b1a72b88bfedc8ee68d4d0badc30db867`)
was reviewed after the root's first source check rejected computed local-value
matches in v1. Parameter accessors now retrieve projected body/error and worker
functions/error. The worker loop carries a valid-first state and performs its
self call directly. It preserves the same first error and does not inspect a
later plan after failure. It may reverse the already computed current worker
prefix immediately before the next false iteration discards that prefix; this
pure local work does not change outputs or permission. No new concrete semantic
issue was found in this revision. Its source check and generated-loop inspection
remain distinct from this read-only review; frozen v1 remains preserved.
