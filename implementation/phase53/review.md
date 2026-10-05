# Phase53 independent review

This is a static review record. The reviewer runs no compiler, generated program,
timing or release job and edits no production source.

## NaN conversion invariant

The unchanged `f32_table_nan_bits.bend` source compares two paths that construct
the same F32 value and then inspect its bits. Each of the 40 comparisons must
succeed, including the first call. Neither the source oracle nor the previously
failed Phase52 result should be rewritten.

The actual direct06 module calls the shared `f32_bits` helper on both paths. Its
old implementation constructs an ordinary `[x]` array before the Float32Array.
The owner's pinned-Node diagnostic records one cold mismatch: payload `0x7fc00003`
versus `0x7fc00000`; later runs agree. This supports a conversion-path problem,
not a different source branch or arithmetic oracle.

Static review approves replacing that intermediate ordinary array with a fresh
one-element Float32Array and an indexed store before reading its Uint32 view.
All state remains local to the invocation, so coercion reentry cannot overwrite
the outer conversion's storage. The owner's controls check signed signaling and
quiet payloads after Number transport, finite bits, signed zero, subnormals,
infinities, once-only coercion, thrown identity and nested conversion. Checked
emission of the unchanged source remains a separate required gate.

This correction does not promise preservation of signaling status through a
JavaScript Number, or of every NaN payload through arbitrary JavaScript storage.
It changes the argument and operation sequence observed by a replaced typed-array
constructor. Document the direct backend's native-intrinsic boundary; do not
claim arbitrary overridden-constructor equivalence with the old helper.

## Initial ordered-statement hypothesis (withdrawn below)

The proposed bounded exact-saturated call-tree lowering must capture each child
value immediately after that child's statements, before evaluating a later
child. This includes opaque children. It preserves left-to-right effects,
throw order and native-template property lookup after all actuals.

Generate prefixes only after the existing demanded-Let use gate. Preserve
`JD_USE` and `JD_REF` metadata in emitted statements. Non-tail child calls keep
their bounce forcing; a root same-SCC transfer keeps all argument captures before
parameter stores and loop transfer. Temporary names must be distinct from source
and emitter binders and stay within the original branch/iteration scope. Partial
applications, closures and unknown calls retain their existing demand boundary.

## Default-backend migration

Default direct output is an intentional public interface change. Retain explicit
legacy selection for clients that use `G` and descriptors, and update maintained
legacy-specific internal callers to request that mode explicitly. Native output
selection must override the omitted JavaScript choice; mixed-output commands
must not reuse the wrong cached emission. Bootstrap compiler-API generation
continues to use its existing legacy ABI. Separate default/direct/legacy CLI and
API routing checks are required; a successful direct benchmark does not cover
those host interfaces.

## Reviewed implementation checkpoints

The isolated ordered-prefix module (`c4115191…`) and three core delegates
(`705b0ab4…`) pass static semantic review. Exact source saturation and the
checked telescope govern recursion; erased arguments emit no work. Every
non-atomic child is held before the next prefix. Opaque expression lowering,
non-tail forcing, demanded-let filtering and existing parallel SCC stores are
retained. Empty prefixes preserve the original return/transfer printer. Checked
compilation and independent execution remain separate gates.

The default-routing change passes static review for omitted direct selection,
explicit legacy/direct selectors, native-run precedence and mixed JS/C outputs.
The identified private compiler-image consumers must explicitly request legacy
output because their packaging exposes the descriptor runtime. The release-smoke
successor retains the previous 18 assertions under omitted direct selection and
adds six explicit legacy run/library/descriptor assertions, for 24 checks.

The source-semantic controller preserves all 96 candidate source oracles. Only
the exact frozen NaN fixture may separately record TypeScript's failed value 1
while requiring candidate value 40. That row remains a differential disagreement;
95 reference successes must not be reported as 96. Review requested selected
attempt/runtime/compiler closure and final input rehash before consumption.
Those joins are now present and the source controller received static approval.
The separate numeric controller must require healthy reference execution even
for explicitly diagnostic NaN-payload oracle disagreements; a crash or timeout
is not that known numerical defect.

## Counterexample: pinned prefix order

The executed callback control invalidated the earlier left-to-right assumption
used to review ordered-prefix01. That static approval is insufficient for the
published direct contract and is withdrawn as a compatibility verdict. Preserve
the isolated proposal and failed controller/report.

