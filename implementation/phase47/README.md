# Phase47: research-guided optimization

Campaign in progress, 2026-10-04. Installed compiler remains Phase45 worker23.
No promotion or new representative-corpus result is claimed by this checkpoint.

Update: the first source candidate passed its focused gate and independent
24-oracle/39-boundary array controls. Public-call ablations show that ordered
write statements are also needed: worker23 takes90.854 microseconds/call,
raw backing alone84.207, and raw backing with explicit writes63.809. The latter
is still a diagnostic derivative, pending source validation. See the
[V8 analysis](v8-analysis.md) and [public screen](evidence/array-public-screen.json).
The earlier batch result uses a different call context and is not multiplied
with this public-call gain.

The405-line worker cleanup is deferred and preserved as an experimental patch: it
does not remove the intended aggregate shells and its small preliminary gains
do not justify shipping that complexity. See the [outcome](worker-outcome.md).
The separate compiler memo diagnostic reduced one lexer request median6.64%;
[its outcome](compiler-memo-outcome.md) does not authorize a production cache.
[Design](../../design/phase47/research-guided-optimization.md),
[first-screen evidence](evidence/first-screen.json).

## First result: repeated array backing lookup matters

Twenty fresh-process, oracle-checked samples (five rotated rounds, 8192 warmups
and 8192 measured invocations each) compare exact saved Phase46 JS derivatives:

| Variant | Median batch ms | Original / variant |
| --- | ---: | ---: |
| Original | 680 | 1.000 |
| Expand write helper only | 683 | 0.996 |
| Reuse backing view from first read | 186 | 3.656 |
| Also reuse length | 186 | 3.656 |

All values and independent batch digests agree; four short correctness samples
also agree. Both global Number conversions remain in each iteration. This is a
useful causal result on this generated loop, not a safe general transformation:
mutable host hooks, escaped storage and callbacks can invalidate the proposed
cache. The prototype preserves bytes outside three exact hashed function spans.
[Producer and boundary explanation](array-proposal.md).

The helper expansion has no useful effect; backing reuse is the next production
hypothesis. Length reuse adds no measured benefit, so it does not justify an
additional invariant now. A separate implementation/review is establishing the
smallest closed-region ownership and host-effect contract before compiler edits.

The first producer attempt failed its own assertion: the substring `Number(`
also matched `regionCounterNumber(`. It wrote no derivative and executed no
target. The original producer is retained as `array-probe-v1.py`; the successor
uses a token-boundary assertion. The transformation itself did not change.

## General worker cleanup and compiler cost

[P47-002](../../experiments/phase47/P47-002-worker-value-cleanup.md) implements a
separate bounded experiment in the existing typed worker IR: inline small known
linear helpers, then propagate immutable field facts and eliminate proven unused
private aggregate shells. Independent controls and review run in parallel with
implementation. This follows the Rust/LLVM enabling-pass/cleanup pattern and
does not claim to admit higher-order or Array graphs that fail earlier proofs.

The first diagnostic lexer compiler request counts21,664 outer type-proof
queries, including11,005 repeated exact book/type identities. Its instrumented
public emission stage takes3.374 seconds of a7.241-second cold request, which
also includes Base preparation. These are attribution numbers with counter
overhead, not clean baseline timings or a cache speedup. A bounded exact-key
counterfactual will decide whether query reuse deserves a Bend implementation.
[Census proposal and prior failed caches](compiler-cost-proposal.md).

## Execution policy and current limits

Root executes serially on CPU3 using the existing exclusive execution lock,
1 GiB Node heap, 2 GiB process-tree RSS limit and4 GiB available-memory floor.
Agents independently prepare implementation, controls, source census and review.
The new raw outputs are under `selfhost/build/phase47/`; closure and durable
preservation are pending while this campaign is active. Phase45/46 evidence is
unchanged. No PR comment has been posted.
