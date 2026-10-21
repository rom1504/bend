# Phase123 RLE state-lane ceilings

Preparation only, starting from`3a31b86`. No target execution, compiler build,
compiler hook, production change or performance claim was made by this audit.
Root owns the serial target lane and the measured results.

The frozen source is
`selfhost/build/phase93/fixtures01/test-rle-roundtrip.bend`, SHA256
`b46580acb1656502d0e37a0115d172529e648719acb75eadb3b9ad45db5b078d`.
The current runnable candidates are`phase123/rle-v2-outer.bend` and
`rle-v2-full.bend`. The entire Phase93 wrapper suffix, entry point, runtime
arguments`[0,0]`, expected result11, and independent upstream oracle remain
unchanged. Source/helper changes occur before the wrapper.

* **Outer:** move `cur` into its own loop argument while retaining the source
  pair`(count, accumulator)`. The original public `rle(xs,state)` signature
  remains a one-time adapter.
* **Full:** carry `cur,count,accumulator` as three loop arguments. Retain the
  actual encoded pair/list allocations, final reversal, shared code list, length
  check, expansion, concatenation and digest. There is no round-trip shortcut.

Both candidates use small completed helpers whose Bool argument selects the
next current value, count and accumulator. The equality is computed once.
Count arithmetic wraps through exactly the original`U32.add`; equal runs create
no encoded pair, unequal runs prepend`(n,cur)`, and finalization always flushes
the current state before reversal. Scalar duplication does not duplicate the
owned accumulator. Ordinary helper inlining can eliminate the call boundaries.

These are ceilings, not isolated ABI-only experiments. The source distributes
the original step result into fields. Existing product lowering might flatten
the remaining outer-candidate pair automatically; inspect actual QBE before
claiming a one-shell/two-shell contrast. Newly enabled private calls and
predicate cleanup may contribute to a measured gain.

## Controls and retained failure

`rle-v2-controls.bend` contains renamed reference/outer/full implementations.
Eight complete-input cases cover empty/singleton, mixed runs,17equal values,
17distinct values, zero and UINT_MAX payloads. Six directly seeded states cover
zero/MAX counts and count wrapping without attempting enormous expansion.
The state cases retain an accumulator alias after all three computations;
mixed runs create live dynamic accumulator nodes, while seeded literal lists
also exercise shared/static data. Each case prints full pair contents for all
three implementations and the retained input/accumulator,56output lines total.
An independent imperative run-list model supplies expected output; no checksum
or compiler-generated expectation is used. These are finite controls, not a
general ownership proof or sanitizer result.

Version one is preserved under`rle-*` without the`v2` infix. Its first emission
was rejected because Bend prohibits matching a computed value:
`selfhost/build/phase118/p123-rle-emit01/report.json`. Version two moves Bool
matching to dedicated definitions before use. `rle-prepare-v2.py` reproduces the
corrected files;`rle-v2-manifest.json` pins generator, inputs, outputs and the
rejected manifest. Preparation itself ran no compiler or target.

## Exact integration interface

From the repository root, use the existing checked Phase121 source/API and
Phase118 runtime. Within the normal CPU3 guard, emission is:

```sh
env P118_RUNTIME_REPORT=selfhost/build/phase118/runtime-extend01/report.json \
  P118_CASE_MANIFEST=selfhost/tools/performance/phase123/rle-v2-cases.json \
  selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase118/emit-integrated.mjs \
  selfhost/build/phase111/p121-api04/report.json \
  selfhost/build/phase121/fusion-source04/manifest.json \
  selfhost/build/phase118/p123-rle-emit-NEW \
  test-rle-roundtrip-v2-outer test-rle-roundtrip-v2-full
```

For the unchanged existing screen use`phase121/screen.py --manifest
selfhost/tools/performance/phase123/rle-v2-cases.json --emission
selfhost/build/phase118/p123-rle-emit-NEW/report.json --out
selfhost/build/phase121/p123-rle-screen-NEW --label p123-rle-NEW --rounds 3
--scale 4`. Its`parentName` mapping correctly reuses the original frozen
counts and qualified parent product. Do not call diagnostic sources new members
of the original45 or incorporate their ratios into the unchanged corpus score.

For controls replace the emission case manifest with`rle-v2-controls.json`
and case name with`rle-v2-controls`; then use`phase118/functional-v2.py`
with that same manifest, the emitted report, and fresh Phase118 output/label.
All build/execution commands remain guarded and serial. Commands above are
instructions for root, not a claim that they ran.

## If the ceiling succeeds

First inspect why`nq_layout_leaf` at`selfhost/src/back/native/product-layout.bend:47`
rejects finite nested Sigma merely because its ADT name matches the outer
owner. Existing flat arguments and tail-self edges already work. A bounded
type-instance distinction might admit one shell with little new machinery;
retaining the inner box keeps the current one-word-field contract. Do not remove
the guard globally without preserving dependent/recursive fallback.

If both shells matter, introduce a bounded compositional layout descriptor with
field ownership and exact constructor identity, then extend existing bundles,
entry/return adapters and backedges. That is a new representation capability,
not a larger inlining budget. Require transfer to a differently shaped record
or parser state before broad qualification. Preserve all negative ceilings and
measure compiler cost as well as runtime.
