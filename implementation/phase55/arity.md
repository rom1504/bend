# Reuse checked matcher types during arity recovery

The first Phase55 candidate uses the expected type already attached to a matcher
instead of scanning every definition's constructor list during `jd_raise`.
Only `selfhost/src/back/js/direct/model.bend` changes: 159→179 physical lines,
+985 bytes and three small helpers. This source proposal has independent static
review; checked compilation, output parity and request cost remain separate gates.

## Why this is a concrete target

The Phase54 interrupted compiler-image profile identified `j_find_ctor` at26.5%
of sampled ticks, with80.3% of those samples beneath `jd_raise_head`. The query
walks every book entry's constructor list, repeatedly allocating `missing`
results. The existing top-level book index cannot directly answer constructor
names, because constructors live in owner `dc` lists. These interrupted sampled
counts are evidence for a mechanism to test, not a promised speedup.

`jd_raise` receives recursive terms produced by `annotate_selected`, then
immediately calls `j_strip`, discarding the annotation that identifies the
matcher's expected function type. Reusing that existing fact avoids a new index,
cache lifetime or telescope threaded through every arity-recursion call.

## Selected contract and implementation

The fast route is deliberately narrow and lazy:

1. The input has an `Ann` wrapper and its stripped expression is `Mat`.
2. Normalize the annotation's expected type and require `All`.
3. Normalize its input domain and require `ADT`.
4. Use existing `j_layout_ctor(book, domain, matchName)` to find that owner's
   constructor. This helper retains the global fallback for a missing owner or
   constructor.
5. Apply the unchanged signed residual adjustment and minimum across both arms.

Unannotated input, nonmatcher expressions and unknown expected-type shapes use
`jd_raise_head` and the original global search. The small shared
`jd_raise_match` helper holds the exact old two-arm calculation; signed U32
residual behavior, lambda raising, `Efq` and the telescope cap are unchanged.
The common `j_find_ctor`, runtime, library ABI and all graph limits are unchanged.

The normal owner query costs indexed top-level lookup plus the selected owner's
constructor list, rather than a whole-book scan. Type normalization still costs
work, as does repeated arity recovery itself. No asymptotic or timing claim for
the complete compiler request follows from this local change.

## Why owner lookup preserves checked-source meaning

The active checker calls `event_error` from
`diagnostic/produce.bend:dg_check_events`. For a new ADT,
`check/kernel.bend:constructor_names` rejects both duplicates within its own
constructor list and a name found by `constructor_exists` in prior owners.
Repeated owner declarations are also rejected. The parser independently rejects
duplicate constructor declarations. Qualified names after source loading are the
names consumed by this check; different valid namespaces retain distinct names.

`check/annotate.bend:annotate` records the expected type in `Ann`.
`ka_lam` recursively annotates its body. `ka_mat` resolves the constructor from
the normalized ADT owner, and `ka_mat_ctr` recursively annotates both its chosen
arm and refined fallback. Removed-constructor refinements do not change a
constructor's field arity. Thus the checked owner query and prior global search
refer to the same unique constructor on the supported fast route.

This is an internal checked-emission contract. A forged raw `Ann` book containing
duplicate global constructor names is not a supported private backend input;
the typed lookup could differ from global first-match behavior there. We do not
claim otherwise. The common global query remains unchanged, and unannotated raw
inputs retain its original precedence. Checked duplicate-name rejection, valid
namespaces/aliases, erased fields, nested signed residuals and unknown-type
fallback are separate falsifiers for this proposal.

## Preserved proposal and required evidence

`selfhost/build/phase55/annotated-arity01` holds exact before/after source,
`annotated-arity.patch`, `original.json`, the data-only preservation producer and
`proposal.json`. Nothing under closed Phase54 raw evidence is modified.

Before SHA256:
`22c66ed470e59392954320f31e98b66c2666c31ff2109945bc297ff7fd4a35bf`.
Candidate SHA256:
`dc48e335d8dc1bdc58aeaca26cdadfd53e952e975f85c3a529719905deb25aaf`.

Independent static review passes the exact patch under the stated contract.
The root owns checked builds and target execution. Promotion requires unchanged
arity/output results on checked controls and source cases, explicit fallback
checks, and the actual complete compiler-image request. A smaller sampled hotspot
alone would not establish that the full request completes.
