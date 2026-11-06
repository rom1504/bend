# Phase171: one scalar catalogue for nested observer retries

Source-only experimental implementation. No compiler job, performance result or
promotion. The current full profile's scalar-finish interval is about 8.635 CPU
seconds, with `nol_scalar_specs` reported as 63 of 268 active-owner samples.
Those samples are descriptive and exclude unassigned callees; **8.635 seconds is
the ceiling for the entire interval**, not a measured removable catalogue cost.
Several seconds may be available, but even five seconds requires a causal test.

The repeated computation is real. `p169q_plans` retains eligibility for already
created plans; it does not cache schema catalogues. Later,
`p168_retry → p128br_retry_plans → p128br_replan` reanalyzes schemas that were
previously refused. A successful nested schema calls
`p128bl_finish → nol_scalar_specs(book,book)`, scanning the same immutable book
again for each successful retry. The ordinary `nol_finish` has the analogous
append, but this experiment leaves that route unchanged.

`p140l_scan` already computes a catalogue for cross-edit cache validation. It
compares complete stored specifications before allowing reuse; it does not
provide that catalogue to the cold nested schema builders. Reusing cross-edit
state would introduce a different identity/invalidation contract and is not
needed here.

## The bounded change

[scalar-catalogue.bend](../../selfhost/tests/phase171/scalar-catalogue.bend)
replaces only `p128br_retry_plans` and adds private helpers. Six private copies of
the nested schema telescope/finish helpers retain their exact tests, order,
budgets and errors. Only their successful finish omits the request-global scalar
suffix temporarily. The retry loop then:

1. Keeps the original valid-schema reanalysis path unchanged.
2. Runs the ordinary `no_schema` path unchanged when rebuilding a refused schema.
3. For an actual successful nested schema, initializes a local `Maybe<specs>` by
   calling the unchanged `nol_scalar_specs(book,book)` once, or reuses the
   previously initialized value.
4. Appends it in the original position before running the unchanged analysis,
   worker candidate construction, patch join and final verifier.

The first failed schema does not cause an eager scan. Failed later schemas keep
the existing catalogue. Every entry starts with `None`; no global cache, source
hash inference, synthetic book declaration or persistent cross-request state is
introduced. The loop keeps the exact same `book` argument throughout. Private
helpers accepting the cache are not general independently authenticated APIs.

The immutable list values attached to every complete schema remain identical;
only physical sharing changes. The local intermediate schema and cache wrapper
are new allocations, and shared suffix reference counting must be charged in
measurements. This could lose on short inputs, despite removing repeated scans.

The [original pins and inverse comparison](../../selfhost/tests/phase171/scalar-catalogue-originals.json)
record that renaming the six copies back, restoring the original recursive
signature, and restoring the single catalogue append recovers all six exact
original declaration bodies. The source module is 115 lines, plus 20 lines of
forward signatures. This is temporary experiment duplication; an accepted
implementation should parameterize the common builders instead of maintaining
two semantic implementations.

## Gates

[scalar-catalogue-controls.bend](../../selfhost/tests/phase171/scalar-catalogue-controls.bend)
provides 12 finite checks. Its concrete nested datatypes force the ordinary
schema refusal and nested fallback, with a two-constructor scalar enum supplying
a nonempty catalogue. Comparisons include every schema field, complete analysis
term/fresh/fuel/error, first and repeated plans, failure before initialization,
failure after initialization, the unchanged ordinary route, and a fresh request
with a changed book requiring a different catalogue. These are prepared
controls; no pass is asserted before source checking and execution.

The shared Phase171 assembler should select:

```text
--prelude selfhost/tests/phase171/scalar-catalogue-laws.bend
--module selfhost/tests/phase171/scalar-catalogue.bend
--module selfhost/tests/phase171/scalar-catalogue-controls.bend
--replace p128br_retry_plans
```

Export `p171sc_controls` alongside the existing complete-request exports. The
root can run the existing finite-controls runner with `p171sc_controls:12`, then
compare complete QBE for the same small compiler/Map/lexer sources against the
baseline checked API. Run this independently of fail-fast first. Require exact
output and actual unchanged final verification. Only a complete-request benefit
justifies native acquisition and full maintained-source timing.
