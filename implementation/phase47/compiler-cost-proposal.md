# Phase47 compiler-cost census and bounded proof reuse

Recorded 2026-10-04. Status: **read-only source assessment; diagnostic producer prepared; no target run, measurement or promotion**. This track concerns compiler requests, separately from Phase47 generated-program optimization.

The installed Phase45 worker23 is the baseline. Its [compiler-cost report](../phase45/compiler-cost.md) records 36 successful checked requests, with request medians 2,282 ms local-pair, 4,422 ms lexer, 7,461 ms Map and 1,515 ms closures. Against Phase44, all four increase, by 8.62%, 28.55%, 1.32% and 1.20%. These are whole requests including lazy API/Base handling, not a profile of any specific pass. Lexer is the clearest regression to investigate first; Map is the largest absolute request. Neither observation attributes their cost to graph proof.

## What the source establishes

| Work | Concrete sites | Established fact and limit |
| --- | --- | --- |
| Host load, check, reach, annotation, layout and emission | [typed-driver.mjs](../../selfhost/tools/typed-driver.mjs): `inspectWithMemo` | Calls distinct public API stages. A saved-API wrapper can measure their synchronous call boundaries without rebuilding. Import and discovery remain separate. |
| ABI2 validated-prefix input | [driver/api.bend](../../selfhost/src/driver/api.bend): `check_program_diagnostic` | Receives `validated` but calls `dg_check_world(book)` on the full book. This is visible redundant source input handling, **not evidence that skipping validation is correct**. |
| Diagnostic prefix API | [diagnostic/produce.bend](../../selfhost/src/diagnostic/produce.bend): `check_book_diagnostic_from_exact_prefix`, `dg_check_world`, `dg_check_events` | Explicitly rechecks: source-only caches cannot restore live memo/output state. Events preserve chronology, signature mode, first failure and published checked bodies. |
| Checker state and transformed bodies | [check/kernel.bend](../../selfhost/src/check/kernel.bend): `KWorld`, `KWorldFresh`; [diagnostic/produce.bend](../../selfhost/src/diagnostic/produce.bend): `dg_event_publish`, `dg_event_output` | Prefix reuse would need a validated state checkpoint, not just equal source definitions. The full-book binder bound also participates in initialization. |
| Existing component/direct-plan reuse | [back/js/jpure.bend](../../selfhost/src/back/js/jpure.bend): `j_plan_context`, `j_plan_prepare`, `j_plan_components`, `j_plan_directs` | Already builds indexed request-owned facts once per selected canonical name. Prior plan metadata is stripped at the next request. Do not propose another name-only cache for these existing facts. |
| Contextual root construction | [back/js/jpure.bend](../../selfhost/src/back/js/jpure.bend): `j_instance_root` through `j_instance_root_raw` | Each eligible public root collects contextual rows, replays source provenance, rewrites a private view, and starts a new complete JPure graph. Overlap across roots is plausible; equivalent contextual views have not been counted. |
| Per-graph body proof | [back/js/jpure.bend](../../selfhost/src/back/js/jpure.bend): `j_pure_graph` | Already suppresses repeated completed graph definitions by name **inside that graph**. It proves the own body before publishing a graph node, so recursive backedges cannot skip body obligations. A global success bit would lose this invariant. |
| Type proof | [back/js/jpure.bend](../../selfhost/src/back/js/jpure.bend): `j_pure_type`, `j_pure_type_check`, `j_pure_signature` | Outer Boolean query always starts with empty active owners and fuel 512. Many signature/body/layout checks can ask it repeatedly. Inner queries carry active owners and remaining fuel and are different queries. |
| Private lowering, component graph and Nat choice | [worker-emit.bend](../../selfhost/src/back/js/ir/worker-emit.bend): `j_worker_emission`, `jw_emission_mode`; [worker-graph.bend](../../selfhost/src/back/js/ir/worker-graph.bend) | Complete per-root rewritten functions are lowered, simplified and partitioned; Number-Nat eligibility is then assessed. Root-local names, exact instance rows and representation mode prevent name-only cross-root reuse. |

The host's existing verified Base cache can still reduce loading/parsing even though ABI2 rechecks. It is incorrect to describe it as wholly unused. The host also has a persistent inspector with explicit API identity checks; this proposal neither expands its public cache contract nor changes source discovery.

## First experiment: one diagnostic census, not a caching build

