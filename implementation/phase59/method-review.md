# Phase59 independent method review

Static review passed for the first-window method and the separate stage/counter producers below. The reviewer read source and saved provenance only; no compiler or workload was executed by this review. Runtime results remain separate evidence.

The question is the selected B2's lexer import + API load + first ordinary library request, previously 1,499.595 ms versus TypeScript's 571.887 ms (2.622×). Prepared disk caches are part of this protocol. Later requests measure a different interval.

## First-window method

Reviewed [method01](../../selfhost/build/phase59/latency-method01/derivation.json):

| File | SHA-256 |
| --- | --- |
| `run.py` | `6f115dd34ebba3e3ea1984819878d726de933c3e46e28ba989f1d10494da5717` |
| `worker.mjs` | `5a1bff2254d1aeec69268a38f03542ef49148c54976cad8ede865966a7d5d20e` |
| `profile.mjs` | `58748e46cc15960e36b0ccd922a167bcb7bbf7f64dd5db09cc82a5237ca1c254` |
| `setup.mjs` | `5641ba8e71cb64a9c56add28186db4810c6812784bb3987e9b84bd3da46df78a` |
| `derivation.json` | `e51147cbe628dbb727d6bb160ac299a4eed38db4b4a1fcad32d502fad5c7c7ff` |

Sample preflight verifies saved identities, private copies, prepared outputs and caches. It does not invoke setup or import the compiler. CPU/allocation capture then encloses actual compiler import, ordinary `D.loadApi`, and exactly one compilation. The helper enforces one request; diagnostic warm requests are zero. Complete output-byte comparison, hashing, file writes and summary serialization occur after inspector stop. Clean runs retain separate import/API/first clocks and three later requests. Preparation uses the full catalog value oracle.

The image is the genuine selected last01 B2 `a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081`, from source `85454aab7a6ef25d1e78970b1c24d68ac2a90a23a4b39b64a30de311c2fc5091`; no checked-attempt metadata is invented for it. Mutable caches and copies reside in Phase59. Existing CPU3, heap and process-tree resource guards remain in force.

Interpretation limits: inspector setup and instrumentation perturb execution; diagnostic wall times do not replace clean ratios. Excluded provenance reads can warm filesystem pages and affect initial garbage state. Three rounds with two roles provide cyclic rotation, not perfect position balance. Allocation is sampled cumulative allocation, not retained memory; nested inclusive CPU frames must not be summed. A refused timestamp weighting remains a sample-count view.

## Stage instrumentation

Reviewed [clock.mjs](../../selfhost/tools/performance/phase59/stages/clock.mjs) (`d606d5c9ef43e3afbc60d60ca31bbb5972daf1831c63aee5d4e058822c2f2c37`) and [derive-driver.py](../../selfhost/tools/performance/phase59/stages/derive-driver.py) (`4546095f9f223406e00cdb9d3057c926247398fd5ce804446ab6f2dee2ee59cc`).

The exact driver anchors preserve original statements and returns. Function `try/finally` scopes retain lexical captures, and statement clocks introduce no additional block scope. Labels distinguish source header/completion, combined ABI2 checking/completion, source reach, annotation, emitted reach, layout proof and emission. Uninstrumented driver work remains in the enclosing exclusive interval. The monotonic stack partitions wall time; successful observations must reject incomplete child intervals. All intervals include clock overhead. Instrumented worker admission and output comparison require their own review.

## Source-work counters

Reviewed [derive-v1.mjs](../../selfhost/tools/performance/phase59/counters/derive-v1.mjs), SHA-256 `4af5047c51dc9eb970e785f482a3dcefdd8f923193969b8f9b60718e9804ae60`.

Fixed-PC SCC mapping, parameter positions, and selected branch outcomes match the actual B2 and corresponding Bend helper bodies. The primitive table contains 90 rows. The producer preserves every original byte under exact inversion and leaves the runtime prefix unchanged. Counters record source-level entries, suffix steps, comparisons and branch outcomes; they do not establish physical object allocations. Added reads and counter operations are diagnostic overhead.

## Instrumented worker follow-up

Static review also passed for [stage-method01](../../selfhost/build/phase59/stage-method01/derivation.json): runner `ec1a225343e704b5ef713682527a44ad723f0891d429ff4532e14ced55391cc7`, worker `1d02dd8e7e7e967ae0fb1aa733eccd48711cebec565b9a5ba795cdc5b3db8bca`, and derivation `f5883c45ddfbc150c0efb074b0840c1177af98aa5e9fc7f76eec03550604ca3b`. The worker binds the insertion-only sibling driver to the prepared original, retains the actual API and cache, records three root intervals, rejects incomplete children, and compares the full prepared output after clocks close. There is one ordinary request and no inspector session.

