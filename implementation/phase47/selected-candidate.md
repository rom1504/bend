# Array06 selection gates

Array06 is selected and installed. The checked build, focused strict gate,
four independent Array control groups, eight maintained suites, five canaries
and final 45-point/669-sample runtime comparison pass. Release verification and
all 42 ordinary/relocated CLI checks pass against this exact installed image.
Both portable bundles pass all 45 reader checks; their separate replay screen
passes 27 fresh samples in 9.370488 seconds.

API: `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`.
Runtime: `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.
Both identities and the exact checked attempt are required.

The maintained change carries local Array<U32> backing storage through a closed
private helper graph, emits ordered writes and normalizes proved calls without
crossing the public ABI. The same contract composes with the existing scalar-tree
emitter. A separate canonical no-F32 proof narrows host checks while retaining
Math.floor, allocation hooks, dependency checks and the original fallback.

The source graph grows from 23,007 to 23,254 physical Bend lines: +247 (1.07%).
It has 19,175 code lines, 2,622 definitions, 87 types and 86 modules. The generated
23-library total grows 100,476 bytes (2.58%); twenty program bodies are unchanged
after removing the exact common runtime addition. Existing helpers remain beside
new private closures so refused inputs retain their old path. This is a measured
size tradeoff, not a simplification or line-count reduction claim.

The [compiler-cost comparison](compiler-cost-final.md) passes 27 independent
requests and records median increases of 1.21% for fold, 3.75% for edit distance
and 0.87% for lexer. Compilation and generated execution are separate measures.

The final [phase report](README.md) and [results](results.md) include the complete
corpus: equal-point time is 2.919418× TypeScript versus the freshly paired
worker23's 3.085148×; equal-source time is 3.995808× versus 4.169855×. The short
128-step fold remains 1.930× slower than worker23. The 405-line worker
inliner is deferred after insufficient aggregate removal; its source remains as
a patch. The proof-memo experiment is diagnostic only. Neither is installed.

Earlier array01–05 attempts retain only their own observed qualification. The
array04 full corpus exposed the missed tree path; array05 established the shared
tree fix; array06 adds the reviewed integer guard. Their timings are not pooled.

The [installed-release receipt](../../selfhost/tools/performance/phase47/evidence/installed-release.json)
binds installation, runtime, source, CLI and portable identities. The
[selected qualification](../../selfhost/tools/performance/phase47/evidence/selected-qualification.json)
records final gate evidence; 103 protected files remain unchanged. The
[portable guide](../../selfhost/tools/performance/phase47/README.md) provides
the 20/60/300/600 profiles and recommends core8 for private/Array backend changes.
The separate [archive receipt](../../selfhost/tools/performance/phase47/evidence/README.md)
verifies all 16,355 closed raw files and both publication parts. Archive membership
does not confer installation or qualification on other attempts.
