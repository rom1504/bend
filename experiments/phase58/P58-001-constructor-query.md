# P58-001: avoid constructor-query misses and reuse checked owner

Hypothesis: preserving global constructor search through a continuation avoids
intermediate missing records; checked arm types provide a datatype owner that
avoids many whole-book scans. This targets shared compiler queries, not source
program names or serialized output pattern selectors.

Scope: isolated `back/common/queries.bend` patches only. No shared live source,
manifest, runtime or driver edits. Source and controller review passed. Root’s controls02 passes; controls01’s
strictExact-flag refusal is preserved. Throughput measurement and promotion
remain pending; no compiler speedup claimed.

[Implementation, commands, controls and boundaries](../../implementation/phase58/lookup.md)

A falsifier is any changed constructor/arm-type result, altered duplicate/fill or
cached-list first-event semantics, inconsistent fallback diagnostic, source
oracle mismatch, or no decrease in the intended intermediate missing counts.
Unchecked duplicate-owner books are outside the existing checked owner proof;
global search controls retain their original first-match behavior separately.
Root owns all builds, target execution and any production integration.

Focused result: controls02 passed in 23.8 s. Each role has 135 actual annotated
queries plus four fallback probes, with equal complete result digests. Instrumented
missing calls are 4,248→3 and kt calls 8,968→478. Synthetic successful long
searches reduce missing512→0; a final whole-book miss preserves one record
(513→1), and cached child misses remain1→1. Renamed ordinary source120 and
duplicate parse rejection agree; emitted fixture bytes are exact. Counts are
query-local calls, not a full allocation or performance result. Both checked
pilots record strictExact:false honestly and independently pass their selected
36 exact/semantic rows. Broader qualification and root latency evidence are
separate gates; see the linked implementation report.

Negative/null performance observation: root’s lexer pilot passes identical
output but is essentially flat. Import+first request1,860.44→1,839.63 ms and
sole later request1,174.79→1,181.70 ms are one-process observations; they do not
establish a throughput gain. Keep this result alongside the query counters.
Large own-source reach/final-emission performance remains unmeasured for this
slice at this evidence cutoff.
