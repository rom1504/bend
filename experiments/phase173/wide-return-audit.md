# Independent audit of the explicit eight-field return experiment

Source-only review of the four alternatives pinned by
[`wide-return-source-v2.json`](wide-return-source-v2.json). No target, compiler or
benchmark was executed. No measured source was edited.

The transformation is a source ABI experiment:

```text
Tuple(Store(nodes,edges,used,edgeUsed,nodeCapacity,edgeCapacity,ok), value)
  ↔ Return(nodes,edges,used,edgeUsed,nodeCapacity,edgeCapacity,ok,value)
```

The field order is consistent in the type, pack helper, direct producers and all
consumers. Both Array fields retain their linear ownership. Bounds, capacities
and status retain the Store's existing quantities. Revision2's payload field
and pack parameter have default affine quantity, matching pinned Base's
`Tuple{fst: A, snd: B(fst)}` at line26. Revision1 used `+value`; it remains a
separate frozen candidate and is not the exact quantity-preserving ceiling.
Each consumer either forwards both array handles once through the immediately
reconstructed Store or drops them at the same terminal ownership boundary as
the original unused Store. No mutable alias, clone or fork is introduced.

I independently tokenized the original and replacement sources and inverted the
return mapping. This did not execute or reuse the author's transformation code.
The inverse checks exact consumer binder order/quantity, converts each explicit
eight-field producer and pack call back to Tuple/Store, and removes only the
inserted Return declaration and pack definition. All original lexical tokens,
including string literals, then match exactly:

| Original | Alternative | Identical original tokens |
|---|---|---:|
| store-flat7.bend | store-wide8-v2.bend |7,777|
| store-compact.bend | store-compact-wide8.bend |7,448|
| store-controls.bend | store-controls-wide8.bend |2,260|
| vertical-store.bend | vertical-store-wide8.bend |617|

All original/output SHA256 values match the cited revision2 receipt. The full
independent inverse was first run on revision1; an additional token comparison
proves revision2 differs only in the two inserted payload-quantity annotations,
which are removed by that inverse. The twelve original
Array operations are unchanged; their Tuple contracts are not rewritten.
Compaction, import/export ordering, metadata, error strings, fuel arithmetic,
validation and complete observation expressions are consequently unchanged
outside the explicit return shell. This is strong source-change accounting,
not a mathematical equivalence proof or a claim about generated ownership code.

The candidate is worth a bounded emission gate. Its advantage over merely
reducing Store9→Store7 is that the Return exposes the Store fields across the
producer's **result** boundary, where a shallow Tuple2 previously still boxed
Store. However, all eight return lanes must actually be admitted, `p173r_pack`
must compose with callers, and reconstructed Store arguments must stay virtual.
Otherwise the experiment can move allocation or add a wrapper. Eight lanes may
also increase spills or result-buffer traffic even when boxes disappear.

Require actual generated constructor/take removal on the read→resume path,
unchanged independent final verification, complete finite/native oracles and a
matched whole-consumer runtime observation. Do not infer a durable-store or
whole-compiler speedup from a successful source inverse or flat admission count.
