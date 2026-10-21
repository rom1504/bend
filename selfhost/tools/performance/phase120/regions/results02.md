# Numeric region02: activation and limits

Root's three-round screen passed all 27 complete-output observations. Against its
matched safe03 baseline, active-ray 256/2240 improves 1715→1423ms (0.8297×), while
raytrace is 1885→1883ms and recurrence 421→418ms. The recurrence QBE is byte-identical
to the local-lane arm, so its small timing difference is not evidence of new
transformation work. Full samples and exact source/product pins are in
[results02.json](results02.json).

The preceding operand-only and local-lane screens are independent matched screens,
not a paired lane-versus-region run. Their active-ray ratios are 0.9728× and0.8698×
against their respective baselines. Region02 does not establish a broad parity
result or attribute all of its improvement to call expansion.

Actual call expansion occurred: each ray QBE file has 3750 `p120nr_` references.
However, the intended intersection call remains. Region02 expands the four
scalar selector callees in nearest/nearest.t; both intersection calls survive.
The first intersection call precedes any new region site in emitted nearest
(line 1582 versus first site 0 binding 1667), so that first refusal is not the
four-site cap. Ordinary Boolean decoding uses `N111CtorId` constants, which the
region02 numeric operand predicate refuses. Original `p111v_value` admits these
only as known integer catalogue IDs; `p111q_value` renders the numeric index.
The separately frozen region03 tests that exact missing constant category.

Read-only native disassembly shows the resulting tradeoff. Counts below use the
same `machine.py`/objdump method and the active-ray products; they count complete
functions, including cold exits and alignment instructions, not dynamic work.

| Private function | Local lanes instructions | Region02 instructions | Local lanes / region02 calls | Local lanes / region02 conditional branches |
| --- | ---: | ---: | ---: | ---: |
| intersection |131|129|3 /3|5 /5|
| product nearest |421|553|10 /6|36 /64|
| nearest continuation |368|496|8 /4|36 /64|

Intersection's XMM movd/movq sites fall 25→24; the large improvement from the
safe03 baseline 49 already belongs to the earlier lane mechanism. Nearest's
stack-reference sites grow 113→150 and its continuation 93→124. Whole active-ray
QBE grows 1,931,806→2,025,339 bytes relative to local lanes (4.84%). Its static
float operand casts fall 1416→1129, but that count crosses expanded function
boundaries and does not explain runtime by itself.

This evidence supports testing actual intersection-region admission next, before
raising budgets or choosing a profitability threshold. Region03 changes only
constructor-ID operand admission. Preserve region02, its successful controls and
its unfavorable code growth; no benchmark-name rule or selected policy follows
from this screen. All inspection was offline; this agent ran no compiler or
native target.
