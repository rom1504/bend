# P5-023 — Final same-source checked B1, derived B1 and pinned TypeScript

- Owner: compact_index; independent reviewer and launch coordinator: root.
- Status: preparation; five pure refusal tests and a six-row tiny-library pipeline smoke pass. Two failed earlier smoke attempts are preserved below. No full-source timing has run.
- Objective: measure the final compiler's full-source compilation cost after the Phase5 semantic and host changes, before proposing another optimization.
- Scope: compilation performance and exact output checks; not full-language conformance or a self-hosting proof.
- Plan cutoff: freeze before the first process. Result updates belong in a separate implementation report, so the consumed plan can remain immutable.

## Comparison and cheapest disproof

The maintained equality derivative previously reduced successful compilation time. Test whether the effect survives the final Phase5 source and host. Stop on any failed checking, ownership, completeness, provenance, export-root or output gate. An incomplete or interrupted cell retains every observation and publishes no six-row comparison summary.

Use the genuine final `integration/attempt-05` checked build. The new tool calls maintained `verifyAttempt` and `deriveEquality`; the derivative retains its derivation report and never receives a fabricated checked-bootstrap sidecar. All three variants compile the exact assembled source recorded by that checked bootstrap, with canonical pinned Base. The Bend variants use the same frozen host helpers and output runtime.

Run six fresh processes on one physical CPU in order:

1. Pinned TypeScript.
2. Original checked B1.
3. Maintained equality derivative.
4. Maintained equality derivative.
5. Original checked B1.
6. Pinned TypeScript.

This provides two opposite-order B1/derived pairs and brackets them with two TypeScript observations. It does not provide statistical confidence intervals or establish performance on other programs. No concurrent compiler benchmark is allowed during this controlled window; record unavoidable shared-host activity.

## Inputs, gates and timing

- Pin and tracked-clean upstream checks use strict file-backed subprocess capture before and after the campaign. Source modules, bootstrap, APIs, derivation, runtime, Base, effects, Node, host, helpers, comparator and worker have before/after identities.
- Both Bend APIs prime their own validated on-disk Base cache in separate, untimed processes. Cache envelopes are verified and decoded Base graphs must be deeply equal. The caches become frozen inputs for all timed requests. No process-local warmed API is reused.
- TypeScript loads/checks Base on each fresh request. This asymmetry is explicit: ratios describe actual selected workflows, not identical cache work or an isolated backend comparison. OS caches are not flushed.
- Every compilation must pass full checking, ownership and unresolved-hole/open-law gates. The ordinary typed driver supplies Bend's library pipeline; pinned TypeScript calls its own unchanged checker and library emitter.
- An untimed actual B1 load/specialize/root preflight establishes the ordered requested roots. A separate TypeScript load/root preflight verifies the same eligible names. TypeScript receives that exact B1 order in its unchanged `js_lib` call, and every timed B1/derived request must reproduce the preflight order. The checked B1 classifier and generated full H classifier also validate the policy on retained TypeScript metadata through export-only adapters. TypeScript's default exported keys equal the requested order; Bend's ABI additionally exports runtime globals/dependencies, so every requested root must be present and B1/derived actual export keys must agree. The normal 54-export bootstrap API is never mistaken for full library roots.
- All B1 and derived emitted output bytes must agree. Repeated TypeScript output bytes must agree within its separate emitter family. Cross-emitter byte equality is not expected or claimed.
- Each generated module is imported in a separate oracle process and executes simple identifier predicates; root/export checks are outside the measured compilation process.
- Request time excludes imports, provenance hashing and output serialization. Process wall includes fresh process startup, imports, input verification and output capture. API phase timers are nested observations and must not be added. The delegated `j_roots` wrapper saves its unchanged return value inside request timing; list conversion/serialization occurs afterward. Peak RSS is the worker's maximum resident set in KiB.
- Resource settings: Node stack 4MiB, verified OS stack at least 8MiB, heap 12GiB, one pinned physical CPU, 900s maximum per compiler child, hard UTC campaign deadline in the final configuration. The draft deadline is 01:45 UTC, leaving time before the 03:39:36 campaign end for a separate proof and backend validation.

## Reproduction and preparation

The example config points to the intended final attempt, which must exist and pass genuine lineage verification before launch. Copy it to a fresh run-specific config, set an absolute attempt path and approved CPU/deadline, and preserve it unchanged thereafter.

```sh
node selfhost/tools/performance/phase5/full-source-compare.test.mjs
node --check selfhost/tools/performance/phase5/full-source-worker.mjs
node --stack-size=4096 --max-old-space-size=4096 \
  selfhost/tools/performance/phase5/full-source-compare.mjs \
  FINAL_CONFIG.json NEW_OUTPUT_DIRECTORY
```

The pure tests reject missing/duplicate/reordered/incomplete cells, invalid deadlines and resources, and invalid timing fields. They do not replace an actual compiler gate. Preparation, Base priming, Git checks, oracle processes and their logs are retained separately from the six timing samples.

## Preparation counterexamples and approved amendment

The original smoke-01 check incorrectly required `Object.keys(H.default)` to equal selected roots. The tiny source compiled successfully, but this oracle failed: `j_library_context` deliberately exposes all `G` globals, including runtime entries and dependencies. The gate now requires all selected Bend roots to be present and exact B1/derived export keys, while TypeScript retains its exact ordered export check.

Smoke-02 delegated the real `j_roots` call and disproved natural cross-compiler order equality: the same 41 eligible names appeared in exactly reversed orders on the tiny fixture. Before any full-source timing, root approved making the requested order an explicit shared workload parameter. The B1 preflight establishes it; TypeScript verifies membership then uses that same order. This changes only benchmark parameters, not either compiler. Preflight loading/specialization is explicitly **not** checking/ownership/emission proof; those gates still run in every measured compilation.

Smoke-03 passed all six fresh tiny-library rows, byte comparisons and output execution gates under that corrected contract. The failed reports and each consumed comparator/worker version remain under `selfhost/build/phase5/full-source-preparation/`. An explicit `smoke:true` mode uses a fixed tiny fixture and a distinct report kind; because it is not a compiler library, it cannot exercise an emitted `j_library_roots` export. The actual final-source gate retains that check. An explicit `preflightOnly:true` configuration performs only input/cache/root preparation and leaves `complete:false`, with `prepared:true`; no timing summary is produced. Final attempt-05's actual source preflight must pass before the long campaign.

## Fixed-point policy

The maintained `tools/conformance/selfhost.mjs` can resume only preceding stages from its own genuine report. It has no supported import-measurement-as-stage2 operation. Do not manufacture one or relabel a measured row as a bootstrap stage. After this comparison, run that unchanged tool from the genuine checked B1 with the same frozen source, canonical Base, host and runtime in a fresh proof directory. Compare its actual stage2/stage3 bytes with the measured Bend outputs as a separate audit. A completed comparison is not a completed fixed point.

## Preservation and decision

Preserve all request/result files, failed rows, outputs, tools, source identities, cache envelopes and actual proof links. Keep the final source comparison distinct from Phase4 observations and from selected frontend workflow timings. No production compiler change is proposed by this experiment. Conclusions await the complete six-row gate; any performance explanation needs separate causal evidence.
