# Phase114: local QBE regions and bounded compiler acquisition

[Design](../../../../design/phase114/qbe-parity-and-staged-runtime.md) ·
[Report and measurements](../../../../implementation/phase114/README.md) ·
[Compiler documentation](../../../../docs/self_hosted/direct-qbe.md).

Source02 now qualifies the full hosted→N1→native self-emission→N2 chain:
**74,220,801 raw QBE bytes agree exactly**. N1 and N2 each pass focused19
(16 positive executions and 3 expected refusals); N2 also passes the original
45 one-shot conformance programs. The three-source request screen passes all
27 observations, with N1/N2 request ratios of **2.82490×/2.82713× upstream** and
request-plus-machine-build ratios of **1.35522×/1.35687×**.
[Exact native results](../../../../implementation/phase114/native-results.md) and
the [reporting-only selection](../../../../implementation/phase114/selection.json)
pin the source, API, runtime, images and receipts. Installed selection is unchanged.

The **5.386× upstream generated-program runtime** result belongs to the separately
measured source01 hosted products (44 timed points plus one zero-work control).
It is not a native-produced full45 runtime measurement. The historical Phase112
facts checkpoint and its approximately 2.07× request result remain a separate
campaign, without an isolated cross-campaign regression claim.

All compiler transformations in this directory are Bend. Python/JavaScript
wrappers compose authenticated source, transport requests, supervise existing
tools and retain measurements. They do not implement semantic lowering.

## Selected source

The runtime-measured recipe is `integration/recipes-v3/table-unwind-first.json`
(source01). The qualified native source adds a stack-bounded verifier traversal:
`integration/recipe-table-unwind-first-namespace01.json` (source02). Reproduce
source02 with `integration/prepare-v4.py`, acquire a checked API with the existing
Phase111 `check-api.py`, then authenticate source/API/runtime with
`integration/admit-v4.py`. The old v3 recipe and measured products remain frozen. Exact commands, dependencies and exports are in
[integration/README.md](integration/README.md). Required historical source,
Base/cache and runtime artifacts are pinned; missing artifacts must be rebuilt
through their existing recipes, not replaced with unverified substitutes.

| Component | Purpose |
|---|---|
| `scaling/` | Reuse original verification context and indexed product signatures; preserve final verification |
| `packing/` | Guarded immediate representation for ordinary unary constructors |
| `recursive/`, `recursive-general/` | Bounded local recursive descent/unwind with captured environments |
| `recursive-table/` | Multiple local continuation cases, structured unwind and selection order |
| `transport/` | Shared fixed frame/pop/get ABI rendering |
| `integration/` | Exact compositional source provenance and original fallbacks |

`runtime/` Take2, `packed-take/` and `complete-bridge/` remain recorded optional
experiments. Their limited gains did not justify inclusion. `scalar-operands/`,
float-lane and table-buffer are separate prototypes; they are not part of the
selected broad/native checkpoint.

## Iteration and qualification

Use `controls/prepare-jobs-v2.py` for ordinary checked-source cases and
`bench/prepare-hosted-v2.py` for the frozen eight-program screen. Execute the
prepared commands serially under the existing Phase111 CPU3/memory/file guard.
The original Phase112 45-program benchmark retains its sources, expected output,
repetition profile and timing method. Broad results are summarized by
`plot-results.py`; it authenticates all 405 complete observations before writing
CSV/SVG/JSON and does not execute target programs.

Full native qualification uses `evidence/native-plan.py`, followed by the
existing source/build/focused19/self-emission/exact-QBE/N2-full45 gates. The
optional N1/N2/upstream request screen measures compiler requests separately
from generated-program runtime. The completed plan is
`selfhost/build/phase114/native-final02-with-transport-plan.json`; its existing
output paths are evidence, not fresh replay destinations. See
[evidence/NATIVE.md](evidence/NATIVE.md) for fresh qualification preparation and
a guarded N2 cache-mode compile/build/execute command using
`phase111/p114-native-final02-self/build/program` and
`phase113/runtime-products-build01/runtime.o` under `selfhost/build/`.
Do not infer native qualification from the hosted benchmark or from source
checking alone.

After target work and report edits stop, `evidence/seal.py` captures exact
receipts and bounded logs through the unchanged prior evidence gate. Machine
products are identity-only in that capsule; their hashes do not authorize
deletion. Separately verified lossless archives retain actual bytes for any
superseded intermediates reclaimed to manage disk space.
