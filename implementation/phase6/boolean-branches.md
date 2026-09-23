# Explicit Boolean workers in the stability predicate

**The isolated candidate met the predeclared small-core pilot threshold in both orders.** Production Bend modules and the consolidated default are unchanged; this is not a source promotion or a whole-compiler speed result.

P6-002 tests whether removing branch closures from `core_subst_stable` and its list predicate helps the optimized B1 compiler. The first local-binding/match formulation failed checking: the pinned language requires a separate definition for this matching pattern. Its failed attempt and source remain intact. The [v1 patch](boolean-branches-candidate.patch) is the failed formulation;
[the checked v2 patch](boolean-branches-v2.patch) is the candidate measured below.
Its bytes match the archived v2 patch; apply only in a separate candidate checkout
(`git apply --directory=selfhost -p1 PATCH` from the repository root).
V2 uses five named Boolean helper workers with explicit laws. It introduces neither memoization nor a substitution shortcut.

The order is preserved: test `Var`; visit children; test `App`; inspect canonical name/id/quantity; check removed metadata and application shape. The list predicate checks the head before the tail. Each helper receives a computed Boolean first and already-bound data afterward. The baseline’s eager conjunction for canonical metadata remains unchanged. Public host API roots remain unchanged. The generated seven predicate/worker bodies use `if` and `run_jump`, with no `kc` calls or branch closures. Whether additional helper calls/argument arrays outweigh saved closures is a measurement question.

The genuine checked/equality workflow passed its 21 paired acceptance/phase controls (seven pre-existing exact diagnostic differences remain). The candidate derived API is `603086e8792030d2a3f044131bbb251c17747f06296ed6cc9157e01f2ef62cdc`; the control is the final validated equality API `e2b5463678a26558e8fea1d585782e0863f1046067949a374f0469080281b15a`.

The final direct gate passed **438 controls**, including an independent Boolean oracle for 400 generated finite KTerm data graphs, canonical/noncanonical application metadata, beta-redex refusal, unknown tags, malformed UTF-16 and list data, child-before-metadata/head-before-tail error order, successful depth-1024 terms and an actual successful 100,000-element list. Raw malformed JavaScript data controls record observed error behavior; they do not broaden the typed graph contract to arbitrary getters, proxies, mutation or cyclic graphs. The earlier control report/tool is preserved before strengthening successful-value assertions.

Untimed preparation separately checked both Base caches and required exact decoded-book equality. The candidate fully checked/emitted the same 60,909-byte core library through frozen final05 host/runtime/Base, producing the established exact output SHA `016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186`. This provides a real compiler-path correctness check; its wall time is not a speed result.

The prepared controlled pilot uses four fresh processes in control/candidate/candidate/control order, CPU2, 4 MiB Node stack, 4 GiB heap, 90 seconds per sample and an absolute 03:32 UTC deadline. Each emitted file must match the oracle and actual preflight bytes. Request time excludes import/provenance hashing/output writing; process wall and maximum RSS include these costs. Both opposite-order pairs must reduce **both request and process wall by at least 5%**. Partial/failed campaigns cannot meet the criterion. The unchanged maintained Phase5 measurement worker supplies observations; all consumed source/API/host/cache/tool inputs are verified before and afterward.

Preparation and controls are retained in `selfhost/build/phase6/boolean-branches/`; `pilot-ready.json` and `pilot-frozen-tools/` preserve the preregistration, source patch, actual tools and successful gate reports before timed execution. [Independent review](boolean-branches-review.md) approves only the bounded experiment. There is no source promotion, public-H performance claim or full-source speed estimate.

## Controlled pilot result

The campaign ran from **03:10:22.011 to 03:11:19.882 UTC** on 2026-09-23, after root and the other agents confirmed all intentional compiler/archive/hash jobs were closed. It used the frozen preparation without edits or retries. The wrapper exited zero, all four observations passed, and every emitted module exactly matched both the established `016a5ced…` oracle and the preflight bytes. All recorded inputs were unchanged.