Pinned `comp.ts:3061` first maps every argument through `js_expr`, which can append
statements to the enclosing segment. Only afterward, at lines 3081–3084, does an
intrinsic hold its remaining non-atomic expressions. In
`U32.mul(f(n), U32.add(g(n + 1), 3))`, the inner intrinsic's `g` call therefore
executes before the still-pending `f` call. Immediate left-to-right materialization
changes the selected target's observable callback/error order. The Phase52 design
and parity contract explicitly require that upstream order; the reviewed local
language documentation supplied no universal argument-order rule overriding it.

A controller successor should correct this mistaken independent expectation,
require actual reference/candidate agreement and retain the original failed
observations. This is not a new mismatch exception. The proposed two-stage
successor must collect child prefixes first, then hold pending intrinsic operands.
Ordinary calls retain pending operands until their call expression.

Coverage must also consider an outer unknown callable or constructor: pinned
`js_expr` propagates child prefixes through those forms too. For example,
`h(U32.mul(f(n), U32.add(g(n), 3)))` can expose the same mismatch if an opaque `h`
application bypasses the new prefix lowering. Fixing one known-call tree alone
does not establish the general ordering contract.

## Composition and closure review

The successor propagates child prefixes through unknown live applications,
constructors and expression Lets. Native literal and inverse-constructor folds
precede recursive field emission. Constructor values remain pending after all
field prefixes. A Let holds only demanded parallel RHSs in their original
environment, then emits the body prefix and retains its final pending value,
as pinned `js_open` does. The earlier draft eagerly assigned that body result;
its owner corrected this before consumption.

Independent review found a second draft defect: a Let alias named `$ord0` could
be captured by a closure whose own temporary numbering restarted at zero,
producing a self-shadowing initializer and TDZ error. The revised aliases use
`$heldX<source binder ID>_<reserved ordinal>`, separate from temporary `$ordN`.
The source ID distinguishes nested lexical binders and the reserved ordinal
distinguishes repeated sibling emission. Alias metadata keeps the type but
refuses native-view inverse cancellation. Demand scans include both the body
prefix and value, including markers inside returned closures.

Eta lowering keeps supplied prefixes inside the eventual fully applied closure.
An erased-only suffix creates no runtime closure. Overapplication follows the
outer unary application: generate callee and argument prefixes, then retain their
pending expressions. Removing the temporary depth-fuel fallback is appropriate: the
walker descends syntax children, finite lists or a decreasing eta-arity count and
does not unfold named bodies. Falling back at depth 64 would silently restore the
known ordering discrepancy; no new depth-based source rejection is needed.

The inherited observation worker can mark a caught assertion as complete when a
host mutation is active. Review therefore required the new composition/runtime
controllers to validate expected return/throw outcome and returned value as well
as completion and differential equality. Their successors add those checks while
preserving consumed reports and workers. A shared erroneous getter-case result
can no longer count as a successful independent oracle. Source execution, fresh
checked compiler acquisition and capture witnesses remain separate root-owned
gates.

Final static checkpoint: ordered module `0dde638d…`, ordered-values
`162cf1d6…`, core `2bb2e2d6…`, and compiler manifest `559e008b…` passed
read-only review. Every output row in the isolated source receipt rehashed
correctly. The final transfer helper also removes the erased-only-suffix fallback:
the existing caller proves complete live saturation and no surplus arguments,
so all supplied actuals now use the ordered path. No reviewer target execution
was performed.

## Checked ordered02 readback

The checked-ordered02 snapshot contains the exact four reviewed overlay files,
with matching recorded frozen hashes. The composition module `1b0516b7…` matches
its checked emission receipt and begins with the exact selected direct runtime.
Readback confirms `g` before pending `f`, distinct captured Let aliases, and
supplied computations inside the eventual eta closure. The consumed strict
composition-v3 report records 18 candidate and 18 reference passes, full paired
agreement, and no changed inputs. The named oversaturation fixture is visibly
arity-raised to a two-parameter maker and therefore is not evidence for the
outer-application path.

The frozen driver calls the checked `jd_*` API and assembles runtime, foreign
modules and emitted text. The acquisition worker writes that returned text
unchanged and requires direct backend identity. This path contains neither a
TypeScript compiler fallback nor generated-JavaScript rewriting. This readback
is not a fresh execution or a full qualification claim.
