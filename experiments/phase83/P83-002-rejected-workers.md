# P83-002: expensive rejected worker construction

Status: supported, workload dependent; no optimization implemented.

Hypothesis: generating complete candidate C before dependency admission wastes
substantial time on some programs. Observation-only B2 wrappers record actual
candidate construction, errors, string sizes and plan readiness.

All four requests reproduce exact C. Map spends379.40 ms constructing finally
unready workers, versus38.03 ms for ready names. Four non-tail recursive helpers
account304.11 ms over12 ordinary/product/retry attempts. Numeric unready work is
36.05 ms; small and Functions65 have none. Admission itself takes1.97 ms on Map.
Later observer integration cannot re-admit these existing worker names; source
inspection establishes final C disposal, while their metadata remains relevant.

Decision: prototype a general definite-refusal preflight and refusal propagation
before broad IR migration. Do not special-case names or count the diagnostic
ceiling as a realizable gain. Tail context/product fallback and exact C are gates.

[Method](../../selfhost/tools/performance/phase83/prepare-regions.py) ·
[Attribution](../../implementation/phase83/candidate-fate.json) ·
[Research/fate audit](../../research/compilers_architecture_and_techniques/phase83/representation-replacement.md).
