# Recurrence experiments: rejected policies and remaining fold gap

The first placement policy improves both fold points by about 20% but regresses
edit-distance by about 15%; it is rejected. V3 preserves the original candidate
pool and loses the fold win while slowing Mandelbrot. V4 passes its controls but
rejects the useful fold placement because it spills a one-time setup temporary;
the actual-machine gate stops it before runtime. None is promoted.

- [First policy results](RESULTS-first.md) and [runtime data](runtime-summary01.json).
- [V3 results](RESULTS-v3.md) and [runtime data](runtime-summary02.json).
- [V4 activation failure](RESULTS-v4.md) and [evidence index](v4-evidence-index.json).
- [Final fold/C attribution](final-fold/NOTE.md): current objects remain unchanged;
  large-input incremental cost remains about twice C. A [source-only two-cell
  falsifier](unroll-two/README.md) is prepared separately, with no compiler edit.

The technical history below describes the first policy and its original
prediction; subsequent results above supersede any pending-work language.

# Recurrence residency through joint pair placement

This experiment starts from the Phase197 combined compiler, the explicit source
`selfhost/build/phase197/full-source01/compiler.bend`. It changes no live compiler
file or executable. `recipe-v2.json` identifies two hook replacements and finite controls. The
candidate passed source checking in `loops-api01` on its first executed attempt.
`loops-controls01` passed28 structural checks and the independent eight-function
joint/liveness C observer on both direct-object and rendered-assembly routes.
The observer performs802 function-result comparisons per route; both control
groups emit identical observer programs, so the repeated run adds no coverage.

The read-only checked-API capture is
`selfhost/build/phase198/loops-capture01/capture.json`; its guard completed in
21.16 seconds. It recorded actual allocation graphs and retained byte-identical
editdist assembly relative to Phase197 combined. The capture's `tailParams` field
is empty because JavaScript replacement-string processing collapsed `$$` in the
observation expression; it has no bearing on compiler execution or the observed
names, graph, groups, parameters and Again values. The analysis below pairs the
recorded parameters after `state,__x181_result_out` with the Again values, exactly
as the unmodified `x181_tail_args` definition does. The capture script is fixed
for subsequent runs; the original instrumented module and receipt are preserved.

Two concrete opportunities appear:

* In editdist's `$product.row`, fuel and index successors are both outside the
  bounded 32-name register-candidate pool. Their parameters are resident. The
  current body stores both successors and reloads them at its backedge. Merely
  preferring an already allocated copy partner cannot eliminate this transport.
* In `$product.fold.loop`, the fuel parameter and successor are both candidates
  and have no interference edge, but occupy different physical homes. The index
  parameter and successor genuinely interfere, so this pair must remain apart.
  Accumulator publication already shares its backedge home.

The direct fold loop is already register resident, with scaled array addressing
and no frame references in its positive body. It still executes 16 body
instructions in Phase195; the inherited decrement rule can remove one. The
retained QBE loop also uses scaled addressing and carries fuel in one register,
but has redundant width/copy operations. Mature C inlines the recurrence into
`NF_FID_112_57_51_46_108_111_111_112_`, unrolls two iterations, and uses in-place
memory-source ADD for the accumulator. Its repeated block at `0xf880..0xf8b0`
contains 15 instructions including the conditional backedge for two cells.
The corresponding complete-iteration counts are direct18 versus C15 per two
cells. The pinned machine census is in [machine-context](machine-context/README.md).
These are dynamic-work distinctions; this is not a claim of DRAM misses or a
missing bounds check. Array masking remains required by circular indexing.

`paired-v2.bend` addresses the two placement causes together. Candidate admission
scores each nonidentity recurrence transfer using the sum of its original
endpoint scores, taking maximum across branch occurrences without compounding.
This encourages both ends of a repeatedly executed copy to enter the existing
bounded pool. Once the unchanged interference graph is available, the greedy
allocator may reserve a common color for a name and one still-uncolored tail
partner. It requires no mutual interference, checks both endpoints' ABI and call
clobbers, and checks the union of their conflicts against existing occupants.
The later encounter of an already reserved endpoint keeps that home.

The existing independent `x190_j_valid` validates the complete placement before
installation. Failure retains the complete previous allocation path. No graph
edge, loop operation, width, ABI, ownership operation, branch, memory operation,
zero-fuel behavior or error path is removed. Pool size (32 names, 9 registers)
and admission bounds (256 statements, 64 parameters) remain unchanged. This is
a placement heuristic, not a proof of globally profitable coalescing. Increased
pressure and code movement can cause regressions, which must remain in results.

The frozen machine expectation is that at least the fold fuel pair will share a
home and the edit recurrence successors will enter allocation. Emission must
establish actual stores/copies removed; no exact postallocation instruction count
is predicted because recoloring can affect other homes. The intended screen is
editdist and local-fold, with a held-out fold input and an unrelated sentinel;
compare incrementally with Phase197 combined and retain independent C oracles.
The finite control driver also reuses Phase190's joint allocator/ABI machine
observer on both direct-object and rendered-assembly routes.

The original source01 was never checked: inspection found two missing affine
sharing annotations before acquisition. Source02 adds only those annotations.
Both prepared sources remain. Guarded costs so far are21.16 seconds for capture,
16.94 seconds for checked API acquisition and27.59 seconds for controls.
The initial policy
subsequently completed its four-program screen; results and additional guarded
costs are in RESULTS-first.md. The narrower follow-up is not yet measured.
