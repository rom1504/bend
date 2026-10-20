# P113-003: bounded inlining in scalar and product IR

Receipt snapshot: 2026-10-20, 18:56 UTC. `inline13` has checked source, native
fixtures and an initial runtime diagnostic. Product composition and matched
performance qualification remain separate hypotheses under the
[Phase113 design](../../design/phase113/qbe-program-parity.md).

## Hypothesis and source evidence

Once complete direct functions remove continuation boundaries, exposing small
callee bodies to QBE should remove ordinary calls and reveal constants across
them. Applying the same bounded transformation after product planning may
compose with carrier elimination. The existing
[structural witness](../../selfhost/tools/performance/phase113/direct/structural-witness08.md)
found seven ordinary calls remaining in the admitted scalar loop after its
runtime frames and jumps disappeared.

The [Bend inliner](../../selfhost/tools/performance/phase113/direct-opt/README.md)
uses callee-before-caller order and the existing structural renamers. Fresh
formals snapshot arguments before callee operations; terminal results assign
the original destination. Ownership operations, branches and runtime calls keep
their order. Input and transformed programs pass the existing verifier, with
the original retained on refusal.

Current bounds are eight parameters and 48 nodes per single-result public leaf;
1,024 initial caller nodes, four sites and 128 additional nodes. Nested scalar
branches count. Each site gets separate 2 KiB scratch; explicit allocation limits
are 8 KiB per callee and 16 KiB per transformed caller, plus ordinary emitter
scratch. Recursion, product imports, multiple results, reserved-name collisions
and early returns before a common suffix are refused.

`inline13` selects the **scalar** adapter. A product entry adapter exists, but
the current eligibility rule still excludes private/multi-result product
callees. No product-vector inlining result is established by the scalar run.

## Observed gates and limits

- [inline13 API](../../selfhost/build/phase111/p113-inline-api13/report.json)
  is complete and checked. Its
  [native batch](../../selfhost/build/phase113/inline-all13/report.json) completed
  48 jobs, including all 12 native fixture observations.
- The [six-program screen](../../selfhost/build/phase112/p113-inline-screen13/phase113-report.json)
  is complete, one-round `diagnostic1`, with `pairedTimingQualified:false`.
  Scalar-region changed from enhanced09's 138 ms to 93 ms, still 5.81 times
  upstream's 16 ms. Ray was 360 to 355 ms, lexer 129 to 129 ms, and closures
  203 to 201 ms. These observations do not resolve small improvements.
- The separate
  [products11 screen](../../selfhost/build/phase112/p113-products-screen11/phase113-report.json)
  measured local-pair at 2,193 to 373 ms and editdist at 2,156 to 372 ms versus
  frozen facts: about 5.88 and 5.80 times faster, but still 23.31 and 24.80 times
  upstream. These are also single-round diagnostics. They motivate composition;
  they do not measure an inliner/product combination.
- The [19-case independent reflection suite](../../selfhost/tools/performance/phase113/controls/inliner/manifest01.json)
  is frozen, but no execution receipt was found in the bounded audit. Do not
  infer its passage from the native fixture batch.

## Independent gates and falsification

Run the independent before/after trace oracle for branch outcomes, argument and
destination aliases, ordered ownership/observer calls and exact refusal
boundaries. Challenge namespace collisions, early-return suffixes, recursion,
node/site/stack limits and verifier rejection. Native witnesses must demonstrate
both expected behavior and disappearance of the actual reachable call sites.
For product composition, preserve field permutations, owned aliases, shared
arrays, result-slot separation and both release orders.

Reject on changed traces, early/late failures, ownership corruption, collisions,
unbounded expansion or stack growth. If hot calls remain, reject the claimed
mechanism before a broad acquisition. If calls disappear but matched runtime
does not improve, or compilation/code/stack costs outweigh it, retain the result
as a rejected performance experiment. Do not raise bounds solely for a named
benchmark. Qualify a combined facts/product/inliner source independently.

All transformations remain Bend; host tools only transport and compare evidence.
Sequential CPU scope, generic fallback, full45 and generation gates remain as
specified in the design. No parity or promotion is claimed. This documentation
audit ran no targets.
