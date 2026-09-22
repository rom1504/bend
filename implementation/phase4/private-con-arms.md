# Exact private Con-arm fusion: rejected pilot

The bounded experiment stops without promotion. All **69 focused semantic checks** and **8 timed compilation observations** pass, but the compiler-core improvement falls from 3.49% in the first pair to **0.061%** in reversed order. That is insufficient repeatable benefit for this additional transformation.

## Mechanism and controls

The disposable transform accepts only the exact generated shape `matcher1("Con",()=>fn(2,function(a){...}))`. It embeds that arm body inside the existing outer matcher worker, preserving `project`, lexical captures and nested argument scopes. An unexpected field count uses the original arm/application behavior. Bodies mentioning `this`, `arguments`, `eval` or `super` are refused. The original public runtime, compiler source and emitted program bytes are unchanged.

This can remove a selected arm closure, function record, empty bound array, bounce and one application transition. It does **not** remove a field-array copy: private exact application already borrows the immutable fields. The canonical image contains 192 eligible sites, including generated private-worker duplicates; the original H has 133. An instrumented original-allocation variant counted **315,755 selected arm executions** during one list-sort compilation, with identical output. Its times are diagnostic only.

The control is unchanged private image `75ebe9e0b3f1f103250621c77c1e455160f83f1479740f8f440c54a6d4dfa598`, derived from completed H `b33b38e3…`. Fresh copied hosts and separately checked Base caches avoid modifying the concurrently running control image. CPU 3, Node v24.18.0, 4 MiB stack and 3 GiB heap are identical between variants. Processes are fresh; the second round reverses variant order. Other physical cores remained active.

## Complete pilot observations

| Workload / pair | Control request | Candidate request | Reduction | Control process | Candidate process | Peak RSS, control/candidate |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| List / 1 | 3.709 s | 3.682 s | 0.73% | 4.829 s | 4.778 s | 384,912 / 391,564 KiB |
| List / 2, reversed | 3.733 s | 3.621 s | 3.00% | 4.817 s | 4.741 s | 384,720 / 391,064 KiB |
| Compiler core / 1 | 28.462 s | 27.469 s | 3.49% | 29.713 s | 28.588 s | 584,404 / 580,396 KiB |
| Compiler core / 2, reversed | 28.033 s | 28.016 s | 0.061% | 29.128 s | 29.131 s | 584,644 / 581,768 KiB |

All result records and emitted bytes match across both variants and rounds. Both emitted list programs were separately executed and printed `6\n` with no stderr. The core is the same real 312-declaration compiler subset used by earlier private experiments. Its output bytes match; this pilot does not claim a full compiler self-emission or faster execution of generated programs.

The predeclared stop condition rejects an absent or small, inconsistent core benefit. No third-round confirmation, combination with Boolean/stability experiments or full-source attempt is justified by these samples. Peak RSS has no material improvement; the list candidate is slightly higher.

## Semantic evidence and retained failure

Focused cases cover captured values, nested function argument scopes, higher-order results, partial/overapplication, short/long field arrays, projection exceptions before body effects, selected arm exceptions, unselected-arm sentinels, returned build-field order and 100,000 tail-recursive visits. The independent review is [recorded separately](private-con-arms-review.md).

The first test attempt compared raw `PrivateFunction` instances from different generated modules using `deepStrictEqual` after a malformed short-field arm returned a partial function and then overapplication threw. Both errors and traces agreed; module-specific class/function identities made that observation comparison invalid for the private data boundary. The original test and failure explanation are retained. The correction observes leftover function arity/bound/environment metadata and preserves the behavioral checks. The subsequent 68-check run passed; adding the unselected-arm sentinel produced the final 69-check pass.

A **separate full-source run of the unchanged canonical control** failed with `F is not defined`, revealing an outer-scope capture defect in the existing private call transform. This pilot neither causes nor repairs that defect. It remains selected-workload evidence only, and no private full-source correctness claim follows from it. Original consumed tool snapshots were captured before that transform was repaired; the pilot completed its unchanged-input gate before allowing the repair.

The reviewer found no semantic blocker in the actual 192 sites, but identified unsupported generic patterns: writes/redeclarations of parameter `a` and local `project`/`fn` shadows. The current frozen image contains none. The disposable transform does not reject all of those patterns; it is not a general reusable JavaScript rewrite. Any future revival must add fail-closed guards and counterexamples before accepting different generated syntax. Hostile proxies/accessor arrays remain outside the private transport contract.

## Preservation and reproduction

[Summary](private-con-arms-evidence/summary.json), [complete pilot](private-con-arms-evidence/con-arms-pilot/report.json.gz), [counter report](private-con-arms-evidence/con-arms-count/report.json.gz) and [archive manifest](private-con-arms-evidence/manifest.json) retain samples, configurations, identity records, consumed transform/helper versions, the original failure, all focused reports and the actual core fixture.

Tools are `selfhost/tools/performance/phase4/private-con-arms{,-test,-compare}.mjs`. The test takes `PRIVATE_IMAGE NEW_DIRECTORY`; the comparison takes `CONFIG NEW_DIRECTORY`. Use Node with the recorded resource flags and CPU affinity. `countOnly:true` instruments the original arm body and must not be interpreted as a timing variant.

Exact historical replay requires H `b33b38e3…` from the completed source proof and the archived **pre-fix** private helper files reconstructed in their original relative module layout in an isolated checkout. The comparison intentionally verifies that canonical image bytes equal specialization of that H. A newer fixed calling transform therefore cannot silently substitute for the old control. Large generated APIs, binaries and cache JSON are omitted; their identities, completed-proof inputs and regeneration prerequisites are recorded. No canonical source/runtime/tool was changed by this experiment.
