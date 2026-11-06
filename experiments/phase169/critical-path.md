# Phase169: the critical path to a 150-second native self-build

Source/evidence review, 2026-11-06. No target execution or production change.
The qualified reference remains Phase152: **249.222 seconds**, complete native
source-to-executable under its authenticated prepared-Base policy. Reaching 150
requires **39.81% less complete time**. The conclusions below distinguish measured
results, cost envelopes and conditional engineering targets.

## Decision

The strongest architectural bet is **one canonical function computation with
verified call interfaces and explicit resumable frames**, instead of constructing
generic scheduled bodies, separate direct candidates, and later rediscovering
their composition. Phase168 is a working entry point, not proof that the entire
replacement pays. Its important feature is making semantic interfaces available
before dependent analyses; preserving that ordering matters more than adding
another late optimizer.

The fastest useful next experiment is a **larger complete checker/optimizer
closure through that working early-interface path**, plus a separately controlled
native construction/ownership experiment. A new equality implementation, generic
compaction cache or admission-fuel change is already contradicted by evidence.
Neither another direct-first microbenchmark nor a compiler acquisition without
an explicit whole-request budget answers the remaining question.

For the immediate Phase169 campaign, reuse Phase168's actual working route and
the runtime-helper experiment before starting the larger frame representation.
The architectural proposal is the escalation if that measured pair cannot close
the budget, rather than a reason to delay the existing native-transfer test.

## What actually has enough cost to matter

[Phase161](../../implementation/phase161/README.md) and its
[profile metrics](../../implementation/phase161/profile-metrics.json) partition
239.794 diagnostic CPU seconds. These are not clean wall-clock predictions:

| Disjoint responsibility | Diagnostic CPU seconds |
|---|---:|
| All work before backend entry |83.223|
| Generic body production |11.588|
| Private/direct candidate production |26.782|
| Initial optimizer |23.673|
| First independent verifier |7.857|
| Observer composition and selected final admission |19.625|
| Registry construction |16.190|
| Rendering/output/teardown |40.208|
| Remaining backend/interstage work |10.648|
| **Total** |**239.794**|

The final admission includes its nested final verifier. Do not add that verifier
again. Backend work totals **156.571 seconds**. A hypothetical **2× complete
backend** saves 78.286 diagnostic seconds, 32.65% of this CPU observation. That is
a sufficiently large envelope for the requested ≥25% opportunity. It is **not a
measured gain**, and deleting the 11.588-second generic producer alone cannot
achieve it: downstream candidates, optimization, registry and temporary lifetime
work must fall too.

The same-output execution comparison is independent evidence that the work is
not intrinsically tied to the present time. [Phase160](../../implementation/phase160/README.md)
ran the same compiler implementation and full input through QBE in223.237s,
through bendc/C in167.602s, and through the same C executable with a different GC
headroom factor in138.383s. Complete118,227,421-byte QBE outputs agreed. However,
the last route used about5,057MiB RSS, versus1,043MiB for QBE, and these are
compiler requests rather than complete machine acquisitions. **138s is not an
achieved 150s native QBE self-build.** It establishes broad execution headroom,
without identifying a single missing optimization.

## The proposed source-level architectural change

At the prepared-definition boundary, make a checked function summary and one
function computation the durable products. Keep ordinary calls, owned/borrowed
argument/result contracts and explicit suspension/resumption edges in that
representation. Lower calls to direct machine calls when their verified summary
permits; otherwise materialize an explicit resumable frame. Build generic/public
ABI adapters only for real demand. Preserve the independent final checker and
its refusal behavior.

The concrete existing seams are:

- `p144o_lower_bangs` currently calls generic `p111_compile_defs` and private
  `p113pl_candidates`; both already read prepared `NativeStaticBody` facts.
- `p168j_imports` / `p168j_registry` in
  [adapter-imports.bend](../../selfhost/tests/phase168/adapter-imports.bend)
  provide real verified interfaces before region discovery and exclude imported
  owners from redundant region candidates. Real forwarders satisfy every import.
- `p134e_registered` in
  [stream-emission.bend](../../selfhost/src/back/qbe/stream-emission.bend)
  retains generic segments, direct functions, IDs/indexes and region metadata
  concurrently. Output already streams; there is no missing whole-file writer
  to fix.
- [model.bend](../../selfhost/src/back/qbe/model.bend) still represents local
  identities as Strings and bodies/operands as boxed lists. The new durable
  function boundary should preserve numeric identities from its producer and
  avoid a pack/unpack conversion around unchanged consumers.

The difficult missing capability is **non-tail recursive composition with bounded
machine stack**, not another round of readiness iteration. The actual
[Phase167 obstruction graph](../phase167/admission-obstructions.md) has closed
`index_remove` recursion, persistent insertion, and verifier body/schema SCCs.
Early scalar observation discharged exactly the predicted comparison cascade;
it did not discharge those other obligations. A general constructor-continuation
or explicit-frame operation addresses the recurring representation requirement.
Unrestricted native recursion, a function-name whitelist, or a fabricated ready
entry does not.

