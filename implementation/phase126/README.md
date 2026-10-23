# Phase126: compose useful optimizations and remove failed machinery

Campaign in progress, starting `3c94d98` at 2026-10-22 22:59 UTC. The authorized
three-hour window ends around 01:59 UTC. Phase125 remains the native-qualified
checkpoint; no Phase126 native qualification or installed selection change yet.

## Findings established by the first focused experiments

1. Persistent local float values help, but a typed private ABI did not. In a
   rotated paired run, active-ray medians were1175ms local-only,1297ms typed and
   1712ms Phase125. The simpler option also won ordinary ray,1835/1863/1973ms;
   recurrence418/419/416ms was neutral. Keep the successful cleanup and discard
   the extra ABI/analysis from the candidate. The compact implementation emits
   byte-identical QBE to the selected prior composition on all three sources.
2. Finite scalar tables compose with the float cleanup. Table-only active-ray
   median1391ms versus1692ms parent; their composition903ms versus1699ms parent
   and201ms upstream. Actual scalar definitions/refusals are independently
   inspected, including full-width Nat defaults. This remains a focused result.
3. A safe conditional in recursive argument preparation blocked a whole local
   continuation region. Admitting that exact retained branch cuts ordinary-ray
   runtime1911→561ms, with upstream229ms. Tree-bitonic, Mandelbrot and local-fold
   in the same screen remain approximately unchanged. The column worker now
   uses the existing explicit-stack region instead of scheduler transfers.

These numbers are compiled-program execution time. They are not compiler
throughput or a replacement for the original44-point geometric mean. Full
composition, additional controls, broad timing and integration are still pending.

## Second focused checkpoint, 00:17 UTC

The checked inline20 composition passes seven ordinary programs (106 output
lines), including float boundaries, full-width valid Nat values, aliases and
recursive shifts. Its five-case screen gives active-ray769/1696/200ms,
recurrence303/418/201ms and ordinary-ray374/1913/230ms
(candidate/Phase125/upstream). RLE1253/1266/217ms and lexer504/515/186ms are
approximately unchanged. These subsets must not be pooled into a corpus score.

Machine inspection explains the recurrence improvement: explicit operation58
admission unlocks the entire local float buffer, reducing60→40 instructions,
9→0 stack-memory operands and9→2 integer/XMM transfers. There was no runtime
call in either worker. The additional Nat predecessor projection removes one
helper call and six stack operands in the recursive ray column worker; its
numeric workers remain byte-identical. Table-call projection then removes the
remaining selector boundaries, improving active-ray beyond whole-table emission.
See [machine evidence](machine-work14-17.md) and the pinned inline20 screen.

Two broader experiments are now bounded independently. Actual map diagnostics
show a missing flat result interface (`$product.Map.bit.go`) despite an existing
verified boxed observer; a Var-only residual adapter plus dependency closure is
checked and passes11 new finite predicates, with runtime results pending.
The tree reshape recognizer admits both the frozen tree computation and an
independent owning-payload fixture; its guarded two-shell reuse still awaits
execution. Neither prototype is a measured improvement or a native checkpoint.

Rejected attempts remain explicit: an overbroad constant-field adapter and a raw
constructor-ID integration were caught in offline review; a bounded type-size
predicate initially used a helper with a fixed4097 offset and refused every
positive. Ordinary fixture corrections repaired parser notation, affine reuse
and a max-Nat expression whose intermediate exceeded the supported limit. The
independent expected outputs were retained; failed receipts were not overwritten.

## Current evidence

- [Design](../../design/phase126/persistent-private-values.md).
- [Float experiment](../../experiments/phase126/P126-001-persistent-float-regions.md)
  and `selfhost/build/phase126/local-typed-paired01/report.json`.
- [Table experiment](../../experiments/phase126/P126-002-finite-scalar-selectors.md),
  `table-inspect02/report.json` and `combined-screen08/report.json` under Phase126.
- [Conditional recursion experiment](../../experiments/phase126/P126-003-conditional-recursive-preparation.md),
  `resume-finite10/report.json` and `resume-screen10/report.json` under Phase126.
- [Machine evidence](machine-audit-v02.md), [local ablation](machine-audit-local06.md),
  [table review](table-review.md), [recursion review](scalar-resume-review.md).

All timed observations use the unchanged complete-result/count oracle, selected
Phase125 runtime, branch-aligned QBE machine builds and one guarded CPU3 lane.
Frozen sources, failed acquisitions and unsupported control literals remain
preserved. Agents inspect disjoint code/proofs/tooling; only the root runs targets.

## Remaining work in this campaign

Test the missing F32-to-U32 operand case, exact Nat predecessor projection and
bounded constructor identity. Test table-call composition if ready. Retain only
measured useful changes, then run ordinary controls, the frozen45 corpus and a
matched compiler-cost screen. A native checkpoint is contingent on material
benefit, memory/disk headroom and enough remaining time; it is not inferred from
hosted benchmark success. Final report will replace these pending statements.
