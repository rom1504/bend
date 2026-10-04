# P45-018: require repeatable work for a new alias-only public worker

Status: isolated candidate over frozen worker17b. Independent static review passes; checked build and performance qualification are pending. No runtime or public ABI change is proposed.

## Falsifier from the full comparison

The first long worker17b batch passed its value observations, but exposed a severe regression in `complete-generic-row32`. Across five fresh rotated rounds, the Phase44 baseline median was **0.420292ms**, worker17b **4.528299ms**, and pinned TypeScript **0.007297ms**. Candidate/TypeScript was **620.529×** and baseline/candidate **0.092814×**: approximately a 10.77× regression against our predecessor. The next runtime batch was stopped by the root, preserving its partial evidence; this is not a completed full-corpus qualification.

The retained report is `selfhost/build/phase45/qualification17b/runtime-0/report.json`. The independent static isolation is `local-row-analysis17b.json` (SHA-256 `47ee708bf39d9b1bc1924e67483c97646fd6c85742a605e8bd3f47dc0d95e1a1`). Its observation adapter is identical for both compiler roles.

Only one complete public assignment differs: the scalar helper `umin` grows from 485 to 2,393 bytes. Replacing that assignment with its predecessor reconstructs the entire baseline module byte-for-byte. The root delegates to one other acyclic scalar helper; its new wrapper admits a two-function graph, installs a 56-dependency guard fence, and enables the module's first exact-entry descriptor. The generic row evaluates this helper twice per cell. It never opens a private region around that path, so repeated calls reach the public guards.

This isolates the changed generated code. It does not separately measure guard cost versus changed JIT behavior or the global exact-entry check. The hypothesis is that fixed public-entry cost overwhelms a small acyclic body. Similar newly admitted acyclic public roots occur in lexer, ray, scalar-region, mandelbrot, symreg and tree code, so the proposed rule is structural rather than a row-program exception.

## General typed selection rule

Retain the successful typed ranking from [P45-016](P45-016-root-plan-ranking.md). For the newly broadened **alias-only public worker** route, additionally require that its complete lowered private graph contains recursion. Real contextual specialization retains its earlier admission; acyclic private callees inside a qualified graph remain available.

`JWEmission` now carries `recursive` alongside emitted code and Number-Nat mode. The fact is derived from the **same complete SCC result already used by emission**, after successful lowering and simplification:

- Any component label different from its function's own index witnesses a multi-member SCC.
- A singleton SCC is recursive only when its explicit instructions contain a call to itself; the existing instruction visitor checks both case branches.
- A missing or refused graph returns false. No partial graph is interpreted as complete evidence.

This adds one bounded scan of functions and instruction nodes, without another source-graph proof or reachability calculation. Number-Nat rewriting preserves private call edges. The general emission result type moves from `worker-nat.bend` to `worker-emit.bend`, which owns its broader meaning.

The admission check consumes the original exact instance rows: a source alias has erased-prefix arity zero, while a genuine contextual row has positive erased-prefix arity. It encloses **both** the new worker and legacy instance-emitter fallback. Returning empty declarations alone would be insufficient, because the inherited fallback could reinstall the same expensive public guard.

Recursion is evidence of potentially repeatable work, not a proof of profitability for every input. Depth-zero or untaken-cycle paths can still pay a guard; an expensive acyclic graph can be conservatively declined. This is a bounded general selection heuristic, not a new execution permission or a complete cost model. Declaration construction still occurs before refusal, so no compiler-speed improvement is claimed.

## Isolation and safety

The isolated patch changes three files, adds 25 net physical lines, and changes no manifest or runtime. It is based only on frozen `source-worker17b`; patch SHA-256 is `d5fc7663ebc836d83cd34a6439ca5fb4f5ff5424bcdc546617c48ae0eca4ad21`. The declaration relocation is the only change after the initial static review. Patch applicability and whitespace checks pass; the root owns all builds and target execution.

All existing source/type, exact-call, public-prefix, graph, ownership, layout, constructor, host and mutation guards remain unchanged for admitted workers. Refusal returns to the existing selected fallback. Native-source public-root policy remains unchanged. Source names, emitted comments, benchmark identities and arbitrary instruction-count thresholds are not used by the compiler rule.

## Validation and process correction

Run the maintained **fast five canaries first**, including the complete generic row, before the broader feature screen or another long comparison. The prior feature-focused screen omitted this already maintained canary; the long run caught a regression that a cheap default screen should have rejected. Keep that failure as evidence and change the order of validation.

First verify that the generic-row helper and complete module recover their prior forms, while large recursive workers remain selected. Then check recursive self and mutual components, acyclic contextual specialization, and acyclic callees inside recursive roots. Activation controls for formerly admitted acyclic public roots must reflect the new conservative policy without dropping their value, mutation or ABI observations. Continue with the key lexer/Map/record/ray gains, all representative points, maintained semantic suites and final selected-image qualification. No speed recovery is claimed before those results exist.
