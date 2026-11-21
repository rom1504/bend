# First policy: large fold gain, unacceptable edit regression

Reject the combined admission-plus-reservation policy as a general change.
Its two balanced four-round sessions reproduce a19.8% local-fold improvement
and19.1% improvement on the held-out8192/123 input, but editdist is15.3% slower.
Mandelbrot improves2.7%; it is a changed object, not an unchanged noise control.
The four-case geometric improvement7.6% does not cancel the edit regression or
establish broad benefit. [Complete ratios and dispersion](runtime-summary01.md).

Actual emitted ELF explains the tradeoff. Fold's complete iteration shrinks
18→16 instructions, with no frame operands, and fuel decrements directly in its
loop-carried home. Edit's fuel and index successors become resident, but the
constant character and array temporaries lose homes. Its body remains55
instructions while frame operands rise12→13. Both minimum sequences inherited
from Phase197 remain active. [Pinned machine evidence](emission-evidence01/report.json).

The static four-object census additionally finds expanded frame usage in some
fallback versions and in edit's generation/batch workers. It compares against
both the Phase197 incumbent and qualified Phase195; only the former isolates
this policy. It is not a profile and says nothing about un-emitted workload
families. [Census](object-census01.json).

Correctness observations pass: independent upstream source checking;28
structural controls; eight generated machine functions with802 independent C
function comparisons per object/assembly route; all four ordinary catalog
value/count oracles; and14 additional whole-program input comparisons against
retained mature C. Additional inputs cover zero fuel, lengths1,2,127,128,129,257
and8192, and high U32 seeds. The control driver runs identical machine programs
for its two structural groups; the duplicate runs add no coverage. Finite
controls are not an end-to-end correctness theorem.

Recorded guarded costs: capture21.16s, API acquisition16.94s, controls27.59s,
four-program emission41.64s, linking/catalog checks4.60s, additional C
comparisons0.27s, and the two runtime sessions16.69s/15.77s. Shared frontend work
is included in emission; cold compiler-throughput impact is not measured.
No maintained compiler file, installed artifact or commit changed.

The second general policy keeps the original32-name candidate membership and
priorities, reserving only a legal recurrence pair already present in that pool.
Its source is `paired-v3.bend` plus `hook-v3.bend`; the only replacement is
`x190_j_graphed`. It still uses one allocation and the existing independent graph
validator. A zero-affinity fast path avoids scanning unrelated future names.
`recipe-v3.json` and `source-freeze03.json` pin this prepared, initially unchecked
variant. It should leave edit's hot row unchanged; retention of the fold gain
requires fresh emitted machines and timings. This is a follow-up hypothesis,
not a promotion decision.
