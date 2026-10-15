# Canonical table integration proposal

This is an offline proposal, not an applied production change or a qualified
compiler. Root reported all 46 fork controls passing with byte-identical legacy
and indexed JS/native stdout (`build/phase90/fork-controls03/comparison.json`),
and full native-candidate acquisition passing in 88.178 seconds. Those results
cover the experimental native-equality variant. The following canonical source
still needs its ordinary checked-source/API and output-continuity gates.

- `tables.bend` is the full proposed replacement for `selfhost/src/back/native/tables.bend`.
- `tables.patch` is a unified patch against canonical source SHA
  `6b8f36fa9063f35105889d8977aa2345fb01eeceb117e6f641151430d084bbaa`.
- `manifest.json` pins all inputs, outputs, names and line counts.
- `../observation/prepare-integration.py --out NEW_DIRECTORY` replays construction.

The patch passed `git apply --check` against the unchanged canonical file.
It combines the five reverse-chunk table builders with the exact indexed fork
closure and flags. It preserves each existing function and its call arguments;
only six prior function bodies change. The other 31 declaration bodies are
verified byte-identical. All seven experiment helpers become descriptive
`nb_*` functions; the private index marker becomes `NativeFork`. Reversing those
name/marker substitutions restores the experimental helper source exactly.
There is no `p88_string_eq`, other `p88_` symbol, or `p90_` symbol in the result.
Canonical `String.eq` remains in use.

The module grows from 221 to 302 physical lines (+81; 8,602 to 11,881 bytes).
Functions grow from 37 to 49: five chunk helpers and seven index/closure helpers.
No new Data type, external library, host operation or compiler pass is added.
The original fixed-point order, fuel, convergence test and root list remain;
only membership storage and text construction change.

## Compatibility and possible later deletion

All 37 existing functions remain. The five `*_go` entry points still accept a
String prefix and produce the same text. `nb_fork_step`, `nb_fork_next` and its
law, and `nb_reaches` remain available even though the new production closure
path no longer calls them. A source search found their references only in the
table module; the complete-product fixture explicitly calls `nb_fork_step`.
That is evidence of dead internal production traversal, not proof that the
raw API or external callers no longer need those symbols. These three
functions/the law are deletion candidates only after root decides the API
boundary and updates its coverage. None is removed here.

Before canonical promotion, use the ordinary checked compiler path with these
functions, retain full-C equality for representative/broad sources and exercise
both JS and native outputs. The 46 native-profile controls include Unicode,
empty names and complete hash collisions, but do not establish malformed raw
JavaScript string exception order. Source and installed compiler identities
remain unchanged until root applies and qualifies this proposal.

`tables-integration01` is an unrun earlier formatting draft; integration02 only
moves the zero-fuel comment beside the function it describes. Its generator was
retained as `prepare-integration-v1.py`. Use integration02 for review.

## Evaluation-demand follow-up

Generated upstream JS evaluates both operands of Bool.and/or. The preserved
candidate therefore computes indexed checks even for fork roots before choosing
the branch; old `nb_fork_step` skips those through an outer `nt_choose`. This is
additional candidate work, not a result discrepancy. The integration keeps the
already-tested candidate unchanged; a lazy outer guard would be a separate
optimization/control variant. The independent fixture's original optional
comparison counts assumed Python short-circuiting: use
`../observation/fork-demand-correction.json` instead when discussing source-level
counts. All 46 complete products and four execution outputs remain valid.
