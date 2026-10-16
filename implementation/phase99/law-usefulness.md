# Phase99: what the laws establish

The final borrowed-call candidate is source04, SHA-256
`c19e926eb7d8d41309c9ed8aa18960c484f3b17681507b57da5418ccfedd31ec`.
Its two directly rebound bundles establish six distinct source-level contracts.
Both passed source checking, safe elaboration and independent kernel checking
with no opaque definitions. Each bundle's three modified helpers admitted alone
before the unchanged laws rejected them. Those negative results are source-check
rejections, not additional kernel or native-program executions.

| Bundle and source linkage | Actual optimizer behavior constrained | Useful limit |
| --- | --- | --- |
| [Borrowed arguments, source04 extraction](../../selfhost/tools/performance/phase99/scalar-controls/borrowed-args-laws02/manifest.json), [positive receipt](../../selfhost/build/phase99/borrowed-args-laws02/report.json), [negatives](../../selfhost/build/phase99/borrowed-args-negatives02/report.json) | The actual `nob_words_cons`, called by `nob_arg_words`, prepends a runtime variable in order and propagates a rejected head or tail as the complete `Absent` value. The extracted closure includes actual KTerm constructors, field helpers and tag comparison. | This does not prove that an argument is well typed, rooted, alive or correctly saturated. |
| [All-trivial guard, source04 extraction](../../selfhost/tools/performance/phase99/borrowed-calls/static-laws01/manifest.json), [positive receipt](../../selfhost/build/phase99/static-laws01/report.json), [negatives](../../selfhost/build/phase99/static-law-negatives01/report.json) | The actual `no_all_trivial_roots` emits an AND for two roots, excludes an intervening scalar slot and emits the true identity for an empty tail. Parameter word names are universally quantified. | These are C-text contracts for the selected shapes, not a universal C semantics theorem or proof of `term_triv`. The caller's OR with the old shared predicate is inspected separately. |
| [Scalar transport, rejected scalar source03](../../selfhost/tools/performance/phase99/scalar-controls/kind-laws03/manifest.json), [positive receipt](../../selfhost/build/phase99/scalar-laws01/report.json), [negatives](../../selfhost/build/phase99/scalar-law-negatives01/report.json) | Actual `nk_typed_bindings` preserves ordered IDs/word names and transmits the supplied head kind; `nf_param_type` keeps opaque parameters as `Term`. Four public contracts use one support lemma. | This proof is attached to `38c40313…`, the rejected scalar experiment. It does not justify scalar permission or SCon representation, and it is not another final-source04 bundle. |

The source03 borrowed-argument result remains preserved in
[`borrowed-args-laws01`](../../selfhost/build/phase99/borrowed-args-laws01/report.json).
Source04 re-extracts and rechecks the same three laws against its actual source;
that replay is not three new distinct laws. Earlier Phase98 contracts retain
their recorded source and scope. A historical catalog count must not be presented
as the number of newly proved final-optimizer properties.

The mutations test different things, so their significance should not be flattened
into a single count:

- Borrowed `bad-order` changes argument order and can alter a noncommutative
  callee's result. `bad-head` can package a rejected argument as `NO_Args`; the
  later emitter still validates atoms. `bad-tail` retains an `Absent` tag while
  adding children, so it violates the complete failure-value contract rather
  than independently admitting a bad call. These are demonstrated helper/law
  differences; no native semantic failure of these mutants was measured.
- Static `bad-any-trivial` replaces AND by OR but retains the final `1`.
  Consequently its emitted alternative is **always true**, not merely true when
  one root is trivial. It defeats the unique/mixed-input fallback policy.
  `bad-tail-false` disables the entire new alternative. `bad-scalar-included`
  incorrectly makes scalar bit patterns affect route selection. These mutations
  change optimization policy; source admission alone would not reject them.
  They were not benchmarked, and a policy violation does not itself demonstrate
  wrong program output.
- Scalar `bad-slots` corrupts binding identity, `bad-kind` drops the supplied width
  fact, and `bad-opaque` narrows opaque private parameters. The laws distinguish
  those implementation errors even though the original scalar optimization
  failed its performance gate. Passing value laws never established a speedup.

The final source04 safety argument is appropriately narrow. It changes the
redirect to `(ANY shared root) || (ALL schema roots term_triv)` and preserves the
old body, schemas, certificates and owning adapters. The existing schema requires
one or two roots; the empty-fold identity does not admit a zero-root observer.
Only root slots enter the new clause. Unique dynamic roots, including an RFC
wrapper at count one, retain the owning path unless another root is shared.
In the pinned runtime `term_sink` performs no work for `term_triv`, so the new
all-trivial case adds no dynamic destruction traversal. `term_triv` also accepts
values such as scalar words and the hole sentinel: it is not a type certificate.
Checked root schemas, valid native representations and the caller-held lifetime
remain essential premises. No blocking defect was found in this bounded source
review, but the laws do not prove those premises, reference counting, native
evaluation order or the whole compiler.

The final-evidence methods were reviewed without running targets.
[`borrowed-final.py`](../../selfhost/tools/performance/phase99/release/borrowed-final.py)
authenticates both compiler images and their common source, compares their full
C output and reference diagnostics, then builds the unpatched C and checks full
program output. [`borrowed-collect.py`](../../selfhost/tools/performance/phase99/release/borrowed-collect.py)
rebinds the exact declarations and mutations, proof snapshots, raw process/output
receipts and final C mechanisms. They explicitly leave whole-compiler proof and
the remaining full-image qualification gates separate. Review of a method is
not evidence that its eventual run completed.

One precise inspection gap was identified: the original own-C inspector checks
the shared route but not source04's all-trivial clause. Small-program mechanism
checks already cover the clause. A fresh `inspect-static-self-c.py` companion is
prepared to check exact own-C root selection, unchanged fallback and runtime;
its completed receipt, rather than the original inspector alone, is needed for
that final own-C claim. Frozen methods were left unchanged.

The next most useful law is an actual acceptance-to-ancestry contract for
`nob_arg_word`/`nob_live_root`: every accepted borrowed root has the expected plain
type and an origin beneath a declared caller root, including reordered and
aliased actuals. Extract the production helpers and produce the root witness;
do not replace them with a separate Boolean model. That would close a more
important source-level gap than adding further constant guard-text examples.
Even then, native alias/escape/error tests and the runtime ownership argument
would remain necessary.
