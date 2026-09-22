# Checker suffix-index experiment

The indexed suffix hypothesis is real but remains an experiment. A checked Bend
overlay preserves each original declaration and its separately computed check
mode. One reverse pass records the nearest later same-name event in the existing
persistent index. The ordinary event guard, declaration context, definition
check, first error and final open-law check are preserved. The overlay retains
legacy handling for any `BookCache` marker and for fewer than 256 eligible laws.
The production kernel is unchanged.

A disposable host-Map attribution probe first established the opportunity without
skipping any checker rules. Its [results](signature-suffix-upper-bound.json) are
an upper-bound experiment, not a compiler implementation. The subsequent Bend
overlay was fully type/ownership/closed-book checked by pinned upstream.
[Its checked build](evidence/signature-index-verified-build.json),
[synthetic checks](evidence/signature-index-threshold.json), and
[full-source check](evidence/signature-index-fullsource.json) retain exact hashes. A separate rebuild verified the clean upstream pin and
before/after identities of `bend.ts`, `comp.ts`, and `base.bend`, and reproduced
the exact candidate API bytes. The [earlier build record](evidence/signature-index-build.json)
is preserved with its original, narrower provenance.

At 1,024 laws plus fills, three alternating samples gave median complete checker
times of 2,710 ms before and 1,726 ms after, about 1.57x. Every original event and
computed mode matched legacy `signature_mode`. Duplicate declarations, missing
fills, unsafe fills, mismatched signatures, 48 deterministically randomized
300-law event streams, empty names and three cached-book fallback cases produced
exactly the same checker text. An independent source review found no blocking
semantic discrepancy.

The realistic result is smaller: one paired check of the exact frozen compiler
book took **182.9 s before and 168.2 s after**, both with empty error. Graph load
was measured separately at 40.2 s. This single paired observation on CPU3 is not
an uncertainty estimate or a full compilation/self-emission benchmark.

The [first unconditional version](evidence/signature-index-unconditional.json)
regressed the 128-law microcase slightly. Thresholding avoids most small-book
planning, but large early failures still pay for constructing the whole schedule
before the first error. Given that tradeoff, an approximately 8% single real-book
reduction does not justify expanding the production kernel in this milestone.
A useful next experiment is incremental planning after a small successful prefix,
followed by repeated accepted/early-rejected whole-compilation controls.

Reproduce the checked overlay from the frozen phase3 baseline (paths from
`selfhost`):

```sh
mkdir -p build/phase3/new-signature-overlay/src/check
cp build/phase3/baseline/src/check/kernel.bend \
  build/phase3/new-signature-overlay/src/check/kernel.bend
patch -p1 -d build/phase3/new-signature-overlay \
  < tools/performance/phase3/signature-index.patch
node --stack-size=4096 --max-old-space-size=4096 \
  tools/performance/phase3/analysis-build.mjs \
  build/phase3/new-signature-overlay build/phase3/new-signature-build
node --stack-size=4096 tools/performance/phase3/signature-index.test.mjs \
  build/phase3/baseline/api/b1.mjs build/phase3/new-signature-build/api.mjs \
  build/phase3/new-signature-check
```

`analysis-build.mjs --in-process` is an explicit alternative for supervisors that
cannot execute its synchronous child. It performs the same upstream checking,
ownership and no-open-laws gates. Run it with an external deadline and explicit
Node resource limits. The full-source runner takes old/new APIs, a frozen source,
the pinned Base path and a fresh output directory; it hashes all consumed inputs.
