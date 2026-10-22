# Bounded next experiment: exact constructor identity

This is an implementation sketch only. No compiler hook or runtime was edited.
The current Phase125 tree `flow` zero-depth branch still performs a take2 and
ctor2 of the exact same fields (`p125-verified-families06/tree-bitonic.ssa:11954`).
The proposed first experiment removes that closed identity, not arbitrary
cell reuse, global borrowing, or a layout guard.

## Recommended boundary

Use a shared **predicate at checked KTerm match lowering**, before ownership
partitioning creates field bindings. Two small hook sites cover scheduler and
private/product paths without parsing generated C/QBE:

- `p112m_original_match_apply` (selected source06:43431), called for ordinary
  non-Word matches by `p112m_match_apply`.
- `p113pm_original_match` (from
  `phase113/direct-fields/overrides-products.bend:3`), the ordinary boxed
  fallback of `p113pm_match`. Preserve all Word/packed special paths.

The hook already has the original scrutinee variable, authenticated constructor
match, full live field count, branch lambdas and remaining evaluated matcher
arguments. An IR pass after `take` would instead have to reconstruct ownership
from scratch stores, field loads and helper strings. Avoid that larger proof.

## Conservative predicate

Start with ordinary user ADTs having two or more live fields. Authenticate the
constructor with `nc_find_ctor` and its actual live arity. Exclude IO,
Word/Array and specialized primitive representations; reject unknown metadata,
dependent/indexed field layouts and any unexpected erased/live binder shape.
The first control need not support every finite Sigma or builtin.

Read exactly the match's field lambda prefix, collecting binder IDs in declared
order. Peel only known metadata wrappers. Admit if the remaining body is
exactly the same constructor applied to exactly those variables, once each in
the original order, with no other children. No calls, arbitrary normalization,
let evaluation, duplicated fields, dropped fields or source-name whitelist.
Initially require no remaining matcher arguments; extension through already
evaluated argument lambdas can be a later separately checked case.

Equivalently, apply the existing field variables using `nc_field_apps`, reduce
only variable beta applications with `nd_beta`, and compare the complete body
to the expected constructor term. This needs an explicit small node/fuel bound
and fresh-ID guard; scanning the original lambda prefix avoids substitution and
freshness cost entirely. Do not invoke unrestricted weak normalization.

## Emission and ownership

Retain the existing constructor tag test and original miss branch. On the hit,
call the normal lowerer on the **original scrutinee variable with the original
environment**. Do not create field bindings, emit a take, or lower a new
constructor. This lets the existing partition sink unrelated branch-local
owners and preserves the target's return/local/product convention.

In particular, emitting a bare machine `return owner` would be wrong when other
owned values in the environment need to be dropped, or when the target expects
a local assignment/product result. Reusing `p111_lower` or `p113pl_lower` on the
scrutinee preserves those rules. Build the miss branch using the successful
branch's returned fresh counter, as before. Do not strip earlier sharing/keep
operations from the surrounding expression.

No mutation or uniqueness proof is needed: returning the original owner is
observationally equivalent to consuming/reconstructing identical fields, even
when the input is shared or static. The checked semantic boundary is essential;
this does not license accepting malformed runtime nodes or replacing existing
standalone runtime validation. Keep the original lowering as exact fallback.

## Minimum evidence before broadening

1. Pure admission controls: exact two-/three-field identity, renamed
   constructors, swapped/duplicated/dropped/changed fields, effects, unknown
   constructors, special representations and unexpected matcher arguments.
2. Ordinary source controls: heap String payloads with retained original root
   and interior alias, static input, changed-field refusal, complete outputs.
3. Query actual admission for tree `flow` and emit that original frozen case.
   Require the exact take/ctor pair to disappear and complete outputs to match;
   timing alone is not proof that the rule fired.
4. Only if coverage and work removal matter, extend to a reconstruction used
   inside a larger result. `Map.seek` is such a case: it returns original map
   plus an owned key observation, so it is **outside this first predicate**.
   Borrowed field observations/keeps require a new ownership proof. Do not
   advertise Map gains from the closed-return identity alone.

The source change should be on the order of a bounded recognizer plus two
delegating hooks, not another optimizer representation. If actual eligible
sites are cold or absent, retain the negative result and move to the measured
local-resume or typed work rather than adding algebraic normalization to chase
one benchmark.
