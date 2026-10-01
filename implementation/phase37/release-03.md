# Phase37 installed compiler

**Checked03 is installed and verified. All 42 ordinary/relocated CLI checks and
all 15 post-install audit groups pass.** The final audit matches 227 canonical
source files. Fifteen inherited Phase35 owner groups, seven inherited Phase36
groups and three new Phase37 groups close separately on this same API.

| Artifact | SHA256 |
| --- | --- |
| Installed API | `ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1` |
| Genuine checked parent | `8385543ac7c9aa39505b0f4ee056f5b1330dd5f549d11357029400a303e60b24` |
| Assembled Bend source | `6b97ede24fd9e57101ac6f372bcae3e78a82aebb6e9cb5903d53ff0b44983201` |
| Embedded runtime | `51bb6046a8ac116865e2b1ed94b5587d1257f951aed536da77da3e91338eac49` |
| Base | `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` |

The upstream pin remains `018751270e800bc222a93dad7f257083ee53a5f7`. The
[installation record](release-installation.json) verifies six installed files,
126 checkout files, checked lineage and final receipts. Ordinary compilation
executes the Bend implementation without a TypeScript fallback. This is a checked
B1 derivative, not a new self-emitted fixed point. The previous Phase36 release
is preserved in
`selfhost/dist/release-history/93e55ad7ee456eebb5fa3dd9606c2cf262ea386c6f66bfd891ffe187d8f50a75/`.

## Result and admitted costs

The [45-point execution comparison](execution/report.md) retains 669 samples
from 23 sources. Numeric recurrence improves **2.674×/5.165×**, and tree sorting
improves **1.165–1.270×**, relative to fresh same-run Phase36 output. All five
target points improve in every paired round with disjoint observed ranges.

Four points have disjoint slower ranges: symbolic regression **+1.63%**, the
smaller lexer variant **+1.78%**, active ray 256 **+3.58%**, and list 512
**+4.65%**. Several held-out points also slow consistently within paired rounds.
Those costs are retained, not dismissed by overlapping overall ranges.
Normal checked-request medians rise **2.47% local row / 6.40% tree / 1.06%
numeric**; source grows **184 Bend lines** to 18,358 in 70 modules. The
[admission decision](performance-admission.md) explicitly accepts this tradeoff.
There is no overall-speed, TypeScript-parity or simplification claim.

## Correctness and release closure

Fresh candidate execution matches all **3,026 main + 196 broader frontend
observations** against identity-verified retained references. Main outcomes
remain 2,525 pass / 497 observed / four shared failures; broader remains 195
pass / one observed. The backend pilot matches all 81 retained outcomes:
69 pass / eight not applicable / four shared failures. Exact agreement does
not turn shared failures into fixture passes. Inherited primitive, worker,
library, component and HVM gates pass; see the [gate table](final-conformance/gates.md).

The [new owner closure](optimizer/final-scope-owner-report.md) verifies finite
selectors, exact native conversion and DataView observability on actual checked
emissions. The first inherited-owner audit failed on historical catalog path
resolution after all seven controls had passed. Its
[reviewed successor](inherited-owner-audit-repair.md) preserves all 43 original
assertions and closes seven groups against 678 file identities and 15 pinned
Git blobs. The original failed audit remains evidence.

Installation, verification and the [42 CLI checks](release-cli.json) complete
successfully. They include JavaScript/native CPU execution and a relocated
compiler without an upstream checkout. Full backend/GPU coverage and independent
proof validity remain unestablished; `--verdict` remains unsupported.

## Reproduction

Use the [Phase37 benchmark guide](../../selfhost/tools/performance/phase37/README.md)
with explicit catalog, selected cases and 20/60/300/600-second execution ceilings.
The full suite takes 17.61 minutes across four bounded runs. Build and source
acquisition are separate; the final checked build plus 36 focused probes took
42.175 seconds. All 24 separate CPU/allocation captures pass in 34.345 seconds.

The [evidence capsule](evidence/README.md) preserves source snapshots, generated
modules, controls, timing samples, profiles, failed attempts and closure logs.
Root ran heavy jobs serially on CPU3 with a 1 GiB heap allowance, 2 GiB process
tree ceiling and 2 GiB available-memory floor. See the [phase index](README.md)
for the protected-file and publication records.
