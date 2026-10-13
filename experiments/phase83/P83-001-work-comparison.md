# P83-001: where does current compilation work differ?

Status: investigation complete; no production candidate.

Hypothesis: matching pipeline regions across more source classes will identify
work a broad IR proposal might miss. Three research lanes cover pipeline,
representations and B1/B2 lowering, incorporating primary compiler literature.

Method: eight existing source/oracle pairs, three roles, two rotating clean
rounds;16 CPU and3 sampled-allocation profiles. Exact Phase82 and upstream hashes
are in the frozen plan. All67 compilation outputs remain exact.

Result: B2 ranges0.828×–1.504× upstream in this exploratory sample; larger
programs range1.283×–1.504×. B1 still has widespread closure/trampoline code.
Numeric B2 allocates100.80 MB versus upstream145.45 MB, so total allocated volume
alone is not an adequate explanation for the remaining B2 gap.

Decision: separate B1 control-flow and B2 work-elimination hypotheses. Preserve
the qualified Phase82 headline; this unchanged-source screen is not a gain.

[Design](../../design/phase83/compilation-work-investigation.md) ·
[Report](../../implementation/phase83/README.md) ·
[Measurements](../../implementation/phase83/measurements.json) ·
[Profiles](../../implementation/phase83/profiles.json).
