# Phase110 independent expanded controls

`manifest.json` froze 29 new input graphs at **2026-10-18 19:05:48 UTC**, before
candidate selection. It pins exact input data, mathematical reference code,
six independent output sets, actual source declarations and the unchanged
Phase109 controls. The Phase109 oracle is not edited or relabeled representative.

The new matrix has 11 training and 18 held-out graphs. It includes 65,536-element
list **and string** unique/shared runs, alias tails reached after many unique
nodes, 65,537-element boundary depths, long opaque String heads, two retained
roots, interior String-head aliases, null codepoints, Unicode scalar boundaries,
combining marks and static nodes. Static graphs fit the adapter's existing
128-word static arena; deep static graphs require another runtime descriptor.

Exact compiler lexer/text source snapshots supply line-list and character-string
replay sets. These preserve real source contents but are not sampled runtime
distributions. Profiling those selected workloads can identify their physical
costs; the fixture choice alone establishes no whole-compiler hotness or weight.

`sources/base-selectors.bend` reaches the actual imported Base `List.tail` and
`List.last.go`, two distinct algorithms admitted by the existing owned operation
shapes. They require new source entry selection, not a compiler algorithm in C.
`nt_append` is a frozen ordinary/nested-call extension target; `String.drop` is a
deferred Nat/unary-constructor target. Source preparation is not checked admission
or executable qualification. Root's separate receipts own those results.

Prepare data without executing any compiler or target:

```sh
python3 selfhost/tools/performance/phase110/controls/prepare.py \
  --out selfhost/build/phase110/controls-reverse02
python3 selfhost/tools/performance/phase110/controls/prepare.py \
  --variant last --out selfhost/build/phase110/controls-last02
python3 selfhost/tools/performance/phase110/controls/check.py
```

Variants `reverse`, `discard`, `duplicate` select all 29 graphs and retain the
existing two worker export names. `tail`, `last`, `append` select 15 list graphs
and respectively require `nx_list_tail(ctx, list)`,
`nx_list_last(ctx, list, StringAccumulator)`, or
`nx_list_append(ctx, list, list)`. `lastAccumulatorCodepoints` freezes the
String default independently of the reverse/append list accumulator. All
results and retained aliases are observed after the result is dropped, and each
repetition checks allocator release and agreement with the first observation.
The separate checker compares complete captured output to the independent oracle.

`--split training` or `--split heldout` prepares a disjoint selection. The
training/held-out labels and policy objective are frozen in `policy-search.json`.
Do not adapt a winner after reading held-out results. Keep failed candidate,
semantic, timing, build-cost and acquisition receipts separately.
