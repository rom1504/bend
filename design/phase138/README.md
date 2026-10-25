# Phase138 — A credible route to sub-20-second compiler development

Investigation, 2026-10-25, starting at `9a89b4d`. No production optimization,
selection change or complete compiler-proof campaign is authorized by this design.

Questions: what would remove enough work to rebuild the compiler below20s; what
the current qualified native profile says; whether recent AI-assisted software
proofs make reusable checked compilation units practical.

Keep three clocks separate: cold complete source-to-executable; an actual local
source edit through a newly runnable compiler; and full independent qualification.
The latter must not silently disappear from research-cost accounting. A warm
edit result cannot be presented as the cold target.

Bounded execution:

1. Relink the retained Phase137 N3 object with the existing authenticated
   diagnostic runtime. Sample one ordinary frozen compiler-A request at32ms,
   counters disabled, against its retained clean-output digest. Reuse current
   profiler/attribution machinery. No compiler-source acquisition.
2. Attribute physical leaves, active contexts and their intersections. Compare
   profile composition with Phase136 without claiming a controlled speed ratio;
   diagnostic relinking, sampling and elapsed time are not clean performance.
3. Audit the earliest safe semantic-reuse boundary and actual blockers in the
   selected source. Establish which existing prefix/cache interfaces really skip
   work, which merely validate identity, and where global binding remains.
4. Read the original recent OpenAI/Anthropic announcements and public proof
   artifacts. Separate checked properties, assumptions, proof-production cost,
   verification cost and applicability to our x86/QBE/Bend pipeline.
5. Record a falsifiable implementation sequence, the cold/warm budgets and the
   smallest useful source-connected theorem. Preserve negative findings.

One root-owned CPU3 execution lane;4GiB process-tree limit,16GiB available-memory
floor,660s outer deadline. Two bounded read-only agents audit sources and
announcements. No broad45/native reproduction campaign: compiler code is unchanged.

Success is a more decisive next experiment supported by fresh evidence, not a
claimed17× gain or a cache with a high hit rate. Full current output must match
the retained digest. Archive small evidence and exact identities; don't commit
another100MB output file. No PR comment.