This is deliberately larger than the Phase164 mixed direct-first route, whose
full private-source acquisition201.931→201.271s was neutral. Merely selecting
direct code earlier while retaining equivalent downstream work already failed.

## Cheapest decisive test and stopping rule

Use one retained, nonempty checker/optimizer closure substantially larger than
the39,333-byte verifier, with realistic recursive terms and persistent updates.
Include the existing verifier and lookup as transfer/quality controls. Reuse
Phase168 API05 and the exact source/root/output methods where applicable.

1. Run baseline versus the **existing** early-interface path first, charging the
   entire backend, final verification, rendering, output and teardown. Keep
   frontend/API/Base clocks distinct. Record candidate fate and retained body
   populations; do not treat hosted tagged events as native allocations.
2. Inspect its largest unresolved non-tail SCC. Implement one general explicit
   resumable-frame rule in Bend at the function boundary, then test both complete
   persistent update and an unrelated recursive tree/checker computation. Retain
   old roots and consume complete changed and unchanged results. Deep recursion,
   shared roots, errors and malformed interfaces must exercise the fallback.
3. Compile those **same source workloads** to native and run their complete
   computations. Require the end-to-end construction saving and stable execution
   together. The previous≤1.10× pilot runtime tolerance is too permissive for an
   already ambitious self-build forecast: aim for≤1.03× on the larger compiler
   computation and require evidence explaining any regression.
4. Advance to one native compiler image only if the complete backend is near
   **0.50–0.55×** on representative compiler closures, or a separate demonstrated
   execution improvement closes the budget. Otherwise use the new stage result
   to reject the 150s forecast or change the architectural scope.

The first baseline/transfer screen is a bounded reuse of existing tools, roughly
30–60 minutes of engineering plus the root-owned target lane; this is a planning
estimate. A genuinely general resumable-frame representation is a multi-hour or
multi-day implementation, depending on reuse of existing region contracts. Do
not turn that uncertainty into a promised one-hour full rewrite.

## Why execution and frontend work should remain parallel hypotheses

[Phase166](../../implementation/phase166/README.md) gives a particularly cheap
execution falsifier: the same complete lookup/digest source takes0.54148s QBE,
0.35772s mature C and0.15649s bendc C. Its expected-record counterfactual still
takes0.28461s QBE versus0.11678s bendc. QBE constructor/take helper leaves account
for46.73% of the original kernel, with91 constructor and19 take static call sites
in its scanner. Test **inline unique-cell construction/take with unchanged
shared/error slow paths** on that frozen pair and an unrelated real traversal.
Inspect spills/frames and count whole ownership events; removing the call alone
does not remove its memory work. This is the fastest execution experiment, but
46.73% is a kernel envelope, not a full-build forecast.

The whole-compiler physical envelope is broader: [Phase153](../../implementation/phase153/README.md)
attributes42.71% to reclamation, ownership/products, allocation and register
transport combined. Allocator-only leaves are merely1.85%; a faster allocator
alone cannot deliver25%. A material whole-request gain requires lowering several
of those coupled costs, or preventing the temporary work itself.

Frontend algorithms also contribute, but their already-known effects must not be
counted twice. [Phase162](../../implementation/phase162/README.md) records the
existing publication policy reducing checking allocations613.60M→254.70M;
the prior clean native gain was4.62%, while the C diagnostic benefit was larger
because GC changed. Integrating/qualifying that result is a useful independent
gain. Compact App alone regressed complete native checker execution4.7% in
Phase163. Source closure saved14.32% emission in Phase161, but changes constructor
identities and the benchmark input; keep that separately qualified from fixed
full-source speed.

For scale, a **conditional budget**, not a forecast, is a25% cheaper83.223s
frontend/preparation prefix plus a2.2× cheaper156.571s backend:62.417+71.169
=133.586 diagnostic CPU seconds. That leaves16.414 seconds for the complete
pipeline's other cost before150s. The present249.222s pipelined build overlaps
compiler/QBE execution, so its7.119s remainder is not an independently fixed
machine allowance. Only a matched complete build can close this budget.

These targets are hard but explicit. Phase168's verifier backend21.555→17.965s
and lookup backend7.480→2.919s show highly variable transfer: one does not meet
the budget, the other does on a small workload and regresses execution. That is
why the next larger complete native computation is more informative than another
small favorable helper or another full acquisition of an unconvincing candidate.

## Small independently validated integration: Phase156 publication provenance

