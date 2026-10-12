# Residual tree work after cold stores

Root reported the first bounded saved-C screen as mode-only 570 ms, reuse-only
556.5 ms, cold-only 459.5 ms and cold+reuse 426.5 ms, with same-campaign upstream
274 ms. These are finite diagnostic medians, not a promoted compiler result.
Authoritative records are `selfhost/build/phase69/node-reuse-diagnostic01`.

The prior counted input cycle localizes allocation gaps. Starting from mode-only
candidate counts, removing all 204,800 extra RFC redirects would leave 434,132
allocation calls; reusing the zipper's two nodes across 81,904 calls would remove
another 163,808, leaving 270,324 versus upstream 231,426. This is **arithmetic
prediction from source-site counts**, not a new counter measurement. The
remaining ~38,898 predicted excess calls are primarily 26,624 Nodes and 12,272
Stat shells, plus formatting noise. Consequently counting alone would suggest
that most allocation disparity is addressed by the two saved-C mechanisms, but
426.5/274 still leaves roughly 1.56x time. Call/layout overhead must be measured
independently before assigning that whole residual to memory.

Upstream's `flow` zero-depth Node branch reuses its matched node. Our version
extracts/frees and rebuilds the same constructor. An identity reconstruction
optimization could avoid that shell, provided it retains match demand and every
field ownership fact. The nonzero-depth recursive flow branch frees its node
upstream too, so broad reuse across recursion is not necessary to reproduce
upstream and would introduce avoidable lifetime/space questions.

Our Stat join uses an already flattened private four-word helper but boxes its
result to a one-word scheduler ABI; upstream's scan and continuations retain the
four result words. This is the shared multiword-transport lane, not a tree-only
arithmetic trick. It explains most of the smaller remaining Stat allocation gap.

The larger independent branch/code-shape lead is the private leaf workers'
generic scalar parameter types. `warp_leaf` and `warp_leaf.go` are major profile
sites and retain scalar keeps plus packed-Leaf heap fallback. Upstream accepts
u32 parameters and emits immediate Leaf payloads directly. P69-008 tests only
parameter C type information, leaving all helper bodies intact so the C compiler
can expose the actual benefit. Analogous opaque scalar slots exist in lexer and
Map workers.

Finally, upstream's recursive `warp` is still scheduler based, but its leaf
branch directly calls the leaf worker and its join directly calls the zipper.
Our scheduler bodies can route through additional dispatch adapters. A direct
scheduler-to-admitted-worker call is a separate general mechanism, overlaps
with narrowed signatures/inlining, and needs bounded-stack/error/polling proof.
Replacing all scheduler recursion with C recursion is not justified by upstream.

## Typed-signature result

Root's completed `selfhost/build/phase69/typed-tree-diagnostic01/report.json`
records medians of 662 ms original, 459.5 ms cold-only, 397 ms typed private
leaf workers and 274.5 ms upstream. Thus the saved signature-only derivative
removes 13.60% of cold-only time (1.157x faster), leaving 1.446x upstream in
this finite same-campaign witness. Threads 1 and 4 controls passed according to
root's acquisition. The original/reused timing campaigns remain distinct.
This justifies the generic checked scalar-parameter proposal; production/B1/B2
qualification and combined-candidate metrics remain root's separate report.

The source patch does not simplify leaf arithmetic by hand. Supplying the
correct 32-bit formal type lets Clang prove scalar keep/seal and packed-payload
fallback paths unnecessary. That is the transferable result for lexer/Map
scalar slots. The type-only saved-C witness leaves function bodies and runtime
helpers unchanged, so it provides unusually direct attribution to information
lost at the native worker boundary.
