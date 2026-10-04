# P45-003 — Scalar fields for admitted native projections

- Owner: Phase44 IR agent; integration and execution: root.
- Status: compiler patch prepared; no candidate build or execution yet.
- Baseline: installed Phase44 checked04, pinned upstream
  `018751270e800bc222a93dad7f257083ee53a5f7`.
- Claim: eliminating temporary field vectors in already admitted private native
  matches reduces executed allocation and can improve several unrelated sources.
  This is an operation/layout rule, with no source-function or benchmark names.

## Evidence and scope

The [Phase44 profiles](../../implementation/phase44/diagnostics.md) attribute
16.2% of Map's sampled allocation weight and 6.5% of its CPU self weight to
`project`. These are instrumented sample shares, not predicted speedups.
Two private prefix emitters independently materialize a vector with
`project("SCon", value)` and immediately read its fields.

Read-only counting in
`selfhost/build/phase44/full-preparation04/manifest.json` found these static
private projection assignments in three source modules:

| Source | SCon | Chr | SNil |
| --- | ---: | ---: | ---: |
| Lexer | 8 | 8 | 8 |
| Unicode text | 28 | 16 | 28 |
| Map churn | 12 | 13 | 12 |

These counts do not establish execution frequency. Other programs, including
record aggregation, retain substantial generic dispatch outside this scope.

## Implementation

The new [projection plan](../../selfhost/src/back/js/ir/projection.bend) has four
explicit alternatives: no native view, empty String, nonempty String and Char.
It uses exactly the prior `j_string_string` and `j_string_char_type` predicates
and constructor-name checks. It does not grant an ownership or entry proof.

Both `j_finite_emit_match_tagged` in `finite.bend` and
`j_component_emit_match_tagged` in `tree.bend` consume the same plan for the
condition, scalar bindings and field names. The old string condition/field-vector
helpers are removed. Other layouts retain their existing lowering.

For SCon, the generated bindings have this shape:

```js
const input = value;
const head = input.codePointAt(0);
const tail = input.slice(input.codePointAt(0) > 65535 ? 2 : 1);
```

The input expression is evaluated exactly once at the former projection site.
Both original `codePointAt` calls remain. JavaScript still resolves `slice`
before evaluating its argument, preserving that original ordering. The Char
view retains the original `typeof input === "string"` alternative. Even SNil
captures the input expression, despite having no fields.

The existing private host/source/input proof is necessary: it excludes the
request/prototype hooks that public `project` must continue to observe.
The public runtime, matcher behavior, representations, force points and worker
stack policy are unchanged. The implementation removes only private temporary
projection vectors and their indexed reads.

Changed production files are `src/back/js/ir/projection.bend`,
`src/back/js/finite.bend`, `src/back/js/tree.bend` and the module entry in
`src/compiler.json`. The separate String primitive admission experiment changes
`jpure.bend`; execution should retain separate candidates or an explicit ablation.

## Smallest falsifiers and decision

1. Build a checked candidate and verify the admitted assignments become scalar
   fields, while generic/public projection code remains intact.
2. Differentially test empty, ASCII, supplementary-plane and malformed strings,
   plus both accepted Char representations. Verify renamed or forged native
   constructors still refuse admission.
3. Mutate `String.prototype.codePointAt` and `slice`, including getters; add
   request/bounce/build hooks. Existing guards must take the original fallback
   with unchanged effects and error order. Retain public alias/getter cases and
   deep recursive result controls.
4. Establish executed activation and allocation reduction on the existing lexer,
   Unicode-text and Map cases before attributing any timing change.
5. Run the bounded short performance screen serially. Escalate only a repeatable
   useful signal; preserve neutral results and regressions. The measured effect
   of this patch must not be conflated with separate admission changes.

No speedup, conformance result or production promotion is claimed in this
pre-execution record. Root will link immutable attempts and decisions from the
Phase45 implementation report and ledger.

## First isolated screen — mixed; longer confirmation pending

Root built `selfhost/build/phase45/checked-projection01`. Its selected API SHA256
is `2f9f22d9a5c80cb5b93736b3be89b3e19ad2a779d52a92b7c2d3be55a4b05d2d`.
A read-only comparison of source snapshots confirms the only changed Bend files
are the new projection module and the two consuming emitters. The separate
`jpure.bend` admission change is absent from this candidate.

The [screen receipt](../../selfhost/build/phase45/runtime-projection01/report.json)
is complete and passes all three cases and 27 role samples. Root used the
60-second preset, three rounds, CPU 3 and the existing resource limits; actual
wall time was 22.44 seconds. Baseline is freshly executed Phase44 checked04,
with pinned TypeScript as the third role.

| Case | Baseline median ms | Candidate median ms | Baseline / candidate |
| --- | ---: | ---: | ---: |
| Lexer | 12.73395 | 7.43917 | **1.71174×** |
| Map churn 128 | 22.55923 | 20.85039 | **1.08196×** |
| Unicode text 64 | 2.13334 | 2.21128 | **0.96475×** |

The lexer result is a strong positive signal in this short screen. The outcome
is mixed across sources: Unicode is about 3.65% slower. Map's within-window drift
is approximately −32% to −37% for both Bend roles; Unicode's is approximately
+15% to +20%. These short-window numbers are not a settled estimate of steady
state or universal benefit. Retain the patch for longer controlled confirmation,
with no production promotion or full-corpus speed claim from this screen alone.
