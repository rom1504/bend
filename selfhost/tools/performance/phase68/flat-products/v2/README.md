# Fixed product shells, source candidate v2

Registered before implementation as [P68-007](../../../../../../experiments/phase68/P68-007-flat-products.md)
in commit `ee726e4`. This directory contains source and source checks only.
The parent owns the checked Bend build, C build, correctness runs and timing.
No target execution or performance result is claimed here.

The relative [candidate.patch](candidate.patch) is bound to the exact baseline
and candidate hashes in [manifest.json](manifest.json). Its integration baseline
contains worker-v3, admission short-circuit-v1, occurrence-summary-v1 and
small-inline-v1. The prototype preserves the occurrence partition helpers and
the inline macro/formatting. It adds 533 net lines in ten files; the earlier
v1 source snapshot remains unchanged.

`build-proposal.py` composes the candidate from frozen source inputs and
`product-source.bend`; `package-proposal.py` writes the relative patch and hashes.
Both scripts only manipulate source data. The product-source template has four
NC_Code fields; the composer adds emitted-call metadata. Use the candidate files
for the checked build, not that template.

Ordinary workers keep boxed arguments and a one-word result. Private `$product.`
variants accept or return fixed vectors of opaque Term fields. Selection requires
actual constructor/result flow with an exact constructor identity and live width;
type annotations do not authorize unboxing arbitrary public words. Arrays and
each individual field retain the existing one-word runtime representation.
Constructor catalogues come from original typed signatures before erasure.

The v2 query uses bounded syntax checks, direct declaration lookup and structural
comparison. It never unfolds a global definition, invokes conversion or evaluates
an opaque field. Unknown aliases, dependent/erased fields and unsupported shapes
decline. The query helper's reviewed SHA-256 is
`efe70c3e7221fa31bf51531a654df0123839273b76cb79f333d92a98932dac42`.

Local bundles require exactly one use on every branch. Product formals must reach
exactly one source use on every inspected prefix path after bounded symbolic
beta substitution. A dropped or shared whole product keeps its boxed path.
The analysis suppresses only literal-true native guards and exact Zero/Succ or
False/True complements; unknown constructor-tag misses remain possible. It does
not assume checked ADT exhaustiveness. Matcher success reorders the environment
to existing held bindings followed by taken fields, preserving the old drop order.

Opaque calls/stores and unsupported matcher shapes materialize existing boxes.
Escaping closures or dynamic application still reject private worker admission.
Selected B/Q calls are recorded in NC_Code metadata and checked by the existing
fail-closed graph admission. Self-tail calls stage all physical words then jump
locally. A speculative Q failure can conservatively reduce B worker coverage.
Private variants also duplicate source bodies; report the code-size cost.

Required first witnesses include record producer/consumer `1131`, Array pair
transport `2917`, shared aggregate `1007006`, callback escape `29`, scratch-array
ownership `7071122`, unchanged raw/error/bang/foreign controls, and the raw unused
mistyped product returning `7n`. The new branch-drop witness `1831` must additionally
exclude the private product entry for its dropping consumer. Keep positive native
exhaustive and negative unknown-tag prefix controls. These are execution requirements,
not claims of completed runs by this lane.

Inspect the admitted product workers, not whole-program constructor text: boxed
scheduler/device fallback remains. The array discriminator must remove both the
getter-result shell and recurrence-state shell; repacking at every loop call is
insufficient. Product signatures use the existing `NF_FID_...` encoding of
`$product.` plus the source name, a result pointer and flattened Term parameters.

Source reviews cover query termination, fresh IDs, affine captures, branch/drop
and sharing barriers, ownership environment order and emitted B/Q call edges.
Lexical delimiter, helper-name, whitespace, hash and relative patch checks pass.
These checks do not replace a checked Bend build or runtime qualification.
