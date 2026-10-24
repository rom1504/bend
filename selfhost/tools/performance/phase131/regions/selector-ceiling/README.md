# Exact selector/consumer source ceiling

This freezes original final-Phase131 `index_find`, `index_bucket`, `dx` and their
actual supporting definitions. The alternative pushes only the scalar `dx`
consumer through the selector's returns. It remains ordinary checked Bend;
there is no borrowed-return ABI, runtime edit, protected verifier edit or
benchmark-name recognizer. This measures whether more general compiler fusion
is worth implementing, not an implemented automatic optimization.

`prepare.py` freezes original extraction and an independent host map algebra.
V01 omitted three source forward laws; the parser refused. `repair-v02.py` adds
those exact laws. V02 then exposed an affine annotation in new scaffolding;
`repair-v03.py` adds explicit quantities only in new functions. Both refusals
and immutable source versions remain. V03 is the execution candidate.

The 34-line ordinary output checks 16 cases through **both** implementations,
then observes retained roots. Cases cover modern/legacy maps, hash mismatch,
collisions, duplicate first-match order, mask-zero nodes, misses, Unicode and
empty keys. An empty-key case selects a KIndexNode whose `dx` is 99; no
ordinary-record-only assumption is made. Expected output was frozen before
execution.

Timing has two separate sources per implementation: a one-entry leaf and a
64-entry forced-collision stress bucket. Each repeat performs a late hit plus
a miss, producing 1. Hashes are supplied identically and hashing time is excluded.
These kernels do not represent the distribution of ordinary verifier lookups
or full compiler throughput. Last argument `N` selects repeats and must print
`1\nN\n` followed by one elapsed-millisecond line. No argument selects controls.

Use `cases-v03.json` with the existing integrated Phase128 emitter and final
checked API. Each resulting SSA is built with the unchanged aligned builder,
Phase128 runtime and `expected.stdout`. `timing.py` seals the four already
checked native products; root runs clean paired measurements on CPU3. An initial
1,024-repeat pilot can calibrate a 500 ms faster-variant batch with
`--pilot-report REPORT`. No target is run by the preparation scripts.

V03 passed all four integrated independent original-verifier gates and all four
34-line native ordinary oracles. Receipts are in `qualification.json`; initial
refusals remain under `phase118/p131-selector-ceiling01` and `02`. Successful
emission is `phase118/p131-selector-ceiling03`. CPU5 performed correctness only;
root owns performance measurements.

`static.json` records a useful limitation: the fused query wrapper shrinks from
111 to 7 machine instructions, but owning `dx` work moves into the bucket
(272 to 376 instructions). Selector bodies remain 595 versus 594 instructions
with the same static constructor/sink call counts. This source transformation
alone does not establish a borrowed descendant or eliminate traversal ownership.
It isolates scalar-result/consumer placement from the stronger proposed private
region capability. Both algorithms are present in both binaries because the
ordinary controls exercise them; only the timed query choice differs.

The calibrated root-owned measurements now show 6.26% lower wall time for the
one-entry leaf and only 0.52% for the collision stress. Internal loops are at
least 104 ms, though the startup-heavy pilot undershot its 500 ms target. Full
results, limits, proof scope and next composition hypothesis are in
[the source-ceiling report](../../../../../../research/phase131/selector-ceiling.md).
