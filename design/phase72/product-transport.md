# Phase72: connect existing native product transport

Start from installed Phase70 compiler03 and upstream0592662. Phase71's saved-C
Array.map experiment removed22.86% execution time by carrying two fields through
a loop instead of allocating and immediately unpacking a Tuple. The compiler
already has typed product signatures, virtual bundles, ownership-aware lowering
and private scalar workers. Extend those mechanisms rather than add a new IR.

## Decision sequence

1. Freeze and measure a saved-C BST call-boundary intervention, using the existing
   independent oracle and alternating original/prototype/upstream binaries. A
   20–30minute falsifier, not permission to rewrite benchmark algorithms. Record
   a null result; do not generalize the Array.map percentage across programs.
2. Inspect why the existing product path reboxes those values. Implement the
   smallest general connection justified by the experiments. Prefer reusing
   known constructor layouts and existing private worker admission. Scalar loop
   state is the same transport problem, not an independently additive gain.
3. Use checked B1 and focused ownership/demand controls before broad validation.
   Cover early exit, dropped fields, shared aliases, opaque calls, nonmatching
   products and error/evaluation order. Raw and device fallback stay available.
   No source-name heuristics or host implementation of compiler algorithms.
4. Measure affected and unaffected native families on frozen outputs; retain
   upstream and old installed comparisons. Check B1/B2 C-request overhead early.
   Only then spend on self-reproduction and release qualification. Preserve all
   failed candidates and old releases. Install only a qualified candidate.

## Scope and efficiency

One agent, no delegation or PR comments. One guarded heavy process tree at a
time: CPU3,2GiB RSS,4GiB available memory, Node1GiB heap/4MiB stack. Use fresh
Phase72 paths; Phase71 and earlier evidence stay immutable. Capture local usage
metadata at checkpoints, export only aggregates; tokens are not exact quota.
Assess benefit and implementation size after the first working candidate.
Constructor storage reuse and producer/consumer fusion are subsequent options,
not reasons to expand an unsuccessful product experiment indefinitely.

Report execution speed, B1/B2 compilation cost, conformance and source-size
change separately. Estimates from the planning discussion are hypotheses, not
achieved results. Commit and push the design and final evidence within the
user's existing authorization.
