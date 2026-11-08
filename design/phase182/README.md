# Phase182 — migrate the maintained compiler to upstream Bend2.0.40

## Scope and baseline

Authorized upstream update from `059266225b77c8ca256ac6b25ee5c21449bab151`
to immutable `9a4223d577ba56a0cb53d1fd952d2b481c38930f`. Fork parent is
`adc5fdc`, preserved as `selfhost/before-upstream-182`. The merge itself is
clean. Historical qualified images, Base carriers and runtime objects remain
available; changing a source pin does not qualify or silently upgrade them.

## Compatibility work

1. Separate constructor and definition namespace resolution and preserve local
   sugar ownership; update dependent-let rules.
2. Replace equality-induced value-heap copying with separate equivalence classes.
   Equality facts must not turn a successful conversion into a cyclic thunk.
3. Adapt the maintained direct JS host interface and IO scheduler to the new
   Number Nat / exact export names / effect protocol. Keep representation bounds
   distinct from host-interface bounds.
4. Extend native intrinsics and ordinary effects. Version the native runtime ABI
   and argument convention, including executable-name inclusion. Preserve old
   producer image metadata and old invocation rules.
5. Bind tooling to the exact new checkout, Base, effect provider inventory,
   source recipe and runtime. No unverified graph repair in host tooling.

## Validation ladder

Cheap independent source acceptance and small API controls come first. Exercise
new namespace/let/sharing regressions, host Nat and constructor identity, effect
scheduling, argument boundaries, F32 conversion and ordinary file IO. Compare
with the exact upstream oracle; unsupported hardware lanes remain explicit.

Then acquire candidate images with explicit source/Base/runtime identities.
An old native seed may compile a transitional entry with the old Base/runtime;
that bridge is a bootstrap artifact, never the promoted configuration. New
native generations must use the new ABI and Base together. Require N1/N2
semantic product agreement and ordinary native correctness gates before native
promotion. JS/C entry profiles require their own focused generated-program and
public API checks. Assembly remains experimental and gets compatibility smoke
coverage rather than an unsupported parity claim.

Retain independent final backend verification. Source acceptance, finite laws,
BendTT checking, backend structure and runtime outputs establish different
properties. Run an economical current-kernel proof gate where available; report
any unavailable proof toolchain explicitly rather than calling tests proofs.

## Metrics and execution discipline

Record request/build time, peak memory, generated program runtime, conformance
outcomes and source complexity separately. Existing old-pin benchmark ratios
are historical, not measurements against the new upstream. Use matched inputs
for comparisons; do not claim a fresh broad runtime ratio from smoke tests.

One root-owned CPU3 execution lane, maintained process-tree/disk guards,
ordinary 2GiB RSS, 16GiB available memory floor and 5GiB disk reserve. Snapshot
sources before executing them. Preserve failed attempts and close run retention.
Parallel agents own disjoint compatibility/audit work; only root runs targets.
Full images follow successful cheap gates. Commit merge and validated migration
work with a report; do not post to the upstream PR.
