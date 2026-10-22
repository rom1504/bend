# Independent finite-selector semantic review

Reviewed the frozen v1 specialization in
[manifest01.json](../../selfhost/tools/performance/phase126/specialization/manifest01.json)
(SHA-256 `6387830ecd6a58fbeac5557fa46640e876f99cfe1545896a884fa22e6fd07dfd`).
All seven module hashes match. This was an offline source review: no checker,
compiler, generated target or benchmark was executed by this reviewer.

**Conclusion:** no semantic blocker found in the stated narrow checked-source
scope. The source-to-decision lowering and final decision-to-table projection
have distinct obligations; the unchanged IR verifier checks the derived program
but does not prove the new source constant evaluator equivalent. Ordinary output,
admission and emitted-code checks remain necessary before selection.

## Nat decisions and default semantics

[plan.bend:130–160](../../selfhost/tools/performance/phase126/specialization/plan.bend#L130)
requires a canonical live Nat domain using the existing primitive-owner check,
then the exact `Mat Zero / Mat Succ / Efq` shape used by the mature JS region
planner. Each successor descent adds one row and reconstructs the successor arm
telescope. The final Lam is a default for the remaining Nat, not evidence that
the input is bounded. Its body must evaluate to a closed scalar: a used remainder
variable is not evaluated or substituted with zero and therefore refuses.

The four-to-sixty-four-cell lowerer returns constants for indices `0..count-2`
and the last constant for **every other full-width input**. This agrees with the
matched consecutive Nat pattern/default. It does not truncate Nat to U32.
Noncanonical ordering, an unsupported residual matcher, insufficient/excessive
rows, or unknown scalar result falls back. The initial Mat restriction is a
conservative coverage restriction; an eta-expanded Lam/apply shape is not silently
interpreted as the same selector.

## Constant evaluation, authority and ordering

[plan.bend:22–104](../../selfhost/tools/performance/phase126/specialization/plan.bend#L22)
accepts canonical U32/F32 literals, authenticated `U32.to_f32` and F32 arithmetic,
and bounded saturated ordinary helpers with one or two canonical scalar inputs.
Primitive authority comes from `j_primitive_call`'s base-definition/telescope and
owner checks, not the name whitelist alone. Ordinary helpers use their actual
checked bodies. Foreign helpers, unsupported argument kinds and dynamic callees
are not interpreted.

Every helper actual is evaluated before substitution, including an unused actual.
The first argument precedes the second. This matters for an otherwise constant
helper containing a remainder, owning or unsupported computation in a discarded
argument: it cannot be erased by substitution first. A failed subevaluation
refuses the entire table. There is no evaluator case for free variables, heap
objects, effect actions, arbitrary match execution or arbitrary foreign calls.
Fuel decreases across expression/helper evaluation; helper arity, syntax and row
budgets further limit the experiment. These are bounded refusal rules, not a
general partial evaluator or compile-time-cost guarantee.

Each folded arithmetic operation invokes the language's F32 operation, then
extracts its bits before another operation. It does not retain a binary64
intermediate, reassociate expressions or introduce FMA. Finite-result screening
excludes NaN/infinity constants and any nonfinite intermediate, even if a later
expression could become finite. Negative zero and finite subnormals remain
admissible and must retain their bits. Correctness inherits the compiler
executable's existing F32 primitive semantics; this review does not newly qualify
host/native constant folding or floating environment differences.

## Exact fallback and machine projection

Independently compared declaration bodies against the pinned Phase125 parent:

- `p126s_original_candidate` equals `p113pl_boxed_candidate` after renaming.
- `p126s_prior_function` equals `p113ah_function` after renaming.
- Removing only `not(p126s_is_table(function))` from the new inlining predicate
  leaves the selected parent predicate unchanged (apart from binder annotation).

The selected hook is
[render-entry.bend](../../selfhost/tools/performance/phase126/specialization/render-entry.bend),
overriding `p113ah_function`. `emit-entry.bend` is an unselected alternative and
is not part of this reviewed composition. Table-shaped functions have no scratch
buffers or float operations; the current typed-companion renderer sends them to
this fallback. Changing that dispatch later requires a fresh composition check.

[emit.bend:11–39](../../selfhost/tools/performance/phase126/specialization/emit.bend#L11)
independently recognizes the exact verified decision IR: one unchanged input,
consecutive full-U64 equality indices, matching condition destinations, immediate
low-word constant results, and no intervening operations. A comparison cannot
overwrite its input. This projection remains valid for any verified function
matching that complete IR, regardless of whether the new source recognizer
created it. Source-specific authority is not needed to replace an identical
effect-free decision tree.

The emitted `cultl input,last` is an **unsigned 64-bit** comparison. It clamps to
`last` before shifting by three and loading a complete eight-byte constant.
Thus equality with the last index, values above 2^32, the high U64 half and
U64-max all choose the last row; no speculative index truncation enters this
code. At most sixty-four entries bound the byte offset to 504. Table cells use
the established `P111QLong{bits,0}` serializer, aligned to eight bytes. Function
symbols use the existing injective name encoder; generated temporary names are
distinct from normal `%v_` formals. No ownership calls, effects or parameter
evaluation are removed by this final projection.

## Validation limits to keep visible

The supplied ordinary selector witness includes exact helper arithmetic, rounding,
negative zero, both scalar result kinds and indices 2^32/2^40. Its remainder,
owning-argument, higher-order and recursive-helper examples have only two rows,
below the four-cell promotion threshold. **Output equality alone does not prove
those semantic refusal checks work.** Query `p126s_inspect` for `None`, or add
separate versioned negative witnesses with at least four rows. This caveat was
sent to the implementer and parent before review completion; frozen v1 files were
not changed.

Useful cheap projection rejection controls are a skipped/nonconsecutive index,
comparison destination equal to the input, mismatched condition name, nonzero
result high word, or an inserted effect statement. Ordinary additional controls
could exercise a high-bit-set Nat index and an unused *unsupported scalar*
argument, so refusal cannot be attributed only to an owning argument type.
Primitive-shadow and nonfinite refusal should remain separate admission checks.
These are recommended coverage, not claims that such tests ran.

Source admission on actual ray definitions, correct QBE assembly, exact outputs,
matched runtime/compiler cost and broad/native qualification belong to the parent
measurement lane. This review establishes neither measured activation nor a
performance gain. The inlining exclusion intentionally preserves a direct selector
call; a future inlined table operation would be a separate optimization.
