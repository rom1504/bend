# B1 primitive string equality: successful bounded pilot

A disposable one-function change to checked B1 reduces the real compiler-core request time by **35.58% and 35.13%** in two opposite-order pairs, with exact checked output. The 909 helper controls and all 12 timed positive/negative observations pass. This clears the preregistered 5% core gate; the complete frontend gate also preserves all 2,756 observations. The separate bounded full-source gate also emits exactly the original H bytes. The ordinary B1 API and all 59 Bend modules remain unchanged.

## Exact change and semantic boundary

The generated `$String$eq$` normally invokes `String.cmp`, which returns ownership-preserving reconstructed strings before equality discards them. The experiment changes only that body in an isolated API. Two primitive well-formed JavaScript strings return `a === b`; every other input executes the exact original body. Both the entire checked B1 SHA and original body SHA must match before transformation. Pinned upstream Base, compiler source and emitted-user-program runtime are not modified.

Well-formed scalar sequences have equal UTF-16 encodings exactly when the sequences are equal. The guard leaves malformed UTF-16 on the original path, including its original errors. Thirty values form 900 differential pairs: empty/equal/different strings, ASCII/non-ASCII, valid and invalid surrogate combinations, null/undefined/numbers/Booleans/plain objects and a boxed string. Nine long-prefix cases add coverage through 4,096 characters. Test-only exports observe the actual internal helper's result or exact exception name/message. One changed-whole-image refusal is tested; the full-image guard dominates the body guard, so this is not counted as a separate body-guard refusal.

The scope assumes ordinary unmodified builtins and the existing compiler data boundary. It does not claim equivalence for arbitrary injected proxies, getters, callbacks, mutated JavaScript prototypes or identical resource-exhaustion thresholds. No raw testing exports are in the measured API.

The original B1 is `0653f21e7e227bf7bf7e3ad777630da64d520534753900636a571ed57a43f810`; the experimental derivative is `e95e119847307aa215765fcbea63d3b9e4a2bba625f3d30a915f298eb6ed9821`. The latter is **not a newly checked bootstrap**. Its report binds the real checked seed, source and every recorded checked-build input without fabricating replacement bootstrap metadata.

## Complete selected observations

Fresh processes ran on CPU0 with Node v24.18.0, a 4 MiB stack, 3 GiB heap and 180-second child deadline. Root released competing compiler work before the timed pilot. The frozen host/Base/runtime and input identities match, and all consumed inputs are rechecked afterward. Independently validated API-specific Base caches were primed before measurement; both contain the identical decoded book SHA `3e540547…`. OS caches were not flushed. Preparation and priming are outside these rows.

| Case / pair | Control request ms | Candidate request ms | Control process ms | Candidate process ms | Control / candidate peak RSS KiB |
| --- | ---: | ---: | ---: | ---: | ---: |
| Core / 1 | 19,636.27 | 12,649.54 | 20,680.92 | 13,699.02 | 489,944 / 484,504 |
| Core / 2, reversed | 19,581.44 | 12,703.16 | 20,633.00 | 13,761.13 | 490,196 / 482,936 |
| List / 1 | 2,583.40 | 1,964.32 | 3,592.39 | 2,976.42 | 300,436 / 262,752 |
| List / 2, reversed | 2,598.45 | 1,965.61 | 3,623.96 | 2,974.69 | 300,096 / 264,420 |
| Checker rejection / 1 | 771.62 | 599.69 | 1,769.94 | 1,598.31 | 249,328 / 246,056 |
| Checker rejection / 2, reversed | 768.26 | 602.25 | 1,768.01 | 1,601.43 | 251,568 / 248,696 |

Every peer result object and actual emitted byte sequence matches. The 60,909-byte compiler-core library output is exactly 138,371 bytes, SHA `016a5ced…`; the list output also matches byte-for-byte. The retained bytes-operations fixture rejects in the same check phase with identical diagnostic and checked flag. This pilot compares compilation results, not generated-program execution speed.

The two-sample core means are 19.609→12.676 seconds for requests and 20.657→13.730 seconds for complete processes, reductions of 35.35% and 33.53%. Mean maximum RSS is 490,070→483,720 KiB. These two pairs establish a useful bounded result, not a confidence interval or whole-source prediction. The earlier profile's 16.58% comparison-helper share is neither a ceiling nor an explanation assigning every saved sample: the change also bypasses associated calls and ownership-result construction, and profile instrumentation differs from these runs.

## Recipe and gate status

[P4-024](../../experiments/phase4/P4-024-b1-string-equality.md) records the plan and stopping rule before execution. From the repository root:

```sh
node --stack-size=4096 --max-old-space-size=3072 \
  selfhost/tools/performance/phase4/analysis-b1-equality.mjs \
  selfhost/build/phase4/combined-checked/api.mjs NEW_PREPARATION
node --stack-size=4096 --max-old-space-size=3072 \
  selfhost/tools/performance/phase4/analysis-b1-equality-compare.mjs \
  NEW_PREPARATION/report.json NEW_PILOT 0
```

Reserve CPU0 before timing. The comparator automatically stops after the core pairs if either request gain is below 5%; only a survivor runs the small positive/negative controls. The supervisor retains failures and uses fresh child processes with file-backed output. Reproduction requires the exact checked source/API/host/Base identities, and does not refresh the reviewed hash for different sources.

The [selected archive](b1-native-equality-evidence/manifest.json) preserves 101 files in 783,413 compressed bytes, including the actual derived API, test-only controls, all process results, output bytes, consumed tools and validated caches. [Preparation](b1-native-equality-evidence/preparation.json) and [pilot](b1-native-equality-evidence/pilot.json) remain readable. Historical paths are not rewritten into a new bootstrap.

The later [full frontend gate and durable archive](b1-native-equality-frontend.md) and its [independent read-only audit](b1-native-equality-evidence/frontend-independent-review.json) preserve all 2,756 raw results and verdicts against final B1, including exact diagnostics. All 45 actual worker histories, replay prefixes, fixture/import hashes and candidate cache/provenance match. The 377 existing strict failures remain; this is behavior preservation, not full conformance. No compiler probes were rerun for the independent audit. The separate [complete-source gate and archive](b1-native-equality-full.md) also
pass: actual 1,143,517 output bytes equal both original checked fixed-point
stages, SHA `b33b38e3…`. Independent audit verified the candidate reconstruction,
original checked source/proofs, host/helper/runtime/Base identities and validated
candidate cache. Its single observation was 348.373 seconds process wall,
347.098 seconds request wall and 2,841,452 KiB peak RSS. This is output-preservation
evidence, not a paired whole-source speed claim or a new checked bootstrap.
