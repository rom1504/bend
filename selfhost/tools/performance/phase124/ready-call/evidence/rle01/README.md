# Original RLE expand: retained transition and reconstruction evidence

This separate extraction does not modify the previously frozen control evidence.
`inspect.py` reads the Phase123 parent and Phase124 ready QBE named by the root,
records SHA-256 identities, resolves FIDs through each program's segment table,
and preserves exact owner/helper/continuation excerpts. No compiler, target,
disassembler or benchmark is executed. Counts below are static source sites.

## Exact scheduler edges replaced

| Parent location | Original operation | Ready private owner |
| --- | --- | --- |
| `$direct.expand` | `p111_rt_jump` to FID249, `$direct.lrepeat` | Full-U64 argument snapshots then direct `p113d_$direct.lrepeat`; result → local unwind |
| FID263, `$p111.k.49955` | `p111_rt_jump` to FID262, `$direct.expand` | Snapshot/rebind owner argument, `jmp @p114r_descend` |
| FID264, `$p111.k.49956` | `p111_rt_jump` to FID256, `$direct.lconcat` | Full-U64 snapshots then direct `p113d_$direct.lconcat`; result → local unwind |

The two helper public wrappers each contain two register reads and a runtime
return. They remain exported in the candidate for original identity, but the new
private owner bypasses them. The parent owner base case had its own runtime
return; the candidate base result stays inside local unwind. A single outer public
expand wrapper retains the ordinary register-read/runtime-return ABI.

Therefore the transformed owner plus its private-call closure contains **zero
runtime jump, runtime return, or runtime apply sites**, with no native call back
to expand. The explicit frame/capture stack and failure behavior remain. One
runtime frame call remains in case0 in this ready-only artifact, covered by the
separate frame-buffer ablation. Other frame pushes and pops use existing inline
templates. This is the same semantics-preserving mechanism as the independent
controls, now demonstrated on the original benchmark.

## What still executes

The source operation is:

```bend
lconcat(lrepeat(U32.to_nat(n), v), expand(t))
```

The candidate calls the same two complete workers, whose existing Phase118 TRMC
implementations are retained in `private-helpers.ssa`:

* lrepeat has a compact numeric countdown and `p118_rt_extend1` per produced list
  cell, ending in `p118_rt_finish`.
* lconcat traverses that newly produced list using `p118_p111_rt_take2` and
  constructs another spine with `p118_rt_extend1`, then attaches the already
  expanded suffix through `p118_rt_finish`.
* `p118_rt_extend1` allocates a fresh cell, stores its prefix and hole, and links
  the previous parent. `p118_destination_fill` reconstructs/validates parent
  constructor metadata and the tail slot, then links/seals according to the
  existing constructor capability. There is no consumed-cell reuse here.
* Expand itself retains the two consuming takes for each encoded list/pair shape,
  plus the opcode24 call and stack/capture traffic.

Thus a positive-length repeated run still has **two list-spine construction
passes**: temporary lrepeat output, then replacement lconcat output. This is a
source/loop fact, not an inferred sample share. No temporary-container elimination
has occurred. This is the largest obvious remaining *category* in the source;
claiming it dominates wall-clock runtime requires a post-change profile.

Opcode24 is U32.to_nat in the pinned primitives header. Its runtime arm only
checks arity and returns the existing U64 argument; it does **not** allocate a
unary Nat. The generic dispatch/scratch round-trip remains unnecessary-looking
work, but it should not be confused with the list allocation/reconstruction above.
Any direct replacement still needs the typed U32/representation contract.

## Machine-level confirmation and next falsification

Root's `fast-machine01/report.json` and exact assembly identities are included in
the new report. The candidate private expand assembly directly calls the helper
workers, retains the two takes/op/frame calls, and branches back inside its own
body. The parent expand assembly is only one of the three old control fragments;
its instruction count is therefore not a fair whole-region comparison against
the larger candidate private worker. No instruction-count speed claim is made.

The strongest next representation hypothesis is a general producer/consumer or
destination-passing composition that eliminates the temporary repeated-list spine,
not another spelling of the same helper call. A cheap falsification should show
that the selected ordinary repeated-list composition can generate the same owning
result and aliases with one construction pass, preserve evaluation order and
helper failure behavior, and transfer to a distinct producer/concat workload.
Independent correctness gates are required; source-name matching is insufficient.
The smaller opcode24 and frame-template omissions are distinct bounded ablations,
not substitutes for validating this allocation hypothesis.
