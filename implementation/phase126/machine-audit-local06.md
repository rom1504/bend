# Local float cleanup versus typed ABI

The [local06 static comparison](../../selfhost/tools/performance/phase126/machine/local06/comparison.json)
pins both actual active-ray binaries. Root's local06 ablation disables the typed
parameter plans while retaining the same local operand, lane, branch and op25
projections. No target was run by this audit; objdump counts include padding.

| Worker body | Typed05 / local06 instructions | GPR/XMM moves | XMM-register moves | Frame references |
| --- | --- | --- | --- | --- |
| intersection | 117 / 111 | 3 / 11 | 25 / 5 | 4 / 7 |
| product nearest | 381 / 410 | 16 / 4 | 24 / 0 | 62 / 104 |
| nearest.t | 361 / 369 | 16 / 4 | 14 / 0 | 42 / 89 |
| product trace | 692 / 698 | 63 / 69 | 32 / 10 | 121 / 116 |
| pixel | 527 / 562 | 49 / 57 | 31 / 7 | 151 / 149 |

Typed ABI changes the movement categories rather than uniformly removing them.
Intersection's floating parameter assignment requires many XMM-register
permutations; the local word ABI uses more GPR/XMM transfers but fewer total
instructions in that body. Nearest's typed version has fewer frame references,
while product trace and pixel have slightly more. Typed word adapters add their
own call and conversions when entered by a legacy caller; those bodies are
listed separately in the evidence and not included in this table.

Root's initial ablation favors local06 on active ray, while independently paired
reruns are needed to assess noise. The demonstrated category is therefore local
scratch/operand/lane cleanup; a benefit from typed call boundaries is unproven.
Fewer conversions in one callee is insufficient to choose an ABI for the whole
call region.

A subsequent numeric experiment could inline a bounded eligible scalar leaf
into its caller after the local representation cleanup, keeping the same ordered
arithmetic and ownership exclusions. This would remove the mixed calling
boundary itself. It is different from the earlier Phase120 untyped expansion,
which retained scratch/word transports and increased pressure. It still needs a
size/profitability gate and must be compared against the simpler local06 winner.

The separate ordinary-ray opportunity is now more concrete: a scalar shift
conditional between a capture frame and recursive descent causes the existing
local-resume planner to refuse colf. The narrow source prototype and proof are
in [scalar-resume/audit.md](../../selfhost/tools/performance/phase126/scalar-resume/audit.md).
