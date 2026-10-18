# P107-001 — checked source, shared optimization, Clang-free consumers

2026-10-18; started 06:37 UTC. Status: completed bounded implementation and
qualification; broader backend migration remains open.

Hypothesis: a small checked-KTerm-to-native-IR lowering pass in Bend plus bounded
pure inlining can retain fast backend construction while removing the large
helper-call runtime penalty observed in Phase106. QBE and Cranelift linked by
GNU tools can remove Clang from this experimental development path.

Before measurements: preserve Phase106 outputs and installed compiler images.
Use fresh source fixtures, capture the checked graph through the installed
Bend compiler API, and run lowering written in Bend. Replay and fresh frontend
cost are different metrics. Unsupported reachable features must refuse; no
silent legacy fallback. Keep scalar representation, erased arguments, native
primitive provenance, unsigned wrap/large shifts, evaluation order and tail
recurrence explicit. Compare exact results against independently defined
answers and the existing compiler where practical.

Interventions: batched process supervision; bounded pure inlining; QBE emission;
GNU link path; only then evidence-backed cache/search extensions. Root owns the
serial CPU3 execution queue. Two agents prepare disjoint inliner/backend source.

Expected information: can ordinary programs use the IR, what language surface
is admitted/refused, how much inlining closes runtime gaps, and whether complete
iterations improve after frontend, emission, object generation, link and run
are counted. The campaign does not assume full-compiler backend compatibility.

Evidence will be retained under selfhost/build/phase107 with a durable capsule
and interpretation under implementation/phase107. No release promotion or new
upstream comparison without the corresponding gates. Resource failures and
rejected configurations remain visible.

## Closed result

The [phase report](../../implementation/phase107/README.md) records the native
source04 image and separate C/Cranelift/QBE consumers. Ordinary scalar requests
now execute native Bend checking/lowering and QBE/binutils, without Bun or Clang;
acquiring that frontend image still uses the installed compiler and Clang.
[Native controls03](../../selfhost/build/phase107/native-controls03/report.json)
closes 32 transport comparisons, 180 independent outputs, 14 refusal observations
and six live-Base controls. Earlier failing controls remain recorded.

[Legacy latency02](../../selfhost/build/phase107/legacy-latency02/report.json)
measures three source-to-executable workflows at 34.6–37.5% less time than the
installed C/Clang path. Initial tool/image acquisition is excluded and reported
separately. [Measure07](../../selfhost/build/phase107/measure07/report.json)
shows substantial focused runtime gains from shared IR optimization, with
remaining backend gaps. Its reference is raw experimental IR compiled by Clang,
not upstream Bend. No full-language, production B1/B2 or recursive-acceleration
claim follows. Later held-out source checks are reported separately in the phase
report; they are not retroactively included in these initial source controls.