The prepared [compiler-probe.mjs](../../selfhost/tools/performance/phase47/compiler-probe.mjs) is a **producer**. It verifies a checked attempt, requires exact generated-function anchors and emits a saved counter API plus a runner into a fresh output directory. Preparing it does not invoke the compiler. Root owns execution.

The counter overlay delegates every original call unchanged: no normalization, forcing, memoization, early return, new acceptance or changed fuel. It counts the stage/query entry functions listed in its derivation receipt, including checker events, component plans, contextual roots, instance replay, JPure graphs/type queries, worker lowering, components and Nat eligibility. Exact raw `(book object, type object)` repeats are tracked only at the outer `j_pure_type` entry; no term-only conflation is allowed. Weak identities do not retain their keys. The bounded set retains at most 40,000 numeric pair keys, then marks truncation explicitly. Structurally equal freshly allocated types are intentionally missed.

The runner uses the driver's normal `loadApi` and ABI adapter, then wraps public API calls to record elapsed synchronous time. It does **not** time internal tail-returning functions as completed stages: doing so would assign deferred work to the wrong stage. These public measurements include marshaling and may nest or overlap; do not add them blindly into a total. Counts and instrumented timings are attribution clues, not clean baseline timings or a predicted cache speedup. Wrappers add allocation and dispatch overhead.

Example commands, executed serially by root under the existing CPU/heap/RSS supervisor:

```sh
/home/ai/.nvm/versions/node/v24.18.0/bin/node selfhost/tools/performance/phase47/compiler-probe.mjs CHECKED_ATTEMPT SOURCE_BEND NEW_DIAGNOSTIC_DIRECTORY
/home/ai/.nvm/versions/node/v24.18.0/bin/node --max-old-space-size=1024 NEW_DIAGNOSTIC_DIRECTORY/run-census.mjs SOURCE_BEND check NEW_CHECK_REPORT_JSON
/home/ai/.nvm/versions/node/v24.18.0/bin/node --max-old-space-size=1024 NEW_DIAGNOSTIC_DIRECTORY/run-census.mjs SOURCE_BEND library NEW_LIBRARY_REPORT_JSON
```

Use the same lexer source from the maintained compiler-cost catalog first, then Map only if attribution warrants it. Acquire an ordinary selected-API check/library pair before the diagnostic pair and compare exact verdict, phase, diagnostic, output bytes/hash and checked flag. The diagnostic runner records the entry source, API, runtime, Base, driver, ABI adapter and producer hashes, rehashing them after the request. It explicitly does not claim a complete imported-source graph receipt: root must join the existing host acquisition/checked-emission receipt for all transitive source inputs. It also does not run a target generated by the compiler.

A fresh-process request should be of the same order as the current 4.4-second lexer request, plus import/Base/cache and diagnostic overhead; this is a scheduling estimate, not a bound. Allow the normal supervisor timeout (for example 60 seconds per small request), preserve exceptions and timeouts, and do not automatically escalate to full source. Cache policy must be equal across control/diagnostic requests. A new diagnostic API hash gets its own Base-cache identity, so priming and cold Base setup must be recorded separately. Counts can include Base preparation as well as the program request; distinguish those runs before interpreting checker-event totals.

The cheap discriminators are:

1. Public checking versus annotation versus JS emission attribution. If checking dominates and instance/JW counts are small, do not spend this iteration on graph caching.
2. Number of selected/root/component/graph/type visits. Existing component-plan counts should show the current deduplication; contextual graph roots may revisit shared source helpers in distinct private views.
3. Exact repeated outer type-query pairs and truncation. Zero repeats defeats the identity-cache candidate for that source; a high hit count alone is insufficient.
4. RSS and diagnostic overhead against the ordinary request. An unacceptably expensive counter can still be discarded without any maintained compiler change.

## One safe reuse candidate, conditional on the census

**Candidate:** completed Boolean results of `j_pure_type(book, ty)`, within one immutable analysis-book lifetime only. This is deliberately smaller than caching `wnf`, a whole JPure graph or emitted workers.

The context-complete key is the exact analysis-book identity plus exact type identity, fixed proof-policy revision, and the outer entry's fixed `(active = Nil, fuel = 512)`. Book identity includes constructor definitions, native ownership, contextual substitutions and source/dependency lookup. Type identity includes quantity information, children and removed-constructor metadata. Never share the cache across a source book and a newly rewritten contextual view merely because the printable type name matches.

