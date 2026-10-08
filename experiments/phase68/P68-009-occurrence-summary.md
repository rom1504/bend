# P68-009 — Collect occurrence IDs once

- Status: registered before implementation/integration; no candidate result.
- Design: [native occurrence summaries](../../design/phase68/occurrence-summary.md).
- Evidence: `native-compilation-templates05-summary.json`, SHA
  `e8cd906d5cf48b62c14ffe07de2b45c72869261f082f3dde2470e5686fd5d481`.
- Target: remove repeated per-environment whole-term scans from native lowering,
  improving B1 and B2 compilation without changing generated C or ownership.

Hypothesis: one occurrence-ID index per queried term plus an ordered live/drop
partition replaces O(E×T) work with a term collection and cheap indexed queries.
Reuse the existing exact full-U32 compressed index; no new persistent cache or
host compiler algorithm. Preserve Var-as-leaf, every other term's `ks` traversal,
all 32 ID bits, environment order/duplicates and empty-environment non-demand.

The evidence is substantial but not a speed promise: B2 occurrence-list self
time is 528–672 ms and B1 Numeric occurrence inclusive time is 1,322 ms. B1
clean requests regressed 2,137/2,018/2,569→2,627/2,676/3,353 ms while B2 improved
1,921/1,845/2,300→1,570/1,582/2,086 ms across intervening native changes. These
single observations are diagnostics, not qualified broad ratios.

Cheapest falsifier: actual old/new helper equality on finite malformed terms,
full-U32 boundaries and ordered duplicate environments. Next require exact
complete C against the pre-change selected candidate; any change rejects the
analysis rewrite. Then measure actual B1/B2 fresh requests and separate profiles.
Keep failed attempts and the original methods immutable. Root alone runs targets;
source/data and independent review stay on CPU0.
