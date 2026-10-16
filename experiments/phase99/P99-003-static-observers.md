# P99-003: borrow roots whose cleanup is trivial

Status: design before candidate execution; isolated refinement of P99-002.

The exact self C admits four additional call wrappers, but its existing redirect
uses `ANY(root has RFC count > 1)`. Closed String literals occupy the static image
and have no RFC bit. Static/static comparisons therefore keep the ordinary
consuming route, even though their graphs live for the whole process.

The runtime's `term_triv` covers immediate/packed terms and static locations.
`term_sink` returns immediately for those values. Existing checked schemas still
establish valid observer roots; this runtime predicate grants no type or foreign
provider authority. Extend only the execution-cost guard to:

```
existing ANY-shared condition OR ALL schema roots satisfy term_triv
```

Keep the original shared condition first, private-worker certificate, owning
adapter and exact ordinary fallback. Two unique dynamic roots and a unique dynamic
root paired with a static root retain the old fallback. This is deliberately
narrower than forcing all nonrecursive wrappers through observers: a callee can
still walk recursively, and that wider policy could add disposal traversals.
No function-name exception, runtime edit or array/layout permission change.

First acquire a testing API from an exact Phase98-based recipe extending the
source03 call implementation. Reuse the 18 predicate/13 native controls and full
value/alias checks, verify the new guard and both fallback cases, then benchmark
static and dynamic retained-root comparisons in balanced order. Add a small
source-bound guard-emission law if useful; it will not prove native lifetime.
Only a measurable affected-workload gain warrants another full compiler image.
Source03's full native result remains a separate observation, never relabeled
as evidence for the refined source. Preserve failures and unchanged default until
complete source-specific qualification.