Store only completed true/false results. Do not cache exceptions, unfinished recursion or a success extracted from an inner active-owner shortcut. A bounded cache miss or saturation executes the original query unchanged. This Boolean entry exposes no remaining fuel and does not debit JPure's separate graph budget, so completed reuse does not silently restore graph admission budget. Its inner `Maybe<U32>` query **does** expose consumed fuel and active recursion context; caching that with only `(book, type)` would be invalid.

A saved-API causal prototype may use nested WeakMaps on these private immutable keys, but it would remain diagnostic. Any maintained implementation must stay in Bend and attach an explicit request-owned type-fact index to the existing plan/analysis context or thread a bounded fact table through the relevant analysis state. Cache lookup/equality costs, propagation changes and metadata storage must be measured. Public raw compiler graphs are not automatically immutable; a host-wide exported-function memo would exceed this proposal.

This first candidate does not solve equivalent but separately allocated contextual views. If raw identities show no useful repetition, stop rather than adding structural hashing, normalization or persistent invalidation in the same experiment. A later candidate could publish own-body/callee facts per exact contextual row and compose SCC summaries, but would need explicit original provenance, rewritten telescope/body, local slot mapping, fuel charge, graph-capacity policy, visited state and representation mode. No implementation of that broader cache is proposed here.

Before a maintained cache change, root should require a saved-API counterfactual, then clean alternating fresh-process timings and memory, followed by source-level isolated implementation and exact gates. Falsifiers include a changed refusal under exhausted budgets, changed first diagnostic, stale Base/import/source/type/native identity, private-row name collision, wrong recursive closure of an ADT, transformed-book reuse, or changed emitted bytes. Same-path edits, failed requests followed by corrected imports, restored source and separate compiler/API identities need coverage. No performance gain is claimed yet.

## Why the Base-prefix shortcut is a different project

An ABI2 checkpoint would need to capture the exact `KWorld` after validated chronological events, the `seen` event book, checked output publication, specialization/completion state, source-event position, whole-book declaration environment and fresh/binder bound. A later suffix can change declaration/signature modes or binder maxima. A state-bearing prefix cannot be reconstructed by inserting source-only validated definitions into a seed without proving those interactions. Prefix identity also includes imported source, compiler policy, Base and ABI identity.

The right cheap first question is how many `dg_check_events`/definition visits belong to Base setup versus repeated main checking, not how to bypass them. If their measured cost dominates, specify a real state checkpoint separately, with chronological forward-law fills, suffix conflicts, delayed definitions, changed imports, unsafe/safe visibility, structured first errors and TODO completion controls. The existing recheck comment is a correctness boundary, not accidental dead code to delete.

## Prior evidence and lessons from compiler research

- [Rejected P4-010 WNF memo](../phase4/private-wnf-memo.md): 339,730 calls, 39.2% repeated exact book/term pairs across 465 books; the cache made the real core 4.4% slower and peak RSS 2.9% higher. Never rank by hit rate alone. Cached term graphs retain more memory than a Boolean result.
- [P4-009 stability memo](../../experiments/phase4/P4-009-stability-memo.md): 89.2% repeated identities yielded only 6.1% less core time. Even a profitable memo does not turn hit fraction into end-to-end savings.
- [P9-005 chronological cache](../../experiments/phase9/P9-005-chronological-cache.md): removing repeated bound scans required a distinct chronological cache and a constructor-metadata collision repair. Reusing broader context required source-history controls, not an indiscriminate global cache.
- [Rust research](../../research/compilers_architecture_and_techniques/rust.md): query keys, dependency reads and cached CFG invalidation are explicit. Use immutable request-local facts first; a persistent result needs complete dependencies and stable identities.
- [Zig research](../../research/compilers_architecture_and_techniques/zig.md): inspected comptime memoization preserves branch accounting and is disabled where incremental dependency tracking is incomplete. This directly cautions against losing fuel or dependency provenance on a hit.
- [Go research](../../research/compilers_architecture_and_techniques/go.md): export data carries typed bodies and escape summaries; bottom-up analysis and bounded inlining enable reuse, while diagnostics expose stage decisions. Shared facts should precede blanket repeated graph construction.
- [Lean research](../../research/compilers_architecture_and_techniques/lean.md): specialization and lambda lifting use explicit keys and bounded caches. Function names alone are insufficient when captures, concrete types and representation choices differ.

Compiler query reuse does not remove generated-runtime dependency guards. Immutable compiler facts and mutable public `G`/descriptor/host observations are different domains. Phase47's runtime and compiler-latency tracks should retain separate outcomes and promotion decisions.
