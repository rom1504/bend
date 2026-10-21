# Captured packing-scan stack failure

The root's `phase111/p118-native-safe02-full-emit/report.json` records6384source
and book definitions,3239live names, frontend255.526s, then integrated-entry
failure after0.966s. Its pinned `error-stack.txt` has `nc_foreign` at the top and
repeated `nc_pack_foreign` rest recursion at checked API line5614. This identifies
an actual stack-depth failure during `p112s_prepare`, before ordinary lowering
completes; it is not merely a suspected new Phase118 observer/transport pass.

`native-pack-stack.bend` changes only production definition `nc_pack_foreign`.
The exact old per-definition predicate remains:

```
!trusted && (unannotated value is Foreign || (kind is Def && nc_foreign(d)))
```

An explicit list-of-lists worklist visits each definition, its `dc(d)` children,
then its following siblings. This preserves traversal of cached/index children,
which must not be skipped. A direct self-tail-call accumulates the OR result;
there are no closure-recursive calls or list concatenation on the traversal.
No constructor representation, foreign permission, or validation rule changes.

`p118np_controls()` compares eight finite cases against both literal expected
Booleans and the exact old recursive predicate: ordinary definitions, trusted and
untrusted foreign definitions, absent/unfilled Def, annotation, cached children,
and following siblings. `p118np_scale(32768)` exercises flat and deeply nested
catalogues with no foreign entry and with a final/deep foreign entry. It never
emits or executes these analysis fixtures; the diagnostic input caps at65536.

Immediate caller review: `p112s_ctors` and `p112s_block_effects` already use direct
tail loops. `p111_effects`, `p112s_defs`/`p112s_def_step`, and `nc_constructors`
retain closure/mutual/list-rebuild patterns over catalogues. They are possible
future size limits but are not implicated by this captured stack and are left
unchanged. Leaf `nc_unann` depends on annotation nesting, not catalogue length.

Root must check the new API, verify hosted loop generation, run the finite/large
controls, compare existing ordinary outputs, and retry qualification. This note
reports source evidence and a proposed repair; no new success or speedup was
measured by its author. The failed sources/methods remain frozen.

Module SHA-256 at handoff:
`8493ca54b61bc20920b16111c93f82b488590ce6994e28fb7fa433e4ca062b1e`.
Captured stack SHA-256:
`a9dffd2c4102b8ca349f812f3661eaaace68bd6d609a178851de8194f1522c84`.
