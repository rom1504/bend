# Bounded scalar-result borrowed observers

## Status and interfaces

This is an optional source-only prototype, not a selected result. No compiler,
target or benchmark was run by the audit agent. Existing frozen modules were
not modified. New files:

- `scalar-observer.bend`: 175 lines, SHA256
  `f905b600356f59b81002c7ffbee46e470903a21fd241e841e79e92f50e62668b`.
- `runtime-scalar-borrow.c`: additive runtime helper, SHA256
  `85d7f3a6a99f3864bdb7b6fd822d854061c87b59f1d83d9b0fb4650283f29ce3`.
- `scalar-observer-controls.bend`: ordinary renamed equality, shared/distinct,
  unique/mixed, static, Unicode and alias cases, SHA256
  `67c38d67609e02c04b71090ec1b353332ccc82031a507c25a426c8720fee23a8`.

Append the Bend module after `integrated-entry.bend` and
`integrated-observer-permission.bend`. Add module overrides
`p118e_permitted` and `p118i_borrow`; retain the existing `p118e_prepare` override.
The selected runtime must contain
`p118_rt_borrow_scalar_safe(state, first, second, count)` in addition to the
existing borrowed-field helper. Both cold/scalar and independent observer
permission branches keep their original conditions.

## What the source and runtime establish

The mature `no_schema` already permits a scalar-only result represented by a
`Var` referring to its unique observation slot. Its NO analysis proves the
residual observation and recursive cursor relationships. The first Phase118
prototype explicitly excluded this result shape because it returned roots
rather than destroying them. This optional path is separate; it changes none
of those existing root-preserving eligibility rules.

Each selected scalar observer must additionally have an existing public,
single-result direct worker with the same parameter count. Its entire fallback
body must contain **no `P113DCall`**, recursively through branches. Runtime calls
and `P113DAgain` remain permitted. This restriction matters: the current borrowed
composition prepends its added functions, and the independent verifier's ready
set does not contain arbitrary existing private product workers. Copying an
unrestricted fallback would violate that dependency order. This bounded subset
can copy the original body exactly under a fresh private name, preserving its
existing owning tail loop without adding such dependencies.

The generated functions are ordered private fallback, borrowed reader, public
adapter. The adapter checks the original owning roots, then either:

- calls the readonly NO reader, sinks each owning root exactly once, and returns
  the scalar observation; or
- passes the unchanged original parameters to the private owning fallback.

No owning parameter is consumed before the reader returns. No borrowed field
escapes as the result. Non-root parameters are the scalar types already admitted
by NO. The existing mature residual emitter and `p118b_lower` validate and lower
the same successful plan. No source or workload name participates in selection.

## The guard is stronger than the mature C profitability guard

Mature `no_shared_roots` joins root tests with OR: **any** shared root selects
its scalar observer. That can be semantically valid while still doing expensive
destruction of another unique root. This prototype instead requires **every**
root to be `term_triv` (including static/immediate values), or RFC count greater
than one. It accepts one or two roots only.

Independently checking count greater than one is insufficient for two aliased
arguments. If both own references to the same RFC cell with count two, the first
drop makes the second drop destructive. This version conservatively declines
every pair of aliased nontrivial RFC roots, even when count exceeds two. A later
generalization could compare count against the number of adapter-owned aliases.

`term_triv` and `term_drop` in the selected runtime establish the constant-time
drop cases. Under the sequential direct-QBE runtime and readonly reader, no
other operation changes those root counts between guard and drops. This
profitability guarantee should not be transferred to a concurrent runtime
without considering other owners releasing references during the read. Holding
the adapter's own roots still provides lifetime safety in that situation.

## Verification retained

The request-bound integrated entry still verifies the original complete IR.
The new guard has a strict structural projection: exact state/word/word/U32
arguments, one-or-two literal count and U64 result. Its projection reads both
Term operands with a typed OR instruction; this is a structural interface check,
not a claim that OR implements the guard. The semantic justification remains the
derived NO plan, source-bound adapter construction and runtime helper contract.

All projected additions then pass unchanged `p118b_verify_functions`, retaining
its exact constructor/arity checking for borrowed field reads and ordinary
direct-function dependency/type checking. The original fallback body is copied,
not reconstructed. Names are private and source-fresh; duplicate emitted names
are still rejected by the verifier. Failure emits an error, never unchecked code.

The current scalar composition also projects/checks an empty addition set; it
does not reuse the conservative entry's empty-set shortcut. This is a small
experimental preparation cost to measure before considering integration.

## Best information-value tests

First check the module and ordinary control source. Inspect emitted function
names for `$p118borrow.owned.` and `$p118borrow.read.`; correct output without
selected workers demonstrates fallback correctness, not optimization coverage.
Run the checked finite alias cases, then measure a shared long equality against
the unchanged unique case and an early mismatch. Preserve the unique-path guard
overhead and refusal results, even if the shared case looks attractive.

On the compiler request, `p118s_workers(book, candidates, originalFunctions, [])`
can report accepted functions after ordinary request lowering/verification.
Promising source candidates are `p88_string_eq_go`, `p88_string_order_go` and
`p98_tag_eq_read`, but their actual NO/fallback admission is unmeasured. Wrappers
such as `p88_string_eq` may be rejected if their fallback retains direct calls.
`tg` itself returns a String and is not a scalar-result observer; the comparison
that consumes its tag is the relevant scalar computation.

The current Phase116 profile proves a root-reconstructing `String.cmp` path and
substantial ownership/destruction cost. It does not establish an inclusive cost
for these particular scalar candidates. Do not claim that all destructor samples
or compiler time will disappear. If no important candidate meets this bounded
fallback condition, retain the negative result rather than expanding the
verifier, scheduler or call graph solely to force admission in this experiment.

The highest-value next step is an exact plan/worker census on the full compiler
plus one uniform shared-string runtime screen. Only a successful, material
screen would justify another native compiler acquisition.
