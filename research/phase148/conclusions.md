# Compactness must survive the producer and native access boundary

Phase148's measured conclusion is narrow: a late pack → two compact consumers →
unpack adapter does not pay for itself. It does not disprove compact IR, nor
prove that a larger refactor will work. See the [report](../../implementation/phase148/README.md)
for the exact comparisons and independent gates.

## Three lessons

1. **Logical compactness is insufficient.** Ordinary Bend arrays use runtime
   operations and affine ownership transport. A contiguous scalar array can
   still produce more calls than the boxed operation it replaces. Inspect
   actual loads/stores, calls and ownership before forecasting a win from cache
   locality. The current verifier was already improved in Phase147, so another
   numeric environment has less incremental headroom than the old architecture.
2. **Convert less, not just traverse faster.** The extra pack/unpack experiment
   costs 16.2% on its complete workload, while new analysis roughly recovers that
   overhead. Removing rendering does not reveal a hidden large win. A successful
   representation should replace a producer/consumer chain, not live between
   two newly constructed generic trees.
3. **Ownership is part of the representation contract.** Native smoke tests
   must precede large implementations around new array-bearing Type wrappers.
   Hosted equality missed unsafe wrapper sharing. The corrected consuming unit
   and returned admission result are worth preserving; they are not a proof.

## Ranked experiments

| Priority | Experiment and falsifier | Expected value / cost |
| --- | --- | --- |
| 1, feasibility | Narrow `p148c_at`/`p148v_w` to their required buffer; inspect machine code and repeat the frozen complete unit loop. Stop if reads retain most transport or whole-region savings remain negligible. | Small implementation; one source/control/native timing loop. Tests whether the storage choice can support the larger design. No large cold-build gain forecast. |
| 2, structural | Emit stable IDs and compact instructions directly from one real lowering family; carry them through scalar analysis, admission and rendering, decoding only where independence requires it. Measure all materialization, final verification and teardown. | Highest leverage in this backend direction; several consumers must change together. Require substantial complete-region improvement and unrelated transfer before a full build. Existing 37.6s lower / 24.3s initial-opt / 38.9s render CPU intervals identify scope, not guaranteed savings. |
| 3, independent | Keep request-local semantic identities across parse, check and publication; avoid reconstructing names/index facts between these stages. Start with one complete definition cohort and exact diagnostics. | Larger potential scope than admission alone: 32.0s parse plus 31.3s check/publication diagnostic CPU. First determine repeated dynamic work and conversion costs; no demonstrated speedup yet. |

These are relative research priorities, not three commitments to implement in
parallel. The first is cheap enough to reject the storage mechanism before
investing in the second. If it fails, the frontend identity experiment is a
better alternative than repeatedly tuning this adapter.

## What would justify 100 seconds or less?

246.17→100s requires eliminating about 59% of **complete cold wall time**. A
roughly 1% difference in a selected-function loop cannot support that prediction.
Even a much faster scalar optimizer cannot erase parsing, checking, output and
machine-construction work. Require a measured accounting of removed work across
several large regions, plus full-build confirmation once small gates justify it.

The 10× ambition is to remove redundant representations and ownership work
across those boundaries, while retaining independent verification and output
quality. The 100× ambition adds stable checked units and fine-grained reuse for
edits, plus bounded independent work where the critical path permits it. Warm
reuse and multicore speedups remain separate metrics from cold serial speed.

Do not add a universal IR, cache hierarchy or alternative backend merely to
express this ambition. Preserve the current compiler and let a producer-to-final
consumer experiment decide whether the architecture deserves integration.
