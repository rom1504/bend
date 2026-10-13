# Phase78: direct control flow and shared native work

Baseline Phase77 release c6e194c: checked B1 f058269d, installed genuine B2
35d7a606. Fresh native requests measure1.92036× B1/1.48173× B2 upstream.
The current user explicitly prioritizes B1 at or below1× and permits measured
temporary generated-program regressions. Correctness and honest metric boundaries
remain required. No agents, no PR comments, no pinned-upstream edits.

## Sequential experiments

1. Replace selected thunk-based choices in Bend source with direct pattern
   matching. First target recursive native rendering/analysis loops where B1
   currently allocates closures and dispatches through run_loop. Keep upstream,
   generated-image derivation, runtime and benchmark unchanged. Check generated
   shape and bounded stack behavior, then exact emitted C and fresh paired B1
   requests. A successful pilot can justify a mechanical, reviewed source rewrite
   over native-only helpers; no blind global eager branch evaluation.
2. Extend the existing native request with facts reused across analyses. Count
   occurrence/layout/type work before adding storage. Demand equivalent context,
   binder/annotation provenance and raw error/demand behavior. Prefer a retained
   result to rebuilding trees or hashing full structural keys. Stop generic
   memoization if bookkeeping consumes its savings.
3. Simplify rendering work: retain structural fragments and eliminate redundant
   scans or transformations under explicit runtime/source identity. Custom runtime
   and raw emission retain correct fallback semantics. Report preparation separately.
4. Escalate to compact indexed nodes only if allocation/traversal measurements
   justify it; this is a larger redesign with overlapping savings, not an assumed
   additional gain. Keep functions65 and non-IO inputs in the loop.
5. Qualify one selected combined source: B1 checked frontend and native/raw,
   genuine B2/B3 and own-source acceptance, exact C or newly measured runtime,
   installed/relocated release. Report compilation B1/B2, execution, conformance,
   source complexity, failures and deferred proposals. Commit and push milestones.

## Fast loops and acceptance

One CPU3 target process tree;2GiB aggregate RSS/4GiB available-memory floor,
Node1GiB heap/4MiB stack. Preserve all attempts in fresh paths. The checked B1
build is about33s and the first screen should use exact prior C as its oracle.
Use two-round screens to reject weak candidates; final three-rotation paired
measurements on five sources include held-outs. No profiling clocks in speed
claims; no warm-cache or B2 substitution for the requested cold B1 metric.

A roughly48% B1 request-time reduction is required. The prior numeric diagnostic
shows745ms native emission,225ms annotation/layout and248ms sampled dispatcher
self time within a1426ms profiled request. These clocks overlap and cannot be
added. Branch overhead removal is a hypothesis; stack safety and semantic demand
must be checked. Aim at large general improvements while keeping each falsifying
experiment bounded before expanding implementation and validation cost.
