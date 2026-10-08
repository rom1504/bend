# Reuse the same native body analysis

[Design](../../design/phase68/local-occurrence-reuse.md) ·
[Experiment](../../experiments/phase68/P68-012-local-occurrence-reuse.md) ·
[Profile evidence](evidence/native-request-hotspots09.json).

The Reuse11 candidate reuses an existing body's occurrence index across held
bindings, body lowering and ownership keeps. General cuts and flat binds also
reuse the filtered value environment. The change adds six lines across four
existing functions, with no new type/function/cache/API or generated-code policy.
Its strict build, actual helper controls and three complete C comparisons pass.
Final genuine-B2 request qualification remains separate.

Independent source review found the finite-term equivalence sound: the appended
binder still receives its original live/drop partition; duplicate environments,
full U32 IDs and malformed Var children retain the existing behavior. The value
environment passed to direct live lowering is already filtered, so the removed
partition can only emit an empty prefix. Rest-before-value lowering, fresh IDs
and first-error selection remain unchanged.

The companion controller compares entire native lowering results on actual
checked B1 images and observes the real occurrence collector to establish that
calls decrease. It is not a timing benchmark. The four-function source shape is
kept separate from the product-lowering prototype, whose substituted and original
bodies must not share an index without a separate proof.

The controller is independently source-reviewed and frozen at
`b54254ef…db5b`. Its 3,520 planned pairs include nested value/body composition,
errors, unused binders and duplicate/full-U32 environments. It requires the
frozen source inventories to agree outside the two declared changed modules.
This is method readiness; no candidate helper or C target has run at this
report checkpoint.

The seven-line renderer shortcut is retained as source-only evidence, not part
of this candidate. Its apparent built-in advantage did not survive inspection:
String.lines still calls recursive per-character String.split in actual B1/B2.
Its sampled budget is also much smaller than repeated occurrence collection.

## Exact Products10 rebase and checked Reuse11

The immutable v2 proposal replays the same local edits on actual Products10.
The fourth function is now named `nf_bind_boxed`; its new call metadata and
product target fields remain unchanged. The product-specific `nq_bind` is not
modified: its original and substituted bodies have different occurrence sets.
The patch still adds six lines and no new functions/types.

Reuse11 passes its strict checked build. Controller v2 passes 3,520 complete
lowering pairs and four extra cases with actual call-edge metadata and a
two-field bundle result, in 2.53 seconds. It compares complete results, not
occurrence-index representation. It also verifies the source inventories differ
only in the exact proposed bridge/flat changes.

Observed occurrence collector calls across those finite fixtures decrease from
15,544 to 9,350. Body-specific counts fall from 7,360 to 3,880; value-specific
counts fall from 4,640 to 2,640. These are test invocation counts, not program
compilation speed ratios. The independently reviewed three-case complete-C plan
uses actual Products10's runtime-qualified outputs as its oracle and changes
only the API in that exact acquisition recipe. All three targets now pass,
preserving every emitted C byte and the prior executable qualification.

| Request | Products10 B1 | Reuse11 B1 | Change |
| --- | ---: | ---: | ---: |
| Numeric | 2,142 ms | 2,023 ms | −5.57% |
| Array | 2,447 ms | 2,339 ms | −4.38% |
| Lexer | 3,087 ms | 2,892 ms | −6.32% |

The geometric mean is 5.43% less request time across these three separate
single-observation acquisitions. This is a useful screen, not a balanced
performance estimate or evidence of B2 speedup. The
[portable join](evidence/occurrence-reuse11.json) pins the exact images, source,
helper results, emitted outputs and clocks. It preserves the root's original
compact C report with its `pass_` field and independently verifies the actual
emission receipts, guard commands and full byte equality.
