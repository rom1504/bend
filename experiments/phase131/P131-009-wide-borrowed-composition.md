# P131-009 — combine proved scalar fusion and wider borrowed layouts

Status: successful extracted-computation experiment; unqualified compiler source.

Four audited field bounds expand8→16 while retaining runtime ABI,91 protected
verifier declarations, buffer checks and owning fallbacks. Seventeen finite
admission checks and independent ordinary outputs pass. Direct KDef/unrelated
record scalar queries take32.48%/41.03% less time in five paired rounds.

Separately, exact scalar bucket fusion is proved for every finite List<KDef> and
key, including empty-key index-node results. Source fusion alone takes6.26% less
time on a one-entry lookup, while64-entry collision stress is approximately
neutral. Most ownership work merely moves to another function.

Compiling that SAME fused source with wider layouts changes the scalar bucket
to a reachable borrowed reader. Three paired rounds per case pass all twelve
outputs: one-entry107.09→52.84ms (50.65% less), collision465.81→177.25ms
(61.95% less). Internal timers are at least50ms; separate stress/ordinary cases
and raw samples remain visible. QBE grows4.40%. Ratios from separate observation
blocks are not multiplied into a claimed whole-composition speedup.

No new source algorithm is introduced in the final comparison. Destructive takes
and sinks inside the reader disappear; the owning adapter/fallback remains.
This demonstrates composability of semantic facts, not whole-compiler parity,
full-tree correctness, native ownership proof or native self-hosting qualification.

[Wider-record results](../../research/phase131/wide-records.md) ·
[Scalar ceiling and proof](../../research/phase131/selector-ceiling.md) ·
[Raw evidence](../../implementation/phase131/diagnostics/README.md).
