# Phase128 Stage1 borrowed-call composition audit

Independent source review only; no builds, target executions or timing runs.
The initial bounded scalar observer remains a separate candidate. Stage1 adds
private scalar-reader calls while retaining the existing plain root schemas; it
does **not** yet admit `List<String>` roots or arbitrary nested owned products.

The reviewed design has a bounded safety argument: caller-held roots protect
borrowed arguments, helper summaries describe only derived scalar readers, and
all final functions are checked in dependency order. One missing residual gate
was identified and restored during this review. No further blocking source-level
issue was found in the reviewed version. This is not native qualification or a
proof of the complete compiler.

## Reviewed identities

Files under `selfhost/tools/performance/phase128/borrow/next/`:

| File | Bytes | SHA256 |
|---|---:|---|
| `context.bend` | 1537 | `6bd9a134bb8f566ae67814ce52d60c3da5478c3928bea48eeb05f70d3055b973` |
| `read-calls.bend` | 5131 | `5ecdd5a2edee5dfd25d981991c6ba2a8434fe6cad3eee5fb37ee9ddf6e51eb64` |
| `integration.bend` | 8389 | `9e08084f4ac3c9971e924c3eae014cdea90c9f5b65aa438b32b3e33ccadf8c0f` |
| `residual-check.bend` | 1554 | `3a6af89e8fb7e99b7d5e565471dcd29eec586a993d7687226def0593338d65c9` |

The foundational scalar/guard/runtime obligations are in
[borrow-audit.md](borrow-audit.md). Subsequent edits require a separate check of
the changed parts; these hashes do not endorse later versions automatically.

## What establishes the helper contract

`p128br_summaries` derives each summary from an ordinary successful `NO_Plan`,
the stronger scalar eligibility predicate and an existing public leaf fallback.
It does not read a user annotation. Ordinary `noa_analyze` initializes the new
helper list to empty, so these seed readers still use the original NO vocabulary.
The summary records formal parameters, root positions, scalar result type and
the private reader symbol derived from the owner.

The seed helper is not already an independently verified installed artifact at
summary creation time. Its source-derived worker is generated again by the same
request-bound path, and the complete added set is independently verified before
emission. `p128br_check_added` enforces that dependency. This distinction matters:
summary construction alone is not permission to invoke arbitrary raw direct IR.

The new caller path gets candidates through the existing checked request and
reachable-bang exclusion. `no_schema` still rejects foreign/native owners and
unsupported parameter/result shapes. Existing NO analysis continues to determine
evaluation order, primitive legality, constructor provenance, pure helper
expansion, tail recursion and the scalar-only result. Public helper names are
resolved against the derived summary set; the emitted `NO_ReadCall` names only
the summary's private reader, never its owning public adapter or fallback.

## Root lifetime and nonescape

`p128br_arguments` requires root actuals to be abstract atoms of the expected
type whose origin is the caller's own root argument or a descendant field of
one. `p128br_held` checks the actual root indices, rather than accepting any
parameter. Scalar arguments must pass ordinary `noa_scalar` extraction.

The caller's adapter retains the original owning roots until its reader returns.
Readers perform no ownership transfer of those roots. A descendant therefore
remains live even if it has reference count one: its retained ancestor owns it.
The private helper does not sink the borrowed arguments. Caller and helper may
read aliased roots or overlapping descendants because neither mutates them.
The public adapter's conservative shared/alias guard remains unchanged.

The result has an admitted scalar type and a fresh scalar observation origin.
It cannot carry a field reference, root, closure or owned product back into
ordinary code. The unchanged result analysis also rejects a borrowed tail as
the caller's result. The final machine verifier checks word types/signatures;
the nonescape guarantee comes from this semantic derivation, not from `U64`.

Stage1 compares type names only because the unchanged schemas admit plain root
and scalar types. This is not sufficient for a future parameterized-root
extension. Such an extension must preserve specialized field/type identities
and cannot simply relax `nol_plain`.

## Dependency ordering and bounded stack use

Seed helpers contain no borrowed-helper calls. Newly derived caller readers are
not added to the seed registry. Consequently, new readers can call only the
original seed layer; local recursion still lowers to `P113DAgain`. This bounds
new native call nesting independently of input depth.

For a new scalar caller, Stage1 copies its original owning body under a fresh
private name, retains its preceding dependencies, then inserts reader and public
adapter at the original public function's position. The original direct function
was already acyclic except for `Again`; renaming its local loop does not create a
native recursive call. Other callers still use the original public identity.

The final `p126bp_complete` path verifies the projected complete function list
from an empty ready catalogue. It rejects missing dependencies, forward/cyclic
direct calls, duplicate identities and ABI mismatches. It does not merely seed
the verifier with every future signature. Existing Phase126 flat closure and
certificate checks remain active. If closure reordering or omission makes a
copied fallback's dependency unavailable, final verification must reject the
candidate rather than emit it.

## Finding and repair: preserve the old residual gate

The first Stage1 draft replaced `no_emit` success with QBE lowering success and
final verification. This dropped explicit checks in
`observer-emitter.bend:no_emit_match_found`: valid native layout storage, exact
residual node arity, variable scrutinee, `NO_Fields` tag, field count equal to
layout width and fresh/distinct field binders. QBE lowering plus structural IR
verification does not independently reconstruct all these residual properties.

`residual-check.bend` now retains that gate. It replaces a `NO_ReadCall` used as a
let value with a scalar zero placeholder only after checking all actual argument
atoms in the current environment and a nonempty target name. It preserves the
outer let/match shape, fields and binder names, and feeds the projected residual
to the unchanged `no_emit`. Malformed outer arities remain unmodified for the
original checker to reject. Actual calls additionally pass QBE lowering and the
complete direct-function verifier.

This projection is strictly a validation device, not an executable replacement
or a semantic equivalence claim. Nonempty target text alone proves no borrowing
contract: the checked summary derivation above remains essential. A standalone
raw `NO_ReadCall` API must not be treated as trusted optimization input.

## Small controls with highest value

- Ordinary direct wrapper-to-reader composition and an unrelated scalar reader;
  inspect actual private-call selection as well as output.
- Shared, unique fallback, static, Unicode, exact aliases, shared suffixes and
  early mismatch, with retained roots observed after the call.
- Origin beneath a root accepted; origin beneath a scalar/nonroot parameter,
  invented origin, wrong argument type/count and escaping result refused.
- Unknown or owning helper target, missing earlier dependency and direct-call
  cycle refused by the corresponding semantic or final verification gate.
- Residual mutants for wrong match width, wrong field tag, duplicate binder,
  unbound call argument and malformed let/match arity still refused after
  call projection. Test rejection without executing malformed target code.
- Deep input retains bounded native stack and live-bank transport stays enabled.

Measure compiler preparation separately: Stage1 derives observer plans multiple
times (seed census, ordinary additions and caller patches). Correctness and a
proxy runtime gain do not establish acceptable full-compiler analysis cost.
Native compiler qualification is justified only after useful selection, actual
runtime improvement and the independent controls succeed.
