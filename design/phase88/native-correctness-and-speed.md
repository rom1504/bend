# Phase88: a correct and faster native compiler

Continue from the measured Phase87 native B1. First repair the real correctness
boundary, then integrate its general linear text builders, expand native checks,
and attribute the remaining lifetime/startup cost before changing it. User
program execution speed, compiler execution speed, conformance and simplicity
remain separate metrics. Upstream stays pinned at0592662.

## Sequential admission gates

1. Freeze the original observer/text/emitter modules. Replace reusable observer
   closures by eight Data continuation frames, preserving full analysis products,
   fresh/fuel/error order and recursive-tail checks. Compare old JS, new JS and
   native focused products before paying for a whole native image build.
2. Apply the Phase87 linear builders in the working source. Build one checked
   native B1 and a separately identified JS sibling. Require Map and the five
   existing positive sources to emit C identical to installed B2. Retain failures
   and diagnose the next boundary rather than omitting unsupported families.
3. Expand to representative source shapes, negative inputs, repeats and applicable
   native/backend conformance. Compare JS behavior too. Make the native entry/tool
   usable and documented within its validated import/effect contract; qualify a
   native B2 only if self-compilation and exact products actually pass.
4. Profile Base and requests separately, recovering physical ownership callers
   where existing unwind metadata permits it. Source rewrites require an actual
   caller/mechanism and exact-product checks. Investigate persistent prepared Base
   or a reusable native process to reduce startup; make all cache identity and
   validation costs explicit. Do not count simply moving work outside a timer.
5. Integrate only validated candidates, run justified broad release gates, and
   write a report with complete scope, metrics, failures, artifact lineage and
   remaining limits. Commit/push progress to the existing fork branch.

## Efficient execution

Three bounded agents handle the observer implementation/controls, ownership
attribution tooling, and prepared-Base feasibility. Root executes all targets
serially. Reuse retained native images, small entries and the Phase68 sampler;
one native image acquisition/build costs about259s and is an integration gate,
not the default edit loop. Do not rebuild or broadly rerun without new evidence.
Use original C byte identity to preserve generated-program performance wherever
possible; otherwise run applicable execution oracles.

Keep the Phase86 and87 archive capsules immutable. Disk began at363MiB free;
reclaim only verified redundant generated C caches whose bytes are preserved in
those capsules, recording every removal. Runtime guard2GiB RSS/4GiB available;
large Clang builds alone may use6GiB with16GiB headroom and360s deadline. Avoid
small virtual-address limits because the runtime reserves large lazy mappings.
No upstream human-written compiler edits, disabled ownership checks, public PR
comments, assumed native fixed point, or successful-family-only parity claims.
