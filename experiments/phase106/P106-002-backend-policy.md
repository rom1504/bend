# P106-002: native backend construction versus evaluation cost

2026-10-18. Preregistered before target timing. See the
[design](../../design/phase106/native-ir-research-loop.md).

Use the same verified, directly constructed Bend IR with C and Cranelift
consumers. The search candidates are C O0/O2 and Cranelift none/speed/speed_and_size.
Use host ISA and PIC for both, one shared external C runner, fresh object and
executable construction, CPU3, serial guarded targets and three shuffled rounds.
Every executed entry result must match an independently computed expectation;
the repeated checksum alone is insufficient.

Freeze training on text scan/hash (200000,7;100 repetitions) and allocated list
fold (2048,17;200). Hold out tree reduction (11,23;100) and explicit closure
environment (100000,31;100). Tail recurrence (1000000,127;20) and 128 functions
(2000,29;50) are structural controls. Shared/borrowed field observation
(200000,37;50 each) is a mechanism ablation, never policy-selection data.

Select the minimum training sum of emission + compile + link + k runtime batches,
for k=1,10,100. A batch includes process startup and the stated repetitions;
k is not a function-call count. Emission is one observation per fixed artifact.
Inspect held-outs only after this selection rule. No selection by aggregate
results that include held-outs. All profiles must pass independent semantic
controls before timing. Retain C O2 as the production/default reference.

The per-result assertion is part of timed execution. Separate differential proof,
reference interpretation, first adapter/producer construction, dependency fetch,
guard startup and harness costs are accounted outside this projected target cost.
Record both reusable-tool and first-use economics; do not call the narrower sum
an observed complete autonomous research cycle. Search payback must specify its
included costs and cannot demonstrate recursive acceleration.

Falsifiers: no complete construction-plus-evaluation saving, held-out regression,
incorrect results, or costlier search than plausible reuse. A faster small-object
backend does not establish faster full-self compilation. Production lowering,
ownership/tail ABI and effects remain explicit missing integration work.

The shared-observation ablation holds owner lifetime, scalar computation and final
reference counts fixed. It can expose avoidable ownership operations under that
assumption. It is not a generic borrow analysis or a proof about Bend's runtime.

Results will be linked from the [report](../../implementation/phase106/README.md).

## Outcome and follow-up

The frozen three-round matrix completed. At k=1 CL size narrowly wins training
(0.965× C O2), and held-outs cost0.727×. At k=10/100 C O2 wins. A follow-up was
declared before running it: freeze that k=1 winner and compare two new sizes per
family in three shuffled rounds, including separate fresh one-shot processes.
It confirms short-check savings but falsifies a general repeated-batch policy:
new training sizes cost1.024× for build plus batch, held-outs0.767×. One-shot
component-cost estimates are0.476×/0.504×. No held-out results reselect the winner.
See [report/evidence](../../implementation/phase106/README.md) for all attempts,
setup costs, conditional payback, interpretation and missing integration work.
