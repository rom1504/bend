# P45-017: defer a nullary-root retry on the improved worker

Status: investigated read-only and deferred. No patch, compiler build, runtime change or target execution was performed. The selected phase will consolidate the qualified positive-arity improvements first.

## Why revisit the rejected experiment?

[P45-008](P45-008-nullary-workers.md) tested nullary private workers before Number-Nat representation, direct native constructors and tail-only component simplification. Its negative runtime result therefore does not measure the current worker architecture. A closed user computation could benefit from those later changes while retaining its existing delayed `fn(0)` demand semantics.

The prior worker07 screen nonetheless remains valid evidence for that exact candidate: baseline/candidate ratios were 0.7621 for RLE, 0.9150 for Map/Set, 0.9826 for morning and 0.9574 for evening. It was rejected and reverted. A retry would be a new hypothesis, not a reinterpretation of those regressions.

## Static coverage is narrower than four complete programs

Inspection of the retained worker07 modules shows that RLE's `main.out` activated a contextual worker, while Map/Set activated only `chk_get` and `chk_union`. Map/Set's complete `main.out`, morning and evening remained generic. All four benchmark entries are nullary, but arity is not their only admission barrier: unsupported function-valued arguments, Array operations and parts of the Map/Set graph still prevent complete proofs. Representation and emission improvements do not automatically remove those type/effect proof gaps.

A new candidate would retain the Phase45 typed root ranking and native-source public-root exclusion. Private zero-argument source references would need the previous complete-graph collection and explicit `JWDirectCall` lowering at each original demand point, never memoization, import-time evaluation or a reusable global result. Public results would remain scalar or exact immutable String. Literal globals, object/function/IO public results and unsupported graphs would retain existing behavior.

## Newly identified ABI qualification gap

The current generic nullary descriptor exposes an anonymous `function(){...}` as `.code`, whose `length` is zero. The current `exactCode` helper always returns an anonymous `function(a){...}` for this path, whose `length` is one. Reusing the old nullary admission patch unchanged would therefore alter observable function metadata.

The old nullary controller checks repeated demands, helper and root mutations, getter order, raw `.code` invocation, overapplication, errors and reentry. It does not compare `.code.length`. Its passing observations cannot qualify this additional boundary. This is a static ABI difference in a previously rejected candidate, not a newly observed runtime test failure.

A possible future implementation would extend the internal exact-entry helper with an explicitly nullary wrapper, using a zero-formal-parameter function while forwarding the original argument-vector value to the existing permission mechanism. The implementation must preserve `.code` name, length, own property descriptors, prototype/constructor relationships, receiver behavior, raw-call fallback, and public demand order; it must also leave existing positive-arity wrappers unchanged. This requires a runtime change and new metadata controls, not merely relaxing an arity predicate.

## Decision and future estimate

Defer the retry in this phase. The expected coverage is limited, the post-representation gain is unmeasured, and the runtime/ABI extension would expand the current qualification work. There is no justified speed estimate from the old screen: a result from no improvement to a useful several-fold reduction at the few admitted points remains plausible, with no corresponding claim for the four-program set or the full corpus.

A future isolated investigation is roughly 1–2 engineering hours for the minimal lowering/entry changes, independent metadata and demand controls, activation checks, and a fresh four-point decision screen; normal full qualification would follow only if that screen warrants promotion. This is a planning estimate. The first stopping condition is exact predecessor/candidate metadata and demand equivalence; the second is a measured gain that survives unchanged unsupported points and guard overhead.

Existing fixtures and controls can be extended, preserving their prior bytes and receipts: `selfhost/tools/performance/phase45/fixtures/nullary-demand.bend`, `nullary-demand-catalog.json`, and `nullary-demand-controls.mjs`. Keep prior worker07 measurements separate, and compare a future candidate against the exact final selected compiler with fresh samples.
