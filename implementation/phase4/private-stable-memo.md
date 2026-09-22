# Private immutable-term stability memo prototype

The new checked Phase4 H repeatedly asks the context-free `core_subst_stable` fact about the same immutable term objects. A counter-only experiment on the real 312-declaration compiler-core library saw 2,078,196 calls and 1,853,629 repeated identities (89.2%; 224,567 distinct objects). Counters and the WeakSet were reset after Base priming. Instrumentation adds no forcing or memoization; exact emitted output and observations matched. Its timings are not speedup evidence.

The separate prototype caches completed native Boolean results in a WeakMap. Six reviewed Bend-emitted worker definitions are required byte-for-byte. Five generated copies of three original non-tail call sites are tokenized and rewritten; tail calls are refused. Misses retain the original `call`/`force`, throws remain uncached, and there is no in-progress sentinel. Values must have the compiler's ordinary six-field KTerm shape, but that check is **not an immutability proof**: correctness depends on the existing text-only private transport, fresh encoding of host inputs and read-only decoded views. The cache is not valid for ordinary public mutable graph/function APIs; a retained test demonstrates stale results after an out-of-contract mutation. Weak keys and Boolean values avoid keeping otherwise-dead term graphs alive.

Three serial AB/BA rounds, fresh worker processes, identical host/runtime/Base and separately primed validated caches produced 24/24 exact observations and emitted-byte matches:

| Input | Private control request | Private memo request | Change |
| --- | ---: | ---: | ---: |
| Tree | 2.221 s | 2.189 s | 1.5% less |
| List sort | 3.709 s | 3.610 s | 2.7% less |
| Rejected bytes operations | 1.725 s | 1.739 s | 0.8% more |
| 312-declaration compiler core library | 29.000 s | 27.226 s | 6.1% less |

Core process wall was 30.155 versus 28.411 s. The large identity reuse rate therefore yields a modest measured gain. This is a compiler subset, not a full self-emission or TypeScript comparison. The experiment used completed checked stage2 while stage3 proof was still pending and is labeled accordingly. The canonical private package was not changed for this experiment.

The direct graph gate passes 3,787 assertions covering shared acyclic graphs, true/false, neutral/beta and noncanonical application forms, unknown tags, malformed fallback and repeated failure, and the mutable-graph counterexample. Depths 128/512/1024 explicitly return true in both implementations; matching two stack errors cannot count as success. This does not establish identical resource-failure thresholds or support raw cyclic IR. Early failed prototype/test attempts remain retained: wrong tokenizer scope, comparing private partial-function branding, and a supposed error value that the original runtime actually partially applies.

An independent review adds 35 typed-shape Unicode/error-order controls, four raw malformed controls, four shared-tail A→B→A→B book cases and eight repeated malformed-string throws; all match exactly. Its existing ABI wrapper compares decoded KChecked structures. Seven sequential source/import revisions across two reused API sessions add 14 exact observations: changed same-path source and dependencies produce fresh output, repeated invalid imported types keep the same diagnostic, and restored valid imports compile correctly.

Tools are under `selfhost/tools/performance/phase4/private-{stability-probe,stable-memo,stable-memo-test,stable-compare,stable-requests,stable-review}.mjs`. [private-stable-memo.json](private-stable-memo.json) archives the checked provenance, exact input/tool identities, counts, outcomes and timing report. Raw reports are retained under `selfhost/build/phase4/private/` and `private-stable-review/`. These are prototype findings; promotion requires an explicit package decision and broader gates.
