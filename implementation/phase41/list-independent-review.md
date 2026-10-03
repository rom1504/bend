# Phase41 list tuple ablation: independent review

Static review of `design/phase41/lists.md`, the saved-JS transform and
controls, the proposed source emitter, the source patch, and the checked-in
`selfhost/src/back/js/tree.bend`. No build, runtime, benchmark, or production
edit was performed.

## Updated finding

The newest patch now guards all three transfer sites with
`j_component_next_args` and `j_component_transfer`. When the argument count is
short, it keeps the old `$next` array path and indexed assignments; for a full
transfer it emits scalar temporaries. This resolves the incomplete-transfer
blocker from my first review. Zero-term short transfers also use the old empty
array path when the worker arity is positive, while an empty full transfer
emits no temporaries or assignments.

## Controls needed

The saved-JS transform checks each proposed `$p41nextN` name against all
identifiers already in that block, but it does not reserve names across
multiple `$next` tuples being transformed in the same block. Such an input
would redeclare `const $p41next0`. I found no evidence in the source emitter's
control-flow construction that selected list-pipeline transfer sites share a
block: sites are emitted at terminal branches under their own `if` blocks,
and continuation phases also have separate blocks. Thus this is a latent
transform precondition rather than a confirmed collision in the selected
output. A low-cost safeguard is to track the matched declarations per block
and either allocate disjoint names or reject a second tuple in that block.

## Checks that pass by inspection

For full transfers, `j_component_next` walks arguments in list order, emits
one `const` per argument, and advances dependent types with `j_app_type`,
matching `j_apply_args`'s left-to-right expression order and erased-position
`null`s. `j_component_assign` runs only after all those declarations, so all
RHSs still see the old `$sN` state. In `j_linear_split`, the existing
`j_producer_unary_before` work still precedes transfer argument evaluation,
and the existing frame `args`, `before`, `phase`, and continuation fields keep
their array shapes. The transform admits only nonempty array literals with
no holes/spreads and one exact constant-index read per slot; it leaves frame
arrays alone. Empty worker transfers are outside the recorded source
admission (`da(d) > 0`), while the saved-output transformer explicitly rejects
empty tuples.

No blocker remains from this bounded static review. I did not run an AST-based
enumeration of selected saved-JS block groups; the source-emitter structure
supports separate scopes, but a future reusable transform should enforce that
assumption directly.
