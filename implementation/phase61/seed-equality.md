# Full seed-text equality

Status: source applied by explicit root authorization; focused checked-image
[controls](../../selfhost/build/phase61/seed-controls01/report.json) completed PASS
for all 27 equality pairs and 10 binding cases. Broader measurement/promotion remains separate.
The only behavior-bearing source edit replaces `f_seed_text_equal`'s tail-recursive
Char equality scan with `String.eq(a,b)`. Exact Base name, full path, nonempty path,
and full text checks in `f_seed_matches` remain unchanged. No cache state, digest,
prefix comparison, trusted flag or loader graph rule changes.

[Preserved source, patch and identities](../../selfhost/tools/performance/phase61/seed/).
[Related primitive design and Unicode argument](../../design/phase61/primitive-selection.md).
The installed checked last01 API's actual `$String$eq$` function has a primitive
String `===` fast path and source fallback. This is a readback fact, not yet a
new candidate execution observation. Primitive transport text is the loader input
scope; changing internal loader implementation does not assert identical traces
for arbitrary overridden String methods or boxed/proxy String arguments.

`controls01.mjs` is a private checked-image probe. It verifies attempts and exact
snapshot seed source, rehashes API/runtime/Base/tool inputs, appends diagnostic
exports to fresh API copies and records each image's actual equality function.
Its 27 pairs cover empty and unequal text, 60k/100k equal/early/middle/final/length
mismatches, astral and isolated surrogate characters, NUL, no Unicode normalization,
a long mixed string, and exact pinned Base text. Ten binding cases cover exact
Base/name/path/text, completed/located wrappers, and changed/truncated inputs.
The source objects remain unchanged. No fabricated checked sidecar is created.

```sh
node selfhost/tools/performance/phase61/seed/controls01.mjs \
  selfhost/build/phase58/checked-last01 \
  selfhost/build/phase61/checked-combined01 \
  selfhost/build/phase61/seed-controls01
```

Root supplies the existing external process-tree guard: scheduled CPU3, initially
60-second deadline, 1 GiB heap/2 GiB tree RSS. Node syntax checking passed on CPU0;
no compiler, generated program or diagnostic target was executed by the author.
A focused PASS must precede retention; broader conformance, own-source compilation,
first/later request latency and allocation remain independent integration gates.
