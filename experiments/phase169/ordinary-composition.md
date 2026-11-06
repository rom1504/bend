# Bounded ordinary composition after the renderer repair

The arrays-only treatment improved the root's editdist screen from19.192× to
14.898× the retained Phase152 runtime. This is useful but leaves the dominant
staged cell chain. The [product audit](editdist-quality-audit.md) identifies
row→cell→cell.f1→cell.f2→cell.f3→cell.f4 calls where the mature compiler composed
the inner computation. The array renderer can optimize visible operations; it
cannot recover operations hidden behind those calls.

[`ordinary-composition.bend`](../../selfhost/tests/phase169/ordinary-composition.bend)
extends the current early selective walk only for ordinary unblocked functions.
It calls unchanged `p113i_function` and publishes the resulting function only
through the unchanged `p113i_original_clean(original)` and
`p113i_table_function(candidate,table)` gates. Thus the maintained size, stack,
site, call/result, renaming and scalar-cleanup contracts remain in force. The
table contains only preceding definitions and the output keeps list order.

Every observer seed stays unchanged and unpublished. Every cached scalar/retry
owner stays unpublished, even when its scalar plan is ineligible. Selected
blocked owners still use exactly `p168t_target`, retaining a transformed body
only under its original leaf contract. All scalar production, closed-worker
verification, consumer retry, actual final verification and renderer namespace
checks follow unchanged. This does not reintroduce the prior broad early walk
that copied mutable owned consumers before their borrowed replacements existed.

The treatment runs before borrowed conversion. Applying the mature inliner to
final borrowed bodies would be a new transformation boundary requiring its own
ownership/projection audit; this experiment does not take that shortcut.

The normal entry derives the unchanged array certificate from the actual
original request, after existing request diagnostics and source permission.
Only a complete scalar/unshared certificate selects an internal mode2. Public
`p168_request_mode` still rejects every input above1 before lowering. Mode0 is
unchanged; a false certificate selects the exact current mode1 producer. The
final renderer independently derives its certificate as before. This repeats
one source predicate for the experiment and its cost must be measured; no new
cached authority is introduced to save that traversal prematurely.

## Falsifiers and controls

Ten finite rows compare the positive ordinary chain with the maintained full
inliner and independently verify the resulting direct list; require exact
unchanged seed/retry/unknown-function behavior; preserve selected-target policy;
and check complete/partial/false certificate mode selection. Private fixture
certificates do not authorize a real request. Existing controls remain exported.

The prepared API source is
`selfhost/build/phase169/ordinary-composition-api-source01/compiler.bend`,
1,653,233bytes, SHA256
`0e49da069d58befcfa92d0632af98b9e8433151fe25d6f7cc30abe034d8252e4`.
The [optional metadata preparer](tools/prepare-ordinary-composition.py) preserves
all consumed modules and inverse-checks its single renamed predecessor entry.
No target was run during preparation.

The cheapest profitability gate is checked hosted editdist emission and its
independent native output, then the already retained balanced runtime screen.
Inspect whether the actual `$product.row` and cell-stage calls disappear before
another compiler-image acquisition. A broader permission check or weakened
retry exclusion is not an acceptable way to force that result.

There is a source-level reason this trial may reach several relevant helpers:
the fixture's cell.f1/f2/f3/f4 have6/6/7/8 arguments. `no_plan_checked` rejects
arity above4 with `observer: owner, effect or arity`; that reason is not admitted
by `p128br_retryable`. This is not a capture of the actual prepared plan map.
Cell/row direct-owner status remains uncertain because they have fewer
arguments and aggregate parameters. Keep this uncertainty visible if the trial
fails to compose the full chain.

For the full compiler the mature certificate is false. Exact emitted QBE is
therefore the intended integration gate, while complete compilation timing
must still charge the additional certificate check. Neither a successful small
chain nor correct editdist stdout constitutes broad runtime qualification.