The [counter worker](../../selfhost/tools/performance/phase59/counters/worker-v1.mjs), `90e6fe1f61003e303c04de567a57ddcbedfff1455bea7fcffd3e150a9f63c801`, also passed static review. Preparation uses the diagnostic image's own private cache and makes no workload request. A fresh sample loads the ordinary API, resets counters, executes exactly one ordinary request, and requires the complete prepared module bytes and source/Base/runtime file set. Cache files and consumed identities are rechecked. These counters cover the request after API load, not the combined import/API/request window; the report states that distinction.

The counter [serial runner](../../selfhost/tools/performance/phase59/counters/run-v1.py), `d3f52588a6ead668e7c411f9e994206bfeea18cce186c399dc8a2439ba82ae6c`, passed the subsequent review: three guarded processes, 120-second child limits within 300 seconds total, reviewed worker/derivation pins, and exact preparation/lexer/Evening request counts of 0/1/1. Failure receipts remain available.

## Saved-data analysis

Static review passed for [summarize.py](../../selfhost/tools/performance/phase59/summarize.py), `421619b7c26e7db8c4bc4e2b9a104deadc24dc41b77af81453cad6bda5a1ac8b`, against actual completed worker/profile receipt shapes. Clean component sums and medians are recomputed with prepared-output and catalog-value joins. The frozen CPU accounting function retains the original refused weighted capture as counts and keeps the independent TypeScript retry separate. Comparative CPU charts use sample counts for every capture; allocation shares use sampled bytes. Neither view is a clean timing ratio, and no repeats are pooled across campaigns. This clearance is for data-only analysis, not an independent execution of the measurement jobs.

## Publication helpers

Static review passed for [preservation-v1.py](../../selfhost/tools/performance/phase59/publication/preservation-v1.py), `c41306b84b9d3c3ce4f25077de5f901521a906351a8510014e64216725a4e728`, and [publish-parts-v1.py](../../selfhost/tools/performance/phase59/publication/publish-parts-v1.py), `8efe53aff9bd90850a29cdab8a5a4b323174773d3275dce9fdbc77c751dc87cb`. Actual publication, source-accounting, start-inventory and inherited archive schemas match their reads. The audit checks Phase58's exact file set, seven installed files, protected 103 files and staging, and selected live source/runtime/driver identities. The publisher verifies the inherited capsule identity; at or above 100,000,000 bytes it writes ordered parts and checks their streamed concatenation against the original capsule. This review neither executed the preservation audit nor qualified an archive that does not yet exist.

## Completed evidence readback

The bounded factual review checked [measurements.md](measurements.md) against analysis `0a9392a4ebc8e6ba04f87a695c62dcac9def56bfa7392665310d7e5e7195e514`, the selected raw summaries, and all four exact SVG copies. The clean combined ratios are 2.603520× for lexer and 2.399924× for Evening. First/later medians, count-view CPU shares, retained timestamp refusal/retry, and allocation totals agree with the receipts. [Counter findings](counter-findings.md) match both counter reports and preserve their narrower request-only scope.

The first stage summarizer contained `dict(pass=True)`, a Python syntax error that this reviewer initially missed. The failed producer is preserved. The reviewed [v2 successor](../../selfhost/tools/performance/phase59/stages/summarize-v2.py), `553956ce7ffad30ddb819ad3bc9e8c2f527f65dcaf72c548d28e8a840a870a8c`, changes exactly that reserved-keyword use and passes AST parsing. The completed stage analysis `ec046a8fc893e091805461e2f5c15cdbf9984bda6b1e884a35b529b4cef536da` and [stage report](stages.md) preserve additive exclusive means, separate medians, and unequal pipeline boundaries. Cache/identity means are 201.249900 ms for lexer and 188.888483 ms for Evening; newly loaded source span validation belongs to source loading.

Independent addition of saved child execution receipts gives 38 target processes, 180.155374 seconds of process wall time, and maximum observed process-tree RSS of 622.550781 MiB. This is a readback of root-run jobs, not reviewer execution. The final report's optimization ranking remains a proposal: neither string flattening nor an optimization speedup was established here.
