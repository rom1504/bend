# Independent review of the cold user-constructor proposal

Status: source review only. No compiler or target executed by this reviewer;
`cold-constructors.patch` remains a proposal until root validates it. The review
found no concrete counterexample under the existing checked-entry contract, but
the extension requires the following argument and controls. Calling the current
predicate a universal no-sharing certificate would overstate what it checks.

## Actual invariant

`ns_unshared_definitions` forbids repeated runtime use of variables whose types
may contain arrays. It permits duplication of a recursively checked whitelist
of trusted Base types: scalar and String values, plus List/Maybe/Result/Sigma and
Word forms whose type parameters also pass. Every user ADT is opaque because
`ns_array_free` requires Base provenance. Functions are opaque regardless of
their visible result type, so captured user values cannot pass through a
duplicated function value unnoticed. Unknown/dependent types conservatively
fail; the syntax-only layout query does not speculate through matches or proof
rewrites. `ns_term` rejects runtime rewrite syntax.

For the trusted current Base ABI, every whitelisted value contains only scalar
or other whitelisted Base values. Consequently it cannot conceal a user ADT.
This structural fact is the missing bridge from the array certificate to the
new claim: all runtime values which may contain a user constructor are used at
most once along each executable branch. Type parameters of trusted containers
must keep being traversed; broadening the whitelist requires revisiting both
array and cold-constructor soundness.

This is a whole reachable-book predicate, not an inference from an individual
fresh allocation. A user node passed through another user wrapper, Base List or
Sigma, or a closure remains opaque. Any repeated use anywhere rejects the macro
for the entire compiled program. A function that uses a captured parent once
can still be called twice only if its closure is duplicated; that function
variable/container must itself fail the repeated-use check.

Native definitions are skipped, so their ABI matters. Current supported
intrinsics operate on scalar values or arrays; the scalar-array admission
excludes arrays holding user values. Foreign definitions are allowed only after
the separate effect-source permission and supported IO.args/print/now checks.
Unknown callbacks or effects cannot be admitted by merely trusting their Bend
signature. Raw `nc_compile` does not run this analysis and must leave the new
macro undefined/false. Direct callers of `nc_compile_checked` remain bound by
its documented checked/specialized/annotated-book and trusted-ABI preconditions.

## Runtime reasoning

Sealing child fields is required when a parent may later be shared:
`span_fade` can duplicate only RFC or trivial child words. Without that
possibility, ordinary `ctr_take` moves child ownership out and `term_drop`
recursively disposes it; neither operation requires eager child wrappers.
Already-shared String children retain their existing RFC words in a plain store.
The proposed change applies only to constructors with encoded non-Base identity;
Base constructor stores, closure captures and task storage retain their existing
sealing behavior.

Static image nodes require separate treatment. Static immutable graphs can be
referred to repeatedly despite lacking variable duplicates, but every field is
also static/trivial and addresses are below `HEAP_OFF`. Neither the cold-store
proposal nor reuse may turn those addresses into writable/freeable storage.
The proposed saved-C reuse correctly gates a spare on `>= HEAP_OFF`; no static
image was yet involved in this review's execution evidence because none ran.

The per-branch use counter takes a maximum only across mutually exclusive
matcher branches; ordinary child lists add uses. Correctness still depends on
the existing annotated/core binding-identity invariant and checker accepting
the program before this certificate is considered.

## Required controls

Retain the lane's unique rotation, direct user sharing and shared String child
fixtures. Added independent fixtures are:

| File | Golden | Required macro |
| --- | --- | --- |
| `fixtures/shared-user-dynamic-refusal.bend` | `22n` | `NATIVE_COLD_USER_CTORS 0` |
| `fixtures/captured-user-refusal.bend` | `25n` | `NATIVE_COLD_USER_CTORS 0` |
| `fixtures/container-user-refusal.bend` | `52n` | `NATIVE_COLD_USER_CTORS 0` |

They construct user nodes in parameterized functions, so lifting source literal
trees to static data does not alone make missing-seal tests vacuous. Check both
one and four CPU threads. Also run existing custom-constructor identity,
erased-field, raw wrong-tag/error-order and foreign callback cases. For the
separate local-spare transform, shared/static parents and both match-miss paths
must retain fallback allocation and cleanup. These finite controls support the
argument; they do not prove it for every program or qualify GPU execution.
