# Counts across matcher boundaries

The substitution pair is a credible next *experiment target*: `subst_node` and `subst_terms` produce **2,446,620 partial function records**, 18.22% of the generic runtime's partial records in one checked compiler-core request. This is an operation count, not an allocation-byte estimate, a removable fraction of execution time or evidence that a fused worker is correct. No semantic rewrite or production change was made.

The predeclared [P4-023 plan](../../experiments/phase4/P4-023-matcher-family-counts.md) tests the specific family proposed in [the next lowering design](../../design/phase4/next_compiler_lowering.md). The final residual profile's 28.16% exclusive `apply` share alone could not attribute that cost to this family. This diagnostic supplies that missing execution-frequency information without treating an instrumented run as a benchmark.

## Request counts

The instrumented request performs 67,779,248 generic `apply` invocations and creates 13,429,155 partial function records at the actual underapplication return. Private positional worker calls that bypass `apply` are not included in that denominator. The five selected families account for 6,069,513 generic invocations (8.95%) and 2,477,781 partial records (18.45%).

| Family | Entry executions | Tagged generic applications | Actual partial records |
| --- | ---: | ---: | ---: |
| `subst_node` | 469,262 | 1,877,048 | 938,524 |
| `subst_terms` | 988,679 | 4,004,871 | 1,508,096 |
| `ka_defs_except` | 244 | 974 | 243 |
| `tele_check` | 62,390 | 186,616 | 30,918 |
| `ka_args` | 2 | 4 | 0 |

An entry is the original root matcher execution or a selected positional/root-function body execution. Tagged applications additionally include selected arm applications and the failed Nil matcher followed by the Con matcher; they are deliberately **not** reported as additional source-function entries. For example, `subst_node` projects six fields into an eight-argument arm, then receives the identifier and replacement. Every observed entry creates two partial records. `subst_terms` has 519,417 Con fallback applications; its Nil and Con arm arities produce different staging shapes. The raw report preserves those incoming/bound/arity counts.

| Phase | Selected applications | Share of phase generic applications | Selected partial records | Share of phase partial records |
| --- | ---: | ---: | ---: | ---: |
| Checking from validated Base prefix | 3,000,791 | 13.72% | 1,201,406 | 25.66% |
| Selected annotation | 2,701,226 | 16.46% | 1,123,114 | 30.63% |
| JS layout validation | 107,013 | 2.96% | 44,604 | 6.00% |
| JS library emission | 260,483 | 5.48% | 108,657 | 11.63% |

The request totals exclude initial image setup, Base preparation, source discovery and the arithmetic/matcher counter control. Those phases remain separately visible in the raw evidence. Root function records created once during image initialization are retagged as entry functions; the syntactic `created:arm` counter in setup must not be mistaken for a per-call arm allocation. The tiny `ka_args` count says little about annotation's related cached/static helper paths, which were intentionally outside this five-name family.

## Exact scope and controls

The source image is the immutable private profile `4318bbcdb2040ad794387b1466b0bafbe12233e67983224c5a564d13fa5753a3`, derived from the completed final H proof and source `34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122`. Every original manifest artifact and both completed fixed-point outputs were verified. Instrumentation checks the complete image hash and eight exact emitted-body hashes before inserting counters. The diagnostic image is `c81bf6a1369530f07a72678ef1c1b6ef5b53352241fa9823d4f0954fbd5b131f`; it has no fabricated production manifest or bootstrap claim.

WeakMap tags identify only the five selected global definitions, their generated matcher/arm values and the three applicable positional workers. The existing generic underapplication return transfers a tag to its already-created partial record. Argument expressions, selected arms, projection order, force/build control flow, error branches and return values are unchanged. Additional allocations and counter work are diagnostic overhead; this is scoped to the private finite compiler-data boundary, not a general public-function equivalence proof.

The 60,909-byte core fixture, canonical Base, frozen runtime and host match P4-022. Its diagnostic-image-specific Base cache was absent initially and was built and validated before the request; cache construction counts are separate. The launcher used CPU3, Node 24.18.0, a 4 MiB stack, 3 GiB heap and a 90-second process-group deadline. It finished successfully at 19:10:41 UTC, without timeout or signal. The instrumented duration is deliberately not presented as compiler performance.

The internal arithmetic control verified exact/partial/matcher accounting. The actual request passed full checking and emitted the exact expected 138,371-byte library, SHA `016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186`. All consumed inputs, including the original image and generated validated cache, remained unchanged. Counts for underapplications equal counts of the actual partial-record return globally and within each recorded phase.

## Decision and replay

Prioritize a **substitution-only typed-worker differential prototype** if this direction is pursued. The small `ka_defs_except` and original `ka_args` contributions do not justify beginning there. The counts do not prove how many partial records a safe transformation can remove: evaluating the later identifier/replacement too early can change matcher exceptions or divergence, and App rebuilding must preserve beta reduction. The existing proposal's already-computed-argument restriction, staged demand controls, dependent-type cases, captured environments and deep-stack gates still apply before any timing or adoption.

No further compiler run or semantic transformation was authorized by this count result. The [evidence manifest](matcher-family-evidence/manifest.json) retains the exact instrumented image, guarded original/modified bodies, executed tool/config, complete raw counts, reduced tables, launch evidence and exact output. The original private image is also preserved in the existing private-image capsule.

From `selfhost`, run `node tools/performance/phase4/matcher-family-counts.mjs CONFIG NEW_DIRECTORY` with the retained configuration and original artifact paths restored. The launcher enforces CPU3 and the resource/deadline settings. Then run `node tools/performance/phase4/matcher-family-summary.mjs REPORT NEW_OUTPUT` to reproduce the tables. A different source image is intentionally rejected rather than silently instrumented with stale body assumptions.
