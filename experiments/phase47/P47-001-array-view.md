# P47-001: private array view causal screen

Date: 2026-10-04. Status at plan freeze: correctness unchecked, measurement not
run, decision investigate. Owner: root execution, lowering producer, independent
analysis controls. [Campaign design](../../design/phase47/research-guided-optimization.md).

Hypothesis: repeated array backing lookup/length transport, rather than already
removed tuple allocation, accounts for a useful fraction of our JS array-fold
cost. Phase46's native allocation findings do not establish this JS hypothesis.

The exact saved Phase46 checked JS is the parent. Three diagnostic derivatives
successively expand the write helper, cache the backing view, and cache length.
Retain both Number conversions, first demand and zero-trip behavior. Record
original/derived hashes, independent values/digests and rotated paired samples.
The prototype does not prove safety for escaped arrays or mutable host hooks.

Falsification: no repeatable roughly 5% gain, or boundary proof disproportionate
to observed value. Production implementation requires a private ownership and
effect proof plus controls for aliases, resizing, replacement and reentry.

Results will be recorded in [Phase47](../../implementation/phase47/README.md);
do not overwrite this pre-execution plan with a retrospective success claim.
