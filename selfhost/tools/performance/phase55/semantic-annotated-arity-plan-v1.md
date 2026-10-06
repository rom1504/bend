# Phase55 admission: Ann-aware matcher arity

This is a successor to the [constructor-index alternative](semantic-admission-plan-v1.md), which remains preserved and is not selected. Root's first experiment changes only how `jd_raise` uses a checked matcher's annotation to obtain its constructor field count. Common `j_find_ctor`, `lookup`, `book_context`, cache representation and raw-book winner policy remain unchanged. The 20 raw constructor-query alternatives are therefore not required gates for this experiment.

The baseline is frozen Phase54 graph02 B1. Candidate scope is the ordinary checked/annotated direct emitter: source graph loaded through its frozen driver, accepted by its actual checker, then annotated by its unchanged annotator. Neither forged Ann records nor duplicate constructors admitted through manually constructed books represent this scope. Duplicate tags must still fail through the real parser/checker; the malformed-private-input behavior is not promoted to a source contract.

## Smallest useful gate

Use a saved diagnostic export on each actual checked compiler API, following the reviewed Phase54 graph-controls precedent. Expose actual private `jd_raise(book, term, left)` and `jd_arity(book, definition)` without replacing either body, and use the role's actual source loader/checker/annotator. Baseline B1's existing trampoline and a future direct image's actual function call are distinct bridges; do not route a direct image back through baseline code. Pin original API, exact suffix, parsed unique symbols, source graph and Base, driver, selected attempt, Node, raw/annotated book fingerprints and output reports. No production ABI changes are needed.

The valid source corpus should reuse these existing immutable fixtures; no new source is needed initially:

| Source | Required evidence |
| --- | --- |
| `phase52/fixtures/direct-contract-v2.bend` | Parameterized Packet matcher (two fields); lambda-returning capture; recursive Nat factory; nullary and successor Nat arms; unchanged arity `add=2`, `capture=2`, `factory=2`, `unpack=1` |
| `tests/check/beta_ann_match.bend` | Explicit Ann around lambda matcher; beta/annotation locality; checked accepted result |
| `tests/check/erased_ctor_field.bend` | A real runtime matcher with an erased Type field followed by a dependent value field and Nat tag (three total constructor fields) |
| `tests/check/param_shadow_def.bend` | Local binder shadows a top-level name; actual checked Var/Ref distinction remains unchanged |
| `tests/check/motive_var_shadow.bend` | Checked matcher motive and local scrutinee-variable shadowing |
| `tests/check/computed_match_specialize.bend` | Checked computed/refined match type; ordinary fallback if no closed local ADT is available |

For each accepted graph, compare complete role-specific checked and annotated book fingerprints before arity queries. Compare old/new `jd_arity` for source definitions and old/new `jd_raise` for actual annotated matcher/lambda subterms at the actual residual left value reached by the old walk. The independent simple arity goldens above prevent a shared favorable mismatch from passing; all other rows compare exact old/new values. Record actual Mat annotations and resolved datatype/constructor arities to show that the new local path executes on genuine input, including residual/refined ADT metadata. `ka_mat` annotates each recursive remaining matcher with its own argument ADT and removed-constructor list, so the test must include the rest branch rather than only the first arm.

Also compare the same private methods on the genuinely unannotated parsed source definitions. Traverse raw matcher nodes without manufacturing Ann metadata and require old global-lookup fallback values to remain unchanged. Common-query source bytes stay exact. Empty/error source behavior is covered by ordinary driver tests; do not invent an empty matcher Ann policy as an optimization obligation.

Run `tests/check/ctor_shared_tag.bend` and `tests/check/ctor_arity.bend` through each actual checker and require the same healthy rejection/error phase. These are source admission controls, not synthetic duplicate-book arity expectations. Namespaces/import aliases and closed-type normalization should be verified by a checked fixture if independent IR/review finds that these six inputs do not already cover the relevant invariant; freeze any additional case before candidate observation.

## Reuse after image completion

Root first requires full77 generation within the unchanged 240-second bound, importability, exact requested APIs and named-field transport. After that, run the actual generated compiler through ordinary driver's eight suites and the fixed Phase54 source96/numeric34/composition18/genuine-overapplication2/census26 scopes. Compare all 45 point modules against frozen graph02 production emissions with complete receipt/source/compiler joins and exact complete-row observer. The existing Phase54 byte comparator's allowed baseline policy needs an explicit Phase55 successor; its exact byte checks are retained.

Native three-source C emission/build/runtime retention remains mandatory under the previously used Clang16 environment. Historical Phase54 native provenance similarly needs a narrow graph02 baseline-policy successor. No runtime669 repeat is necessary if all output bytes remain exact; compiler generation, generated compiler usability and fixed-point status must still be reported separately. No targets are run by this plan, no Phase54 file is modified, and the 103 unrelated protected files remain unchanged.
