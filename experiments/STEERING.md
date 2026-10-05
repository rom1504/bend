# Current compiler: Phase47 array06

Array06 is installed. Release verification, all 42 ordinary/relocated CLI checks
and portable replay pass. The [report](../implementation/phase47/README.md),
[results](../implementation/phase47/results.md),
[compiler costs](../implementation/phase47/compiler-cost-final.md),
[Array mechanism](../docs/self_hosted/private-array-regions.md) and
[portable guide](../selfhost/tools/performance/phase47/README.md) describe the
selected version. Preserve all 103 unrelated starting files and closed historical
evidence. No PR comment is authorized.

## Selected mechanisms and scope

The worker23 foundation retains typed first-order calls, private layouts, tail
loops, bounded native recursion and continuation fallback. Phase47 adds a closed
Array<U32> representation contract over scalar public boundaries and complete
helper graphs, with ordered writes and consistent call normalization. The same
contract now reaches the existing private scalar-tree emitter. The original Zero
branch, dependency checks and old fallback remain. Canonical no-F32 proof narrows
host checking while retaining Math.floor and allocation hooks. No program-name
recognizer or persistent mutable-host cache is involved.

Four fresh independent control groups and eight maintained semantic suites pass.
The 3,026-main / 196-broader frontend and 81-backend inventories remain historical
worker23 evidence, including shared failures. This is a checked B1 derivative,
not a new self-emitted fixed point. Native IO.args remains unfixed; no broad
native/GPU or independent proof-validity claim follows from the JS checks.

All 45 points / 23 sources / 669 fresh samples pass. Equal-point slowdown improves
3.08515× → 2.91942× TypeScript (1.05677× gain); equal-source improves 4.16985× →
3.99581×. Tree edit distance gains 1.85–1.86×, local pair 1.75×, and the large fold
reaches 0.956× TypeScript. The short fold regresses 1.93× (7.603 → 14.671µs).
Default tree-bitonic regresses 4.17%; its larger variation regresses 5.36% with
wider overlapping ranges. Their bodies are unchanged apart from the common
runtime addition; no specific JIT cause is proved. Sixteen medians improve and
29 regress; signs are not significance tests. This is a corpus-informed result,
not typical-program speed or universal parity.

Source grows 247 physical Bend lines to 23,254 (19,175 code lines, 2,622 definitions,
87 types, 86 modules). Libraries grow 2.58%. All 27 compiler-cost requests match
expected outputs, with median increases 1.21% fold / 3.75% editdist / 0.87% lexer.
The 405-line broad worker cleanup is deferred and preserved as a patch; it did
not remove the intended aggregates. The saved-JS proof memo's 6.64% one-input
result remains diagnostic, with no production cache or combined speed claim.

## Next experiments

Use the nominal 60-second core8 screen and explicit private-entry witnesses
before a full campaign. The five canaries alone missed the tree composition gap;
checking a marker's presence is insufficient. Preserve 20-second rejection
screens and distinct semantic, timing, profiling and publication jobs. Root owns
serial CPU3 execution with a 1GiB heap, 2GiB RSS and 4GiB available-memory floor;
agents work concurrently on independent source, review and data analysis.

Prioritize general public-entry profitability/contract amortization and private
ownership plus result materialization. Keep known calls and representation facts
composable across all selected private paths. A root-local host snapshot is
unsafe because a prior foreign initializer can replace hooks; optional runtime
fragments must preserve the early capture boundary through feature metadata.
Do not remove host checks based on a clean benchmark or cache mutable identities.
Shared helper emission and an observed aggregate-elimination consumer should
precede another broad inliner. [Remaining work](../implementation/phase47/remaining-work.md)
records limits and falsifiers.

Keep JS primary. The preserved [Phase46 JS/C study](../implementation/phase46/README.md)
shows allocation and curried-call/continuation transport must improve before
switching backend: our C lost to our JS on five of six batch workloads. LLVM and
assembly remain deferred. The upstream pin is 018751270e800bc222a93dad7f257083ee53a5f7.
