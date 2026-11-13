# Phase191: remove machine transport before increasing allocator complexity

Parent: Phase190/e4cdffa, installed selection unchanged. Eight frozen tuning
cases and37held-out cases; one CPU3 target lane. Design: ../../design/phase191/README.md.

## Hypotheses and falsifiers

| Hypothesis | Expected work removed | Cheap falsifier | Current observation |
|---|---|---|---|
| Loop-aware register priority | Repeated frame loads while exit-only values occupy homes | Correctness controls; actual address chain still spills; paired runtime | Alone1.64%less geometric runtime on8cases. Combined placement makes the key row address chain register-resident. |
| Indexed addresses and memory ALU | Temporary pointer construction, register moves, spills | Exact byte/runtime controls; no selected indexed accesses; unchanged runtime | Alone12.30%less on8cases, combined14.38%less; local-pair47.57%less, editdist33.24%less. |
| Pure conditional selection | Boolean-result branch diamonds and empty branches | Exact actual checked shapes absent; CMOV controls fail; runtime regression | Source check and74 extra controls pass; runtime measurement pending. |
| Adjacent private-frame forwarding | Immediate store/load transport with identical address and width | An intervening item or width mismatch must refuse; no actual removals or runtime win |21 controls and576 independentC observations per route pass; runtime measurement pending. |

Initial ablation: selfhost/build/phase191/ablation-summary01.json,200 timed and
123pilot observations. All8 products pass exact independent outputs. Two
runtime dispersion flags remain visible. These are development results, not
all45 coverage or parity. C geometric ratio on this deliberately hard subset
is4.172→3.572; do not substitute it for Phase190's44-case3.084 ratio.

## Negative and methodological evidence

Early source checks caught declaration ordering, illegal computed/local matches,
affine binder duplication, one missing type annotation and a fixture delimiter.
All failed snapshots/diagnostics remain retained. No failing version reached a
selected compiler. One timed-development preparation was invalidated by a live
compiler-manifest dependency: explicit immutable toolchain manifests now bind
all acquisitions. A wrong runtime-manifest filename failed immediately and was
corrected in a fresh run. No receipt was edited to manufacture a pass.

The checked diagnostic row dump is useful source-level context but replays a
historical pipeline helper. Exact current machine instructions and independent
runtime products are the authority for claims about final selected code.
Static frame-reference/transition counts do not establish cache misses, memory
latency, dynamic frequency, or speedups.

## Controlled follow-up

The second eight-case screen records candidate/baseline0.757261 (24.27%less
runtime), with local-pair0.3323 and editdist0.3719. Numeric recurrence regresses
8.25% despite unchanged normalized instructions in both its hot recurrence and
its repetition wrapper. This remains a real measured regression.

The three-case seven-role ablation independently retains frame-only,
select-only, combined and16-byte body-alignment products. Numeric times relative
to the address/priority candidate are1.0255,1.0228,1.0787,1.1075 respectively;
local-pair1.0543,0.7016,0.6376,0.6344; Map0.9781,1.0000,0.9825,1.0000.
The alignment variant fails to repair the regression and is rejected. Its
source09/API/products remain preserved; no alignment code remains selected.
This does not prove a cache/front-end cause: absolute layout moved while the
inspected hot instructions stayed equal. Do not retune offsets to one case.

The physical profiler confirms>98%of local-pair samples in the inspected loop.
Map costs are distributed; the insertion worker accounts for only3.5–4.6%.
Removing199static frame loads there cannot justify a whole-program large-gain
claim. The next bounded general experiment examines ABI argument snapshots,
which use RSP rather than the RBP references counted by the earlier audit.

## Rejected call transport and final candidate freeze

A bounded parallel-move scheduler removed all 1,071 recognized call snapshot
sites and 7,036 static RSP references across the eight development programs.
The four-role, four-round `call-runtime01` screen measured only about 0.56%
additional geometric improvement over the selected bundle, with mixed individual
results. The algorithm passed focused independent controls, but it was removed
from production: static instruction removal alone did not justify the added
complexity. Preserve `call-moves-experimental.bend`, its integration patch,
`call-controls01`, `call-summary01`, and the exact machine audits for reuse.

The frozen complete candidate is `selected-source01/compiler.bend`, SHA-256
`d9cc1516c1b7d51f2e7f220228ee07477a98f253dbe1cff78652a38782740ce2`.
It contains the address/ALU, loop priority, conditional selection and adjacent
frame-forwarding changes, with no alignment or call-move experiment. Independent
upstream source checking and native N1 all45 outputs pass. Eight development
objects and their linked text/data/rodata sections match the checked hosted
products. Broad runtime and native reproduction are separate final gates,
recorded in the implementation report rather than inferred from these passes.
