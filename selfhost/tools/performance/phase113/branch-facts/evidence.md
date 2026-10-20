# Structural evidence from the optional branch pass

**Rejected candidate:** branch24 later failed the complete local-pair output
check. These historical structural observations do not qualify its semantics or
runtime. Candidate31 adds explicit Boolean widening; consult the
[phase report](../../../../../implementation/phase113/README.md) for its separate
ordinary checks and remaining native acquisition limitation.

These are read-only counts of actual emitted QBE and native assembly. They are
not execution times or a controlled attribution of all composed features.
The scalar worker has the same remaining 15 low32 masks in both profiles; the
new reduction comes from removal of Boolean exhaustiveness failure paths.

| `$direct.mit` | ranges19 | branch24 |
|---|---:|---:|
| QBE function lines | 713 | 650 |
| Assembly body lines | 317 | 137 |
| Native `p111_rt_fail` call sites | 7 | 0 |
| Native branch instructions | 30 | 4 |
| Negative-offset `%rbp` references | 59 | 0 |
| 4294967295 constant occurrences | 15 | 15 |

Inputs:

- `selfhost/build/phase111/p113-ranges19-scalar-region-8192-emit/program.ssa`
- `selfhost/build/phase111/p113-ranges19-scalar-region-8192-build/program.s`
- `selfhost/build/phase111/p113-branch24-scalar-region-8192-emit/program.ssa`
- `selfhost/build/phase111/p113-branch24-scalar-region-8192-build/program.s`

The mechanism is visible in the assembly. A comparison creates 0/1. Generic
Bool matching then tests 1 followed by its complementary case; the compiler
previously kept a failure branch even though the value domain was exhausted.
Each such cold native call made many live values require register preservation.
Once the impossible calls disappear, the worker fits its hot state in registers.
This is a cross-layer effect: a semantic fact removes a call, which improves
register allocation far beyond the cost of the test itself.

The source24 product cell.f3 worker loses both of its failure call sites,
shrinking from 250 assembly lines in ranges19 to 194. Its row caller still calls
f3, and repeated guarded array access still has native fallback calls. It is not
appropriate to infer array speedup from the scalar result.

The checked audit at `selfhost/build/phase113/branch-audit24/after.txt` identifies
the remaining inlining boundary precisely: product f3 has 202 IR nodes, just 10
above the 192-node eligibility limit. Product cell has 168 nodes and row 275;
both retain the f3 call. Many counted nodes are hygienic copies/result snapshots,
which QBE later removes. A future cost policy should distinguish these from
real machine operations while retaining absolute IR-growth/stack limits.

Root owns the checked-source receipts, independent finite controls, actual
execution, timing, broad-suite qualification and any promotion decision.
