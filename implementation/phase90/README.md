# Phase90: native self-hosting — integration in progress

[Design](../../design/phase90/native-self-hosting.md).
The compiler written in Bend now completes its entire C emission in a native
executable. Its38,614,586 output bytes match both independent JS-hosted Bend
producers. Final runtime integration, a native successor and release installation
remain in progress; this is not yet the final native fixed-point claim.

## Current completed results

| Observation | Result |
|---|---:|
| Checked JS-hosted B1, full native compiler C request |109.399s|
| Genuine JS B2, same source and full C |48.662s|
| Own-backend optimized native diagnostic, same full C |163.217s|
| Native diagnostic peak RSS during that request |1.536GiB|
| Full optimized Clang build after dispatch repair |267.681s,3.885GiB peak|
| Live/cache Small, Map, Unicode, file-I/O exact-C gates |8/8|
| Fresh JS B2 own-source check and B2/B3 equality |Pass|

These are completed single observations, not a paired upstream speed campaign.
The native diagnostic is built from an explicitly recorded two-edit C derivative;
its self-request uses the original runtime. A native successor built from the
final Bend-emitted runtime and reproducing its own C is a separate required gate.
The installed JS release is still Phase82 and will be refreshed through actual
checked-source qualification. No manifest-only update has been performed.

## Main findings and changes

- [Stack-safe static images](static-image.md) and [whole-segment traversals](segment-traversals.md): tail loops and reversal replace linear-depth recursion. Controls include65,536 distinct words and65,536 segments.
- [Linear table construction](tables.md): five growing-prefix String builders now collect chunks and flatten once. All108 complete String observations match independent expectations in JS and native execution.
- [Indexed fork propagation](fork-closure.md): exact-name indexed lookup removes the late list-search stall. All46 complete-product controls pass in JS/native execution, preserving first-match, cycle and fuel behavior.
- [Final C formatting](formatting.md): one emitter change removes a character-by-character indentation pass whose sampled late window was85.82% GC. All45 complete CPU preprocessing comparisons pass against independent B2 C in165.891s.
- [Clang memory](clang-memory-localization.md): large shared dispatch tables expand into15,296 return sites. A noinline table accessor prevents explosive LLVM reference-graph growth. The original form exceeded10GiB; the diagnostic builds below4GiB. Small controls preserve live word registers, environment and stack behavior.
- [Native build and self-emission](native-build.md): optimized native06 passes eight request gates and emits the complete independently matching compiler C. The earlier O0 cdecl diagnostic and all resource failures remain recorded.

The runtime integration will preserve direct dispatch below4,096 entries and GPU
dispatch, and restore upstream's safe O0 attribute guard. The threshold is a
conservative boundary, not a measured universal crossover. Runtime/template/host
identities must move together; old receipts retain their original asset identity.

## Evidence and execution discipline

[Bootstrap lineage](bootstrap.md), [earlier own-backend gates](own-backend-gates.md),
[profiling](profiling.md), [cross-host equality](cross-host-c-equality.json),
and [native comparison methods](../../selfhost/tools/performance/phase90/native-comparison.md)
retain the precise producer, source and boundary of each result.
[Evidence01](evidence01.json), [evidence02](evidence02.json) and
[evidence03](evidence03.json) seal successive completed results, including failures.
[Evidence04](evidence04.json) seals784 additional files, including successful native06, its complete self-emission, all45 preprocessing comparisons and failed build/method attempts. Active new-runtime work is explicitly excluded.

Root alone runs compiler/native targets under bounded memory, CPU and deadline
supervision. The attempted parallel exception was rejected before target launch;
no overlapping performance measurement is claimed. The one10GiB Clang experiment
failed and was followed by diagnosis, not another cap increase.

[Reclamation notes](reclamation.md) and prune receipts record removal only of
byte-verified duplicates in committed capsules. [Prune08](prune08.json) recovers
275.9MB of obsolete Phase75 payloads with exact restoration identities. Current
images, release dependencies and unrelated Phase6/68 work remain preserved.
No PR comment has been posted.
