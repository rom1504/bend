# Discarded child-type reconstruction

The candidate removes nine eager parent type computations when the exact child
is an `Ann` and the unchanged next consumer immediately replaces that incoming
type with the child's annotation. It adds four private guards, 26 physical Bend
lines, and no allocation, prepass or cross-context fact table.

The immutable proposal is [candidate.json](candidate.json), its five before/after
source pairs, and [dead-child-types.patch](dead-child-types.patch), SHA256
`2b3ec4c8d3c3670d7309df6a75ce743a08aff60a86835343d62284efdaa14eb2`.
`applied:false` and `checked:false` describe that proposal's creation, not later
root-owned integration. Root receipts identify what was actually built.

| Parent sites | Discarded work | Guard and unchanged consumer |
| --- | --- | --- |
| Three direct lambda-body sites in `core.bend` | `j_app_type` substitution | Direct child `Ann`; `jd_doc_body` uses its saved type |
| `jd_calls_lambda` | `j_app_type` substitution | Direct child `Ann`; `jd_calls_body` still visits/charges the Ann node |
| Ordinary `jd_calls_match_other` arm | `j_arm_tel` reconstruction | Direct arm `Ann`; field count, fuel and scan refusal unchanged |
| Ordinary `jd_doc_match_emit_at` arm | `j_arm_tel` reconstruction | Direct arm `Ann`; `jd_doc_body` uses saved type |
| `jd_doc_word_bind_type` | `j_app_type` substitution | Direct child `Ann`; binder consumer overrides type even at zero fields |
| `j_layout_lam` | Unconditional `subst` | Direct child `Ann`; `j_layout_term` overrides type |
| `j_layout_match` | Ctor lookup, WNF, specialization and `j_arm_tel` | Direct child `Ann`; layout visitor overrides type |

Numeric Word row branches strip annotations before consuming the derived type;
they retain their original computation. A `Rwt` containing an annotation is not
a direct `Ann` and retains its original computation. Layout's raw lambda fallback
uses the original unconditional substitution, including for a non-All raw type;
it is not replaced with the different `j_app_type` fallback.

The local semantic argument is consumer behavior, not equality between derived
and annotated types. The actual child, environment extension, quantity tests,
field counts, default-arm traversal, layout-open checks, refusal conditions and
call-analysis budgets remain. `subst` can beta-reduce, so this is not a universal
termination-equivalence claim for forged ill-typed raw trees. The ordinary
annotation producer already completed corresponding specialization before
producing the unchanged child annotation. No explicit failure/budget computation
is removed at these sites.

## Root-owned checks

[compare.mjs](compare.mjs) accepts:

```
node compare.mjs CHECKED_ATTEMPT NEW_PHASE64_OUTPUT [LATENCY_CATALOG [CASE_ID...]]
```

Execute only through the repository's serial CPU3 process-tree resource guard.
The default two cases are Numeric recurrence and MapSet; a catalog may select
at most 32 actual source cases. The checked candidate must contain all four new
helpers. This controller cannot operate on the preceding State02 image.

The derivative is append-only and pins its parent API, source/runtime/Base,
workflow, Node, driver and inputs. Its diagnostic wrappers compare full enclosing
JDText, JDCallScan and layout-worklist results with optimization enabled versus
all original formulas forced. Every explicit JavaScript composition forces the
intermediate Bend trampoline. Ordinary wrappers retain the compiler's native
trampoline return protocol. Nested consumer wrappers are not recursively doubled.

Each source is also compiled with all four helpers forced to their original
formulas; the complete generated JavaScript must match exactly. Counters separate
admission/fallback and lexical WNF/substitution queries. Shared generated SCC
workers can obscure internal operations, so these counts are controlled logical
observations, not exhaustive work accounting or performance measurements.

Synthetic supplements cover raw and Rwt-child fallback, the raw non-All layout
lambda, call-scan fuel 0/1/2/8, and ordinary match fields 64/65. They compare the
whole scan where the optimized helper may return a different discarded type.
At most 100,000 helper calls and 64 MiB of compared serialization are accepted.
Synthetic controls run after the saved real-source counters and do not inflate
the reported source admission counts. Root-owned clean latency measurements and
broader emission/semantic gates remain distinct from this instrumented oracle.
