# P107-004 — native hosting of the identical IR optimization kernel

Status: supported on the exact IR kernel; ordinary full-compiler extrapolation withheld. 2026-10-18.

Hypothesis: some of the ~473ms spent optimizing the128-helper graph comes from
hosting this Bend optimizer as JavaScript. A native image of the exact same Bend
source can reduce the complete construction/optimization/emission request cost.
An algorithmic bottleneck may remain, so this is not a promise of a hosting win.

Prepare one source with `kernel/prepare.py`, compile it to a checked JS API and
a native executable with the existing installed compiler. Compare all8 IR
workloads, raw/pure/memory policies and JSON/QBE outputs. Require byte equality
before interpreting the paired costs. Use three alternating host-order rounds on
CPU3, subprocess timeouts and one resource guard. Include process startup/output;
report JS internal phase clocks separately. Do not subtract unmatched startup
samples to invent native optimizer-only timings.

Expected evidence: `selfhost/build/phase107/kernel-source01/`,
`kernel-measure01/report.json`, source/tool/acquisition receipts and method
snapshots. These are IR-constructor workloads, not parsing/checking of Bend
sources, a full compiler bootstrap or an upstream comparison. Native image
acquisition is a separate one-time cost; report its amortization explicitly.

Keep either result: exact product agreement plus a measured hosting win supports
using this kernel for expensive IR research; a loss points toward algorithmic
work and avoiding unnecessary host migration. No production default promotion.

Observed: `kernel-measure01` passes144 byte-identical comparisons across eight workloads, three policies, two formats and three alternating rounds. The128-helper pure JSON request takes median0.14685s native versus2.14944s JS; the memory policy takes0.25747s versus3.99610s. Native acquisition costs32.515s (5.657s Bend emission +26.858s Clang), separately recorded. A similar expensive pure request amortizes this at roughly17 requests; smaller work needs more repetitions. No new full compiler speed or bootstrap generation result.
