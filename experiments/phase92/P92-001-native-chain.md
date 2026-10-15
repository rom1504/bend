# P92-001: source-matched native compiler qualification

Status: qualification accepted; no production change or optimization promotion.
[Design](../../design/phase92/native-chain-scoreboard.md) ·
[Report](../../implementation/phase92/README.md) ·
[Metrics](../../implementation/phase92/summary.json).

Question: does the existing own-C native07 differ materially from a native image
built by upstream C when Bend source, Clang flags and request inputs are fixed?
The older upstream-built native image used different source and could not answer.

Result: exact D04 source, same O2 toolchain; new native B1 emits the complete C
used by existing native07, which reproduces it again. B2/B1 is1.203× request /
1.444× process on six sources and1.085× request on full self. Forty-five broader
products agree completely and execute correctly;69 original conformance cases
and3 rejection controls pass per role. Keep31 entry-contract exclusions and the
unavailable frontend/JS interfaces explicit.

The full-source native B1/B2 deficit versus TS/Bun remains2.898×/3.145×. Small
prepared-Base workflow wins do not generalize: live Small process time is3.257×/
3.684× TS. Both native builds share a large-input cost that matching upstream
C lowering alone cannot remove. Own-C Base decoding is independently slower:
pooled139ms versus59ms. Profile these boundaries before changing algorithms.
No particular allocator/string/dispatch cause is proved by this qualification.

Evidence: two sealed capsules, exact build/self lineage, balanced small screen,
original golden judge, full-byte broad C comparisons, retained disk-stop report
and verified continuation.227 root-guarded jobs, no overlap/OOM/timeout; one
pre-launch disk reserve stop. Three offline agents, no target delegation, no
quota estimate or PR comments. Source remains132 modules/32,692 physical lines.
