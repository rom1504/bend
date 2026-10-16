# Certified scalar borrowed calls

Current first-stage candidate:
`selfhost/build/phase99/borrowed-calls-source03/compiler.bend`, SHA-256
`3a3d9c098fc8d091e0fde08f2b02a54e6fe96e5e0705ca8195144acb4cae5ccb`.
It is an exact Phase98 `2a72bbdc…` derivative, adding 123 physical lines and
8,337 bytes. Root's `borrowed-small02` checked API generation passed; complete
runtime qualification and performance decisions belong to the root reports.

Reproduce the source without running a compiler, using a fresh output path:

```sh
python3 selfhost/tools/performance/phase99/borrowed-calls/prepare-v3.py \
  --out selfhost/build/phase99/borrowed-calls-source04
```

The recipe records exact ordered old/new strings and offsets, complete source
pins, method/helper pins and an exact inverse replay. Canonical modules,
Phase98 artifacts, runtime code and scalar experiment files stay unchanged.

`helpers-v3.bend` supplies a private schema registry, borrowed-call checks and
emission. Only successful admission of both fresh private workers publishes a
scalar callee. Each root actual must be a concrete atom of the exact supported
plain type and have ancestry under a matching caller entry root. Scalar results
use fresh observation origins and full `Term` storage. Calls target only the
private borrowed worker, carry its dependency, and preserve success/error checks.
Existing owning adapters and unique-root fallbacks remain responsible for RC.

The existing root schemas are unchanged: no applied types, aggregate KTerm
projection, virtual-root call arguments, foreign calls or closure escapes are
added. Helper cycles still refuse. Only helper-cycle/depth refusals are queued
for one retry after the first route pass; existing certificates are skipped.
For N candidates and P queued names, analysis attempts are at most N+P, P≤N
for the existing unique live-name input. The final pending list is inspectable
through `no_route_pending`; there is no unbounded retry loop. Entry indexing
is currently built twice, but the second pass does not analyze the whole book.

Original public analysis/emitter APIs use empty registries. `api-exports.json`
describes the unchanged compile APIs and optional inspection exports.
`fixtures.bend` and `api-cases.json` prepare 15 finite predicate controls for a
test API. Append those fixtures only to the test source. They use synthetic
internal schemas to challenge type, arity, ancestry, alias and refusal checks;
they do not mint production authority or replace real compiled-program tests.

Preserved attempts:

- `prepare.py` / `helpers.bend` / source01: offline draft; the new emitter used
  String where Phase98's `NC_Code` requires `NC_Text`. No target run.
- `prepare-v2.py` / `helpers-v2.bend` / source02: root's checked API refused an
  affine `rest` captured by two branches in `nob_live_root` (`borrowed-small01`).
- `prepare-v3.py` / `helpers-v3.bend` / source03: marks that tail shared and
  preserves the text-tree fix. Checked API passed. `borrowed-small02` later
  stopped on a separate aliases test-source parse error; it is not a full pass.

The [initial audit/design](../../../../../implementation/phase99/borrowed-tags.md)
remains the record for the wider tag projection work. This candidate implements
only its certified-call stage, using existing String layouts.

Root follow-up: `borrowed-small09` completes 18 predicate cases and 13 native
executions using `fixtures-v4.bend`, `api-cases-v2.json` and `unique-v2.bend`.
The latter preserves filled-definition order; the attempted reversed declaration
was invalid upstream and is retained as a failed fixture, not a compiler defect
or retry test. `borrowed-small05..08` retain those fixture annotation/order and
expected-policy failures. Source03 is unchanged. See the Phase99 report for the
6.8% micro reduction, neutral B1 screen and subsequent integration decision.
