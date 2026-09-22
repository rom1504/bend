# Saturated private substitution workers

**Rejected at the predeclared performance gate.** The narrow P4-025 candidate passes 157 selected semantic checks and four exact-output compiler-core observations, but its two opposite-order request reductions are **7.25% and 1.99%**. The second falls below the required 5%. No additional pair, broader sweep, full-source emission or production promotion followed this result.

The experiment ran from the [recorded plan](../../experiments/phase4/P4-025-substitution-workers.md), motivated by [P4-023's actual family counts](matcher-family-counts.md). Those counts identified substitution as a plausible target; they did not establish that its partial-function allocation was expensive enough to yield a useful whole-request improvement. This result preserves that distinction.

## Exact intervention

The control is immutable private image `4318bbcdb2040ad794387b1466b0bafbe12233e67983224c5a564d13fa5753a3`, derived from final source `34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122` and completed H proof `b33b38e3…`. The candidate is `50d9c8090276c5cb57f48912783d8660020bbd0089ef2ebbe98ba54e675c37f9`.

The transformer changes **one** inspected call site: the non-Var branch of `privateWorker1077`. Its term, identifier and replacement are already-bound local values, so no later argument expression moves ahead of a potentially failing match. Two new private workers handle the KTerm and list cases; only their own recursion uses the new list worker. All original G definitions, public/global entry arities, generic matcher functions and the runtime remain byte-for-byte unchanged.

The fast path requires an exact `KTerm` tag with six own array fields, or `Nil`/`Con` with zero/two own array fields. Wrong tags, missing fields, sparse arrays and extra fields execute the original staged applications. A complete image hash and individual original-body hashes make this an exact-image experiment, not a general JavaScript rewriter.

The KTerm worker still projects fields, substitutes children, reconstructs the original fields and removed metadata, then calls the unchanged `core_rebuild`. It does not skip App beta reduction when the substituted identifier is absent. The Con worker still returns ordered head/tail build thunks and an explicit private tail bounce. Constructor demand and build-stack machinery remain in use; this is not a direct recursive JavaScript list walk.

This reasoning is limited to immutable finite compiler data. In particular, binding projected fields earlier or later is observable with injected getters or mutation; those values are outside the private input contract. No arbitrary public getter/proxy equivalence is claimed. The original public/global entries remain available for zero, partial and overapplication and noncanonical shapes.

## Semantic controls and review

Three successful retained control runs contain 151, 156 and 157 checks respectively. Later runs add reviewer-requested coverage and stricter assertions; earlier reports and their exact consumed test-tool revisions are retained.

The final 157-check gate includes:

- Matching/nonmatching variables, dependent binder structures, quantified fields, annotations, constructors, captured replacement values, and removed metadata. Removed metadata also retains its exact object reference.
- Lam-headed and neutral Apps, including an explicit control proving beta reduction still occurs when the substituted identifier is absent.
- Malformed tags, field counts, sparse arrays and canonical KTerms with malformed children; exact returned values/function descriptors or exception names/messages match the original.
- Original global zero/partial/overapplication and an early matcher error before a throwing later argument. The latter deliberately tests the unchanged G boundary, not the new worker's implementation.
- A failing list head before a malformed tail, with the observed error explicitly required to equal the head-only error.
- A successful 300-level binder structure and **100,000 successful list-tail steps**. The latter validates every Con field count, the exact spine length and terminal Nil, then compares the complete output digest. Neither deep test is permitted to pass merely because both variants throw a stack-overflow error.
- Refusal of a changed source image, and before/after identities for consumed test inputs.

The tests invoke the changed `privateWorker1077` and both new helpers directly. Testing only the unchanged `G.subst` entry would not establish that coverage. Large outputs use an iterative canonical traversal, preserving array lengths and holes as well as data fields. These selected controls do not replace full frontend/backend or full-source gates, which were not earned by the performance result.

The [independent review](private-substitution-workers-review.md) found no blocker for this bounded private-data experiment and requested the explicit successful-deep-result/head-error assertions. It does not establish a general emitter theorem or approve production integration.

## Controlled core result

The fresh output directory is `selfhost/build/phase4/substitution-workers-compare/`. Both variants use the same 60,909-byte compiler-core source, frozen host and runtime, canonical pinned Base and completed-proof lineage. Each sample runs in a fresh Node 24.18.0 process on CPU3 with a 4 MiB stack and 3 GiB heap. Separate Base caches were explicitly checked before measurement and remained hash-frozen. Base preparation took 8.276 s for control and 8.197 s for candidate, separately from the table; OS caches were not flushed.

Root released the preceding full-source gate before this pilot. No other intentional compiler workload ran during these samples. This describes resource scheduling, not physical isolation from operating-system, storage or shared-memory activity.

| Order | Control request | Candidate request | Reduction | Control process | Candidate process |
| --- | ---: | ---: | ---: | ---: | ---: |
| Control, candidate | 25.309 s | 23.474 s | 7.25% | 26.417 s | 24.586 s |
| Candidate, control | 24.569 s | 24.079 s | 1.99% | 25.689 s | 25.203 s |

Peak RSS in recorded order is 580,280, 580,016, 575,344 and 579,608 KiB. All four requests pass full checking and emit identical 138,371-byte libraries, SHA `016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186`. Complete emitted buffers are compared in addition to hashes. All original inputs, caches and image identities pass the final drift check. Every subprocess exits zero, without signal or timeout.

The request includes the ordinary host/ABI compiler pipeline after API loading; process wall additionally includes startup/loading and report/output work. Neither is an annotation-only or substitution-only timer. The run began at 19:29:12 UTC and finished at 19:31:15 UTC. No average is substituted for the failed opposite-order threshold. Both pairs are faster on this workload, but the second is insufficient for the predeclared escalation decision; the data do not prove zero benefit or a statistically precise effect.

## Decision, preservation and replay

The general typed-worker architecture remains open. This result rejects the **particular one-site, guarded private substitution candidate** as justification for broader integration during this pass. Extending it to arbitrary staged applications would still require evaluation-order, closure-capture, malformed-input, binder and stack proofs, and the present counts cannot predict a payoff. Do not rerun the small pair repeatedly until it crosses the threshold or silently relax the 5% requirement.

The [evidence manifest](private-substitution-evidence/manifest.json) preserves 142 references to 70 content-addressed gzip objects, 1,797,573 packed bytes: all three control reports and generated probe images, original/candidate images, exact outputs, all six prime/sample records, configurations, requests, validated caches, frozen host/helpers, consumed tools and historical test-tool revisions. Node remains an external executable prerequisite with its exact recorded hash/version. Every object was decompressed and hash-checked when archived. Archival hashing/compression took 0.545 s on CPU3 after the pilot; it was not part of either timing pair.

From `selfhost`, reproduce the semantic gate with `node --stack-size=4096 --max-old-space-size=3072 tools/performance/phase4/private-substitution-test.mjs ORIGINAL_IMAGE NEW_DIRECTORY`. Reproduce the isolated pilot with `node tools/performance/phase4/private-substitution-compare.mjs CONFIG NEW_DIRECTORY`, using the retained configuration and a successful final control report. The comparison enforces CPU3 internally and verifies the original image/proof, exact derived candidate, cached Base and expected output. The archive tool is `private-substitution-archive.mjs PHASE4_BUILD NEW_DIRECTORY`; labels in its manifest retain the original consumed paths without requiring duplicate objects.

No compiler source, canonical private package, runtime, default API, fixed-point report or completed validation result was replaced by this experiment.