| Order | Variant | Request ms | Process wall ms | Maximum RSS KiB |
|---:|---|---:|---:|---:|
| 1 | Control | 12,425.540 | 13,453.014 | 485,360 |
| 2 | Candidate | 11,590.482 | 12,604.835 | 484,812 |
| 3 | Candidate | 11,574.232 | 12,599.082 | 485,936 |
| 4 | Control | 12,336.741 | 13,373.585 | 485,456 |

Forward pair: **6.7205% less request time, 6.3048% less process wall**. Reverse pair: **6.1808% less request time, 5.7913% less process wall**. Both exceed the required 5% in both measures. Memory observations are essentially similar; no memory improvement is claimed.

This is two samples per variant on one 60,909-byte core-library compilation. It demonstrates a bounded benefit on that workload, not a full-source speedup, broad conformance proof, public-H performance gain, or causal percentage for the entire compiler. Broader semantic/backend checking and independent repeated full-source measurements remain prerequisites for any promotion. No repeat campaign was used to replace a failed threshold.

[Durable evidence](boolean-branches-evidence/manifest.json) preserves the failed first formulation, successful v2 source/build/derivation, generated helper bodies, both direct-control versions, frozen preparation/caches/tools, all four actual sample results and emitted modules, and exact consumed inputs. Historical absolute paths and original reports are not rewritten.

### 2026-09-23 wording qualification

The generated direct controls are finite KTerm **data** graphs, including arbitrary tags and noncanonical application metadata. They were not independently accepted by `check_book`; predicate agreement must not be called well-typed Bend-term coverage. The real core-library compilation is a separate fully checked gate. The earlier archived report remains unchanged as historical evidence.

## Actual-H correctness follow-up

The guarded component experiment fully checked and Bend-emitted the altered four-module core, then replaced **exactly seven definitions** (the two predicates and five new workers) in a disposable copy of proved public H `5043267732f5178b12d14708e7dc07e3aa1a71b9d1d5949ef279af23c4297edd`. Constructor metadata and global dependency guards passed. Frozen final05 host/runtime/Base and the same final equality B1 emitter were used. Production/default artifacts were unchanged.

**The original positional-H graph gate failed**, after 430 completed controls. The reused B1 test expected a child-error comparison for a malformed `BadList`. H instead returns an opaque runtime function of arity two; ordinary deep equality compares fresh function identities and rejects it. A separate observation confirmed even repeated calls to the *same baseline H* return different code identities. Baseline and candidate agree on the observed function type/arity/bound count and on the combined malformed-child/null-name TypeError; the malformed-list-only returned function code hashes differ. These observations are retained without claiming equivalence of the partial closures or repairing the failed gate. Deep/list controls later in that failed run did not execute. Malformed-host-data behavior remains a limitation to review independently.

**A separately named real-core output subgate passed.** It used the actual changed H capsule, genuinely checked its own Base cache, and fully checked/emitted the unchanged 60,909-byte core library. The result exactly matched SHA `016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186` and the actual preflight bytes. This confirms a real successful compiler path under the changed self-emitted workers; it does not override the failed malformed-data gate.

Both runs exited within the authorized 180-second total compiler budget: approximately 16.3 seconds for component emission/failed graph gate and 73.2 seconds for the separately authorized Base/core subgate. These are bounded correctness workflow costs, **not H performance measurements**. H already optimizes `kc` choices, whereas v2 introduces five helper calls, so the B1 improvement cannot be transferred to H. No whole-source fixed point, matched H timing or source promotion was performed.

The separate [H evidence archive](boolean-branches-h-evidence/manifest.json) preserves both report statuses, direct positional encoding, raw result types/arities/code hashes, generated capsule/metadata guards, actual checked core output and consumed identities. Original failed files and the prior B1 archive remain unchanged.
