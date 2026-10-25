# P138-001 — Early semantic reuse versus another local optimization

Status: investigation complete. [Design](../../design/phase138/README.md) ·
[Report](../../implementation/phase138/README.md).

Hypothesis: sub20s development rebuilds require avoiding unchanged semantic
preparation and lowering, not another late optimizer/object cache. Current hot
queries may offer cold gains but cannot supply the required94.2% time reduction
alone. A reusable source-connected correctness contract could make early reuse
safer, but proof-production and check costs must be charged.

Test: fresh exact-object Phase137 N3 profile on the unchanged historical source;
read-only dependency and source audit; primary-source formal-verification research.
No cache, pass, compiler or verifier changes in this experiment.

Falsification: a newly dominant independently removable computation, or a working
existing early-reuse boundary with acceptable total cost, would change priorities.
Every proposed reuse must account for dependent bodies, order/absence, checker
state, specialization, runtime/producer identity and current global binding.

Result:10,785 zero-loss samples,99.66% main-thread CPU coverage; complete105.9MB
output matches the retained clean digest. Drop/fade25.67%, borrowed equality9.33%;
three original queries13.78% with overlapping5.39% drop/fade. No single remaining
hotspot establishes the17.3× target. A concrete checker checkpoint is plausible;
existing Base-prefix interfaces do not implement it. Reuse must continue through
erasure, lowering, final binding/verification and rendering to meet20s.

The recent Anthropic proof result is verified at the publication/artifact level;
a matching OpenAI software-proof announcement that week was not found. Recommend
one source-connected replay law, not a whole-compiler proof campaign. No compiler
or installed selection changes, new theorem, or performance improvement claimed.
