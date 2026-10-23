# A selected optimization can be bypassed by earlier inlining

The Stage2 name-search request admitted `has_name`, `has_name_next` and
`p88_string_eq` with empty schema, analysis, residual and QBE errors. The
coordinator's initial screen nevertheless found less than one percent additional
runtime reduction over Stage1. Admission and emitted private readers were
insufficient evidence of coverage.

The exact static evidence is in `callsite-audit.json`, tied to the SHA256 of
`selfhost/build/phase118/p128-borrow-layout-emit01/compiler-name-search.ssa`.
Its private digest function directly calls `$p126scc.37` with selector1, the two
actual parameters and padding0. It does not call the new `has_name` adapter.
The new adapter is reachable from the generic scheduler entry, which the hot
digest has already bypassed.

The old public `has_name` wrapper is exactly:

```text
has_name(x, y) = result of private_worker(1, x, y, 0)
```

The old `has_name_next` wrapper is exactly:

```text
has_name_next(x, y, same) = result of private_worker(0, x, y, same)
```

Earlier ordinary inlining copied these equations into callers. Installing an
equivalent optimized implementation at the public entry did not update their
already expanded calls. The loss is a composition boundary, rather than an
insufficient borrowed-layout proof or evidence that borrowing the list is slow.

`restore-boundaries.bend` recovers only the general exact equation: an original
public function has a two-statement direct call followed by its unchanged single
result; the call arguments are constants and a bijective permutation of its
parameters. An independently selected observer replacement gives a valid new
implementation of that same function. Later original calls to the worker that
match every literal constant can therefore use the new entry and inverse
parameter mapping.

The implementation uses the existing hash index keyed by callee; it contains no
SCC identifiers, source names or benchmark names. It rejects unknown selectors,
different high constant bits, missing or repeated parameter bindings, changed
results and ambiguous matching rules. Repeated parameters are conservatively
refused even when particular actual arguments compare equal; no new ownership
duplication assumption is made.

Rules become available only after the original wrapper's position. Generated
reader/adapter/fallback groups are spliced unchanged; in particular, an owning
fallback cannot be redirected back to its own adapter. The unchanged final
verifier checks the complete function list from an empty ready set. Fifteen
finite mutation and ordering controls are in `boundary-controls.bend`.

The source-level rule is cheap and bounded, but performance must still be
measured. The next decisive evidence is that the hot digest's actual call now
targets the selected observer, that take/drop work falls, and that independently
checked outputs and unrelated transfer remain correct. This note records the
cause and proposed repair, not a demonstrated runtime improvement.
