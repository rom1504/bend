# Compiler analogue: cached-book field decoding

The closest actual compiler-source analogue is
`selfhost/tools/performance/phase88/base/decoder.bend:237`:

```text
p88_fields(state,tag,role::rest,values,left)
  -> p88_fields_next(p88_field(state,role),tag,rest,values,left)
p88_fields_next(P88Step(state,value),tag,rest,values,left)
  -> p88_fields(state,tag,rest,value::values,left)
```

The outlined field reader returns a heap-owned state/value record before the role
walker can continue. The continuation preserves remaining roles and accumulated
values; decoded arrays and cursor ownership cross the boundary. At termination,
`p88_fields_finish` reverses values, builds a typed node and inserts it in the
cache. The selected Phase121 compiler contains the same definitions at
`selfhost/build/phase121/fusion-source04/compiler.bend:38162`. This is a real
compiler request workload, not an invented benchmark analogy.

Existing Phase119 native compiler profiles contain this decoder family. Pooling
the four Phase118 captures yields758 physical-leaf samples, including
`$direct.p88_fields`1, `p88_field`1, `p88_build`1, `p88_record_put`1,
`p88_field_number`4 and `p88_number_read`2. Its numeric decoder `p88_digits` has19
samples (2.51%), the largest individually sampled compiler-source function in
that pool. `p88_digits` itself is a different mutual-tail-recursion shape; it is
**not** evidence that the new local-resume node can optimize it. The persistent
index also appears (`index_find`11, `index_insert`3), but is not a substitute for
proving this decoder chain's actual admission.

Evidence: `implementation/phase119/results.json`, `compilerProfiles` entry
`role:phase118`; raw analyses
`selfhost/build/phase119/compiler01/phase118-{1,2,3,4}.analysis.json`.
These are short physical-leaf captures, not inclusive caller attribution. They
establish decoder execution and compiler relevance, **not** the field walk's
share of compiler time or a predicted compiler speedup. The same report attributes
28.1% of all leaves to destruction/reclamation, without assigning them to this
particular producer.

If the ordinary controls and RLE first validate the mechanism, the cheap next
compiler check is an admission query for `p88_fields` and its direct field-reader
callee, plus an extracted small cached-record decode using the existing immutable
carrier/expected book. Check whether inlining exposes the mutual helper spelling
as one owner and whether `p88_field` is independently eligible. Large state records,
unknown calls or table budgets may still refuse it. Do not build another compiler
image or claim compiler-throughput transfer until that evidence exists.
