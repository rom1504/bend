# P132-003 — Which boundaries make reuse and lower memory plausible?

Status: source research plus measured observations; no backend change.

Hypothesis: reusable semantic interfaces and earlier release of rendered output
matter more than filesystem throughput or adding another object cache.

Go primary-source research and isolated cache/edit experiment:
[Go build reuse](../../research/phase132/go-build-reuse.md). Distinguish stable
unit identity, action identity and output/interface content identity. The local
experiment usesGo1.22.2; current release/development source research is separately
pinned. A Bend interface must include inspected bodies and proof dependencies,
not only public types.

Memory/build audit: [cost](../../implementation/phase132/build-cost.md),
[source boundaries](../../research/phase132/memory-and-native-first.md).
An already-needed369s changed-source request supplies the timeline, avoiding a
second full request solely for diagnostics. RSS rises roughly1.9GB late while
output remains empty; observed writing occurs near the end. This is consistent
with retaining linked-character Strings, not an exclusive rendering timer or
live-heap proof.

Useful falsifiers: packed/streamed output must reduce request RSS and total work;
semantic-unit reuse must skip real lowering and survive deliberate invalidation
changes. A cache that simply moves repeated work to a host scanner fails the
research-throughput goal.