This result is already earned and still absent from maintained production.
Integrate it separately so Phase169 cannot accidentally claim it as a new
discovery or attribute it to the backend. The retained native experiment has
two reversed full-source pairs:215.026310→205.086488s per-role medians, **9.940s
less source-to-QBE request time (4.62%)**, all four complete outputs exact.
That excludes machine construction and is not a guaranteed10s reduction in the
current pipeline. [Report](../../implementation/phase156/README.md),
[metrics](../../implementation/phase156/metrics.json).

The minimal implementation comes from
[publication.bend](../../selfhost/tests/phase156/publication.bend), SHA256
`5ae6a0288a00d4b04758ceaf4f86ddc4a6264adc52a92662bb3597cbb217f60c`:

- Add exactly eight private helpers: `p156cp_continue`, `p156cp_stored`,
  `p156cp_put`, `p156cp_publish`, `p156cp_next`, `p156cp_guard`, `p156cp_walk`,
  `p156cp_start`.
- Replace only `p143cp_seed_ready` and `p143cb_resume_state`, both in maintained
  [compact-schedule.bend](../../selfhost/src/check/compact-schedule.bend), with
  their two candidate bodies. The original ordinary loop remains available.
- Those ten declarations, with `@unsafe` markers and separating blanks but no
  harness comments, are79 lines/4,147 bytes. They depend only on existing
  maintained definitions, introduce no type and do not alter `KWorld`.
- Do **not** import the original/reference exports, load-only ancestor clones,
  request harness, shared-use overlay, dense experiment or Phase154 codec into
  production. The old combined test API needed the codec; the publication
  algorithm itself has no such dependency.

The private dirty bit starts True at both entries. False means the complete
book is already its canonical projection **and** the existing cache agrees
with first-visible raw-tail lookup. Ordinary canonicalize-and-`book_put`
establishes this state; childless logged publication sets True; skipped
publication preserves it. The candidate skips only the known-redundant
canonicalization. Existing checker mutation sites preserve cleanliness or
restore that check's entry book. The ordinary `p143cp_result` still canonicalizes
all outward logging results, including errors. Logging=False takes the complete
old path. The real planner's256-childless-suffix admission threshold, Base
ordering, bound arithmetic and prepared-world/hash-disjoint fallback stay exact.

Retain the [source invariant](../../research/phase156/publication-invariant.md)
and [independent review](../../research/phase156/semantic-review.md). Refresh the
mutation closure against the integration source: previously435 distinct names /
578 declaration blocks. A source edit adding a new world mutation is not covered
by the historical audit. This is a source argument and finite evidence, not a
new theorem or already completed native qualification.

The exact finite evidence is a **composite gate**, not an all-green old report:

| Receipt | Status and identity |
|---|---|
| `selfhost/build/phase156/controls-prepare02/checked-api/report.json` | Checked API complete; SHA256 `be209036457aca2164cca7df440adf440b5013c666beffbf39ea1eb073fa36a7` |
| `selfhost/build/phase156/controls02/report.json` | Retained failed report:11 publication cases, genuine Base, actual645-declaration checker and8-declaration Map worlds pass; sole bad fixture expected duplicate-source parsing to succeed. SHA256 `50a04749305f780c97759776691c6e2e4959d23a710c698edaa0a9757ea50cd8` |
| `selfhost/build/phase156/duplicate01/report.json` | Complete/pass; explicitly binds the failed row, requires exact duplicate parser refusal, separately checks duplicate checker events with logging False/True. SHA256 `3094e9fbcd2f4a06d0094220afdec3387528204b2848c641cb4e24fc91f2f0ca` |

`implementation/phase156/metrics.json.semanticGate` declares that composition;
the source/evidence archive is
`implementation/phase156/evidence/phase156.tar.gz` with its `capsule.json`.
Full structured `DChecking` comparisons include term/type/uses/error, complete
book/index, memo/fresh/checked state and diagnostics. Checksum-only tests are
insufficient. Existing collision/deferred-fresh proposals are not claimed as
executed controls merely because `publication/spec.json` lists them.

The cheap integration check is source admission plus these actual-world and
failure controls, followed by exact small native products. Combine with the
selected backend only after an isolated source-only delta is frozen; one final
native lineage/qualification can then establish the combination. Re-measure the
complete full build rather than subtracting the historical9.940s from249.222s.

### Prepared minimal source

[Phase169 publication.bend](../../selfhost/tests/phase169/publication.bend) now
contains exactly those ten original declarations, retaining the `p156` names:
79 lines,4,147 bytes, SHA256
`5b0c7b87db77cfff6cadc1d8708f766d763700773f1df95fbdf036b534aa9be7`.
[The extraction receipt](publication-extraction.json) records individual
declaration hashes and the two override names. Each complete declaration,
including its `@unsafe` annotation, is byte-identical to the frozen Phase156
module. Replacing the original ten spans with independently reparsed extracted
blocks reconstructs the entire original module byte for byte. No reference,
loader, test observer, new type or extra experimental dependency is included.
This is extraction evidence only: fresh source admission, integration controls
and native qualification have not run for this module.
