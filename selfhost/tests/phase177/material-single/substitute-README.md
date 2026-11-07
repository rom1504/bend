# Frontend substitution dependency experiment

Root's native inspection found that `f_scope_app_span` and its `f_sub` dependency
had p111/p112 implementations but no p113d worker, while the other material-loop
dependencies already had p113d. This candidate addresses that concrete boundary.
No source checking, target execution or performance measurement was run by this
subtask, and no worker-admission success is claimed here.

Use `substitute-prelude.bend` and `substitute-single.bend`, replacing exactly
`f_sub`. This is independently usable; the material-single override is not
required to define or test it. `f_subs`, `f_scope_app_span` and all core
substitution functions remain unchanged. The entry law declares quantities and
types only, and its implementation is untyped.

`p177fs_loop` owns the complete term traversal. A frame holds an empty parent
shell, untouched siblings, and completed children in reverse order. Hits return
directly to that stack; misses reconstruct all children, including stored
children on a Var. All three term variants and every metadata field survive.
Apps are never beta-reduced or canonicalized by this operation. The original
`f_sub` also descends through Error, FName and same-id binders; those semantics
are preserved.

For a Var hit, the replacement is opaque. Only its root span is filled, and only
when both replacement coordinates are zero and its actual tag is not
`FUnboundVar`. Replacement descendants remain unchanged. Either nonzero coordinate
prevents filling; unusual occurrence spans are copied exactly. A KLiteral whose
kind text is `FUnboundVar` still has tag `Lit` and is eligible for filling. This
immutable replacement predicate is computed once at entry rather than once per
hit. There is no replacement traversal and no occurrence scan.

Add `substitute-controls.bend` to baseline and candidate and export:

```
f_sub
p177fsc_cases
p177fsc_value
p177fsc_actual
p177fsc_expected
```

The baseline retains the original checked `f_sub`. Run
`substitute-values.mjs --baseline REPORT --candidate REPORT --out FRESH` under
the root-owned guard. Its proposed 245 complete observations comprise three
paired exported values, two independent literal expectation comparisons and
240 varied substitutions. Each varied substitution compares all fields and
checks both input and replacement aliases. This is a finite gate, not a proof.

The 20 literal cases cover root span filling, opaque replacements, traversed Var
miss children, one-sided nonzero replacement coordinates, the FUnboundVar tag
exception and literal-kind distinction, same-id replacements and binders, Error
and FName children, lambda quantity presence, zero/maximal ids and unusual
spans, plus unreduced Apps of arity zero, two and three.

After this independent gate, inspect actual `p177fs_loop`, `f_sub`,
`f_scope_app_span` and `p177ms_loop` admission in the combined native candidate.
Passing values or obtaining private workers alone does not establish a speedup;
the combined materializer still needs the complete parsing/frontend transfer
comparison. Keep standalone substitution benefit and dependency-unblocking
benefit separate when interpreting measurements.
