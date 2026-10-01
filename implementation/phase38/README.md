# Phase38 report: compiler research and mined optimization ideas

The requested research collection is complete: **19 design documents**, including
**12 compiler/research studies**, a baseline, estimate methodology, source registry,
architectural synthesis, ranked idea catalog and prospective experiment queue.
Start with the [collection index](../../design/phase38/README.md) or
[ranked ideas](../../design/phase38/ideas.md). The root README links the collection.

This phase changes documentation only. Installed Phase37 checked03, runtime,
benchmark catalog and upstream pin remain unchanged. No new execution speed,
compiler speed, source reduction or conformance improvement is claimed.

## Research performed

The studies cover the pinned Bend TS backend; MLton; GHC; OCaml/Flambda2;
Lean; Koka/Perceus; Chez Scheme; V8/JavaScriptCore; Zig; Rust/Cranelift;
stream fusion/vector/Strymonas; and compiler validation/engineering including
Souper, Alive2 and CompCert. Three parallel agents researched disjoint files;
root inspected local TS/selfhost/generated source and two additional compilers,
then synthesized and reviewed the findings.

Primary sources include versioned implementation files, compiler authors'
papers and official documentation. The
[source registry](../../design/phase38/sources.md) distinguishes commit pins,
historical release tags, dated development sources, and access limitations.
The [external URL index](source-links.json) initially collects **81 distinct
cited URLs**; these are not 81 independent papers or a claim of universal
network availability. Full external source copies are not committed.

Pinned `comp.ts`, `bend.ts`, current backend/runtime files and four final
numeric/tree output modules were hashed in
[local-source-identities.json](local-source-identities.json). Selected Koka/Chez
downloads have [commit and content identities](external-source-identities.json).
The source and performance baselines come from commit
`9391ebe91ceeb73f69e4d02f1cdb67aa32a0c6a7`; TypeScript reference remains
`018751270e800bc222a93dad7f257083ee53a5f7`.

## Main finding

The most useful recurring compiler technique is to preserve known callee,
arity, shape, demand and control-flow facts so private computation becomes
direct code. Our profiles still show generic application/forcing inside useful
recursive work. The TS backend's direct calls and tail-component loops provide
the closest concrete comparison. MLton, GHC, Flambda and Chez supply different
ways to reason about the same missing knowledge.

The architectural candidate is a bounded direct recursive worker component
behind the existing public interface, initially retaining tagged data. A shared
fact analysis could later replace duplicated admission logic. This approach
earns a refactor only if two independent component experiments succeed.

The cheapest next discriminator is extending an existing private Number-counter
proof to the scalar recurrence. A separate ray scope experiment can investigate
guard amortization. Known callback specialization should be measured before
fusion, and allocation elimination before ownership/reuse machinery.

## Best proposals and limits

| Proposal | Conditional planning range | Principal risk |
| --- | --- | --- |
| Private Number countdown | 1.1–1.5× numeric | Nat bound, escape and failure timing |
| Larger useful closed scope | 1.15–1.5× active ray | Host mutation, callback/error reentry |
| Direct recursive tagged workers | 1.5–2.5× tree | Demand, sharing, recursion/stack and ABI |
| Known callback specialization | 1.5–3× selected list/closure cases | Captures, staging, specialization growth |
| Fusion after direct calls | 1.2–2× versus a future direct-unfused worker | Demand/error order and aliasing; low confidence |
| Shared analysis facts | Initial 0–6% checked-request reduction target | Stale/context-dependent facts; cause not yet isolated |

Except fusion's explicitly named prospective comparator, ranges are incremental
against installed Phase37 on named workloads. They are not achieved gains,
confidence intervals, population averages or additive multipliers. Transfer of
tree workers to map/BST/lexer remains unquantified. A large current TS gap shows
headroom, not a forecast of obtaining it. There is no supported parity date.

Simplicity's exploratory target is deletion of 5–15% of the 4,345-line JS backend
if a duplication inventory supports it: about 217–652 lines, only 1.2–3.6% of
the 18,358-line compiler. This is not an achieved reduction or a basis for a
50% overall reduction promise. No failing conformance test is claimed fixed.

## Findings that prevent expensive wrong turns

- VM invalidation/watchpoints cannot be copied as an ordinary JS guard cache.
- Numeric already has one outer loop guard; its remaining guard cost does not
  demonstrate a nested-scope opportunity.
- Closure conversion alone may retain closures and allocation. Direct unfused
  execution is the right control for later fusion.
- Pure functions can still fail in an order that fusion changes. Ownership,
  shape, demand and effects need separate facts.
- Runtime reference counts from Lean/Koka are unavailable in our JS heap;
  pooling/reuse can increase retained memory.
- A smaller optimizer can be preferable to a large rewrite engine when the
  dominant cost is runtime protocol, not algebraic instruction selection.
- Whole-program architecture, source size, compiler latency and generated
  execution are different axes. Zig's history does not supply our speedup.

The [independent review](review.md) records concrete corrections and remaining
limits. The [experiment queue](../../design/phase38/experiments.md) preserves
the 20/60-second inner loop and separate 300/600-second confirmation, complete
value/alias/error controls, serial memory limits, and fresh holdouts.

## Validation and publication boundary

Documentation verification checks Markdown local-link targets, balanced fenced
blocks, JSON readability, selected source hashes, coverage of all 12 study links,
and absence of production source changes. The
[verification receipt](verification.json) records the final reviewed corpus
inventory. The [protected-work receipt](protected-files.json) verifies all 103
unrelated starting files unchanged and unstaged using the existing Phase37 helper.

No builds, generated programs, benchmark timings, profiles or external compilers
ran for this research. Re-running conformance for documentation would add cost
without testing a changed compiler. Phase35/36/37 evidence trees stay closed.
No PR comment or other external message was posted. Publication is a commit
and push of this documentation collection on `selfhost/bootstrap`.
