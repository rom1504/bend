# Do not render arguments just to choose a tail-transfer path

`jd_doc_return` previously built full `JDArgs` for a call inside its current SCC.
`jd_arguments` renders every supplied live actual to a JavaScript string and
constructs a list of those values. The only consumer, `jd_doc_return_self`, does
not read the values. It tests the remaining actual list and the missing live
formal count, then emits the selected path using the ordered emitter, which
renders actuals itself. The first rendering and its lists were discarded.

The isolated [candidate](candidate.patch) changes that one call to
`jd_argument_shape`. It replays the original telescope traversal and retains the
same `rest`, `typ` and `missing` in `JDArgs`, with an empty `values` list. The
consumer remains unchanged. Public `jd_arguments` remains unchanged and is the
independent oracle. The proposal adds 13 physical lines to `core.bend`, two
private functions, no type or cache. Patch SHA256:
`7186b6ea46318e912ab337dc57b93fab53a43d013357664c387498bbc0335ba5`.

Exact corner behavior matters:

- At `left == 0`, return the actual remaining list and raw type without WNF.
- At `left > 0`, normalize the type before examining even an empty actual list.
- A consumed actual uses the same `j_app_type`; do not introduce an All guard.
- The final consumed actual leaves that substitution result unnormalized when
  `left` becomes zero. Missing-formal classification is still the original
  `jd_live_arity` computation in the unchanged consumer.
- Choice handling, SCC membership, owner, parameter order, argument evaluation
  order and final emitted refusal markers still belong to their old emitters.

The removed expression construction is pure compiler string construction;
`jd_fail` returns a string containing a runtime failure, it does not throw while
constructing that string. Those discarded strings never contributed markers to
the old result. Both resulting emission branches still render the actual output.
This reasoning does not claim divergence equivalence for arbitrary forged raw
input whose discarded rendering does not terminate.

## Differential controller

Run [compare.mjs](compare.mjs) only through the root-owned serial CPU3 guard:

```
node compare.mjs CHECKED_ATTEMPT NEW_PHASE64_OUTPUT [LATENCY_CATALOG [CASE_ID...]]
```

The checked image must contain `jd_argument_shape`. The append-only derivative
pins the source/API/runtime/Base/driver/workflow/Node and inputs. A wrapper around
`jd_doc_return` captures its exact environment, then compares complete JDText
with the shape helper enabled against the original full `jd_arguments` in that
same environment. Nested returns retain their own environments; comparison is
only doubled at the outer active boundary. Handwritten JS composition forces
Bend trampolines before consuming intermediate results.

Each real source is also compiled with all shape helpers replaced by full
argument rendering; its complete generated module must be byte-identical. At
least one source must activate the optimization. Twelve synthetic controls
compare exactly `rest`, `typ`, and `missing`, including zero/empty, partial,
erased-only missing suffix, overapplication, non-All telescopes and a dependent
result. `values` must be empty in the shape result and is intentionally not part
of the equality projection.

The derivative counts lexical `jd_expr`, `jd_ordered_expr`, WNF, substitution and
application-type queries, and separately attributes queries inside the original
discarded rendering. Generated shared SCC paths can hide internal operations;
these counters are an activation/work oracle, not exhaustive cost accounting.
No instrumented clocks are used as performance data. Root clean latency and
broader correctness gates decide selection independently.
