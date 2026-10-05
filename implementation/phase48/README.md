# Phase48: composable representations — final candidate qualification in progress

The installed baseline remains Phase47 array06 at
`ee54723f87db81cce64b9f762fdd116805068c8a`. Phase48 is not yet selected,
installed or released. The likely candidate is the frozen
`selfhost/build/phase48/source-combined-rnfa02`, combining composite result
boundaries (R), native String values (N), private finite-F32 literals (F), and
typed array effects (A). Final combined semantic gates, compiler costs and corpus
measurements remain pending; isolated passes are not combined-image passes.

The [initial design](../../design/phase48/composable-representations.md) was
committed and pushed as `bb9480c` before new target execution. Root integrates
and runs guarded jobs; workstream owners prepare source, controls and reviews.
The [composition receipt and source review](combined-rnfa-integration.md) identify
the exact frozen inputs and 14 changed files. Runtime fragments are unchanged.
[Mechanism explanation](../../docs/self_hosted/phase48-representations.md)
connects these source changes to their proof and representation boundaries.

## Preserved baseline and measurement boundaries

The original full baseline is **2.919418× equal-point / 3.995808× equal-source**
pinned TypeScript execution time, over 45 points / 23 source programs / 669
fresh samples. Those are historical context, not denominators for isolated
fresh screens. The maintained corpus informed development and is not an
untouched holdout or universal parity test. Six severe outliers have different
causes; isolated gains cannot be multiplied or averaged into a campaign result.

Baseline API is
`28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`;
runtime is
`880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.
Upstream remains `018751270e800bc222a93dad7f257083ee53a5f7`. Public descriptor
mutation, partial application, demand/errors, aliases and bounded-stack
contracts remain. No target migration or upstream repin is planned.

## Completed isolated outcomes

| Slice | Executed qualification | Fresh isolated screen / limit |
| --- | --- | --- |
| R: composite results | Checked composite01; 30 independent values, 6 boundary traces; maintained row.probe executes 1 fast / 0 fallback | Generic row 385.457→30.6253 μs, 12.586×; local pair neutral. Three-round row drift remains explicit. |
| N: String.append | Checked native01; 7 ordinary points, 1372 complete values, 18 boundaries; maintained Unicode executes 178/706 concats | Unicode16/64 gain 1.215×/1.520×; Morning executes zero and is neutral. |
| F: finite F32 literals | Checked float01; 22 bit-pattern controls, 408 scalar observations, 17 host/view boundaries; numeric executes 769/3073 specialized writes | Numeric1024 gains 1.081×; Numeric256 nearly neutral. Mandelbrot/Symreg emit identical baseline modules and do not activate this slice. |
| A: typed effects and literal handles | Arrays02: 115 values / 14 boundaries / 16 entry-refusals; literals02: 40 / 26 / 29; old U32 allocator mutation repair executes. Loop-qualified arrays03 literals: 96 / 41 / 47 pass. | Initial acyclic Evening literal entry regressed 34.91%; successor requires existing loop work and refuses those acyclic entries. No broad typed-array speed gain claimed. |

Canonical source identities and host guards remain part of each slice.
“Private” or fewer emitted constructor expressions does not guarantee zero
machine allocations. Public handles, final result shells, string storage,
arrays, generic fallbacks and some continuation state remain necessary.

Exact source/image identities, sample ranges, drift and limitations are in
[composite results](composite-results.md), [native values](native-values.md),
[private F32 literals](private-f32-literals.md),
[typed array effects](typed-array-effects.md), and
[loop-qualified literal handles](literal-array-handles.md).
The prior saved-output numeric experiment remains preserved as motivation;
its 1.180× large-point result is not the checked production screen and is not
pooled with it. Original fixture/parser and controller failures also remain.

## Excluded or deferred work

Higher-order H02 passes 26 complete oracles / 39 boundary observations with
six ordinary fixture entries. Its measured-corpus reach is weak: Morning needs
an unsupported matched recursive factory, while the existing closure points
already select the older specialized path. A fixture pass does not justify
406 lines of broad integration. See [function flow](higher-order.md).

Private aggregate V03 passes synthetic and source controls and actually removes
RLE tuple constructions. Its four-point screen is mixed and mostly flat or
slower; fewer shells carry wider scalar transport and continuation frames.
It is excluded from RNFA, along with the separate unmeasured flat-vector
alternative. See [aggregate transport](aggregate-transport.md).

The allocation-free raw-entry guard passes its audit, but gains only 1.039× at
128 steps, is adverse at 4096 (0.993×), and is nearly neutral at 8192 (1.002×).
It is deferred. Optimized-body-only host-footprint narrowing is rejected because
the original generic call/forcing path may observe the omitted hooks. No mutable
host permission is cached and no input-specific threshold is introduced.
See [entry outcome](entry-profitability.md).

## Combined acquisition failure: checkpoint remains unselected

The combined RNFA02 checked build passed, but its first maintained local-row
corpus acquisition failed with a Node 1 GiB heap OOM after 35.78 seconds.
The process reached approximately 1.19 GB RSS while system available memory
remained approximately 26.8 GB. This was a bounded compiler-process heap OOM,
not a system/session OOM; the campaign nevertheless includes a real OOM attempt.
The installed compiler remains unchanged. No combined corpus pass follows from
the successful build or the isolated component controls.

The array owner found an eager `Bool.and` native-predicate admission bug: it
normalizes an ordinary live argument as a type unconditionally. A `kc` admission
fence is being prepared. This is a suspected cause of the acquisition failure,
not a demonstrated diagnosis until a corrected combined candidate acquires and
passes its controls. The 20-second trace diagnostic produced no output because
emit-worker clears `BEND_*` environment variables; it provides no planner trace
or evidence of where the heap grew. Preserve the failed attempt and diagnostic.

## Final admission remains separate

The frozen RNFA composition retains selector precedence and original fallbacks;
two narrow F32 leaf audit admissions permit the already-proved array graph to
compose with finite literals. Preparation/source review establishes provenance,
not execution correctness. The combined image must independently pass actual
entry, mutation, shared-view demand, handle identity and maintained suites
before its cost/corpus evidence can support release selection.

Raw evidence remains under `selfhost/build/phase48`; consumed inputs and failed
attempts stay intact. Compiler source growth, generated-program execution,
compiler request cost and elapsed work will be reported separately. The initial
preservation audit found all 103 unrelated files unchanged and unstaged; final
closure must verify that again. No PR comment is authorized or posted.
