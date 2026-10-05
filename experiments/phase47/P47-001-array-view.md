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

## Final outcome — 2026-10-05

The saved-output screen supported backing-view reuse: five rotated rounds
measured a 680→186 ms batch median (3.656×), with all 20 value/digest checks and
four short controls passing. Expanding only the write helper gave 683 ms; adding
length reuse to backing reuse stayed at 186 ms. These are diagnostic derivatives
in a batch context, not safe public-boundary or installed-compiler results.

The follow-up public-call screen found a separate ordered-write gain and did
not support an invariant pointer cache. The installed array06 implementation
therefore retains fresh host/ownership proofs and demanded length reads, with
no backing registry or length cache. Its independently qualified production
outcome is recorded in [P47-004](P47-004-private-array-layout.md) and the
[phase report](../../implementation/phase47/README.md). The initial 3.656× result
must not be multiplied by those later gains or treated as a universal speedup.
