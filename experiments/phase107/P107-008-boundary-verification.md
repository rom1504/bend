# P107-008: verify a bounded optimization pipeline at its boundaries

Status: prepared, not checked or measured. The optional research pipeline does
not change a standalone pass, the production compiler, or an installed image.

The kernel-measure01 report identifies a much larger JS optimization cost than
native optimization for `many`. Root's component observation is approximately
3.996 seconds complete JS work, 3.484 seconds optimization, and another 0.469
seconds in the final `nx_verify`; complete native work is about 0.257 seconds.
These observations motivate removing repeated work, not a predicted speedup.
The final verifier is still necessary; reducing intermediate checks cannot remove
all of that final cost. The control manifest pins the original report and source.

The hypothesis is that repeated validation between validity-preserving passes is
a substantial avoidable cost. `nx_pipeline_fast(program)` checks its input once,
applies the existing bounded transformations in exactly this order, and checks
the final result once before returning it:

```
tail -> demand-inline(4096) -> reachable -> leaf-inline(4096)
     -> reachable -> memory-forward -> fold
```

Invalid input returns unchanged. An invalid final candidate also returns the
original input. Internal helpers are private by adapter convention: only export
`nx_pipeline_fast`. They assume valid input and are not replacements for the
checked public APIs. The program has exactly one externally visible entry;
unlisted library exports, reflection, or external function lookup are outside
this closed-program contract. `NxFunc` references remain ordinary reachability
edges, including stored and returned addresses.

The implementation reuses the transformation algorithms and all non-verifier
refusals. Tail transformation retains its function, body, normalization, fresh
name and total-growth limits. Demand inlining retains the original deep-eligibility
analysis, entry-first policy, original function order, original callee templates,
and one 4096-node budget shared with the remaining functions. Its two internal
prunes remain, as does the explicit subsequent pipeline prune. Reachability
retains the 256-function/65536-node admission limits, 256-step worklist and exact
missing-target/unfinished-work fallback. Leaf inlining retains its own independent
4096 budget and caps. Memory forwarding retains the 256-function/65536-node
admission and 4096-node per-function cap. Folding remains unchanged. A capacity
refusal applies to that pass, not to the entire pipeline; later folding can still
change an otherwise refused large program.

The one deliberate removal is intermediate `nx_verify` and its corresponding
intermediate invalid-output fallback. Exact composition therefore requires each
core to preserve validity on admitted valid IR. The final verifier provides a
fail-closed emission boundary, but does not prove semantic equivalence: an invalid
intermediate that later becomes valid would otherwise escape that check. Source
review and stage-by-stage comparisons must establish this preservation contract;
any witness against it rejects this candidate. Do not silently broaden eligibility
or repair an intermediate only in the fast path.

The frozen [control plan](../../selfhost/tools/performance/phase107/inline/pipeline-controls.json)
requires full IR/JSON/C products, final validity, unchanged inputs, all existing
finite scalar/tail/address/leaf/memory oracles, and explicit invalid/cap controls.
Compare valid input directly with the fully checked composition. For invalid
input, give the checked reference the same outer input guard and final fallback:
its final standalone `nx_optimize` is intentionally unguarded and could otherwise
fold an invalid input. Never execute recursive refusal or malformed witnesses.

If these gates pass, compare both policies in the same generated compiler image,
same source inputs, same host and output format, alternating order. Pin complete
products before timing; separate transformation time, external final verification,
serialization, process startup and object generation. Measure JS and native hosts
separately. The first target is reduced compiler/research-loop time with identical
generated code, not improved generated-program runtime. Keep the fully checked
composition as the diagnostic baseline even if the fast pipeline is retained.
