# Typed comparison: bounded independent source audit

Reviewed `compare/typed-v01.bend`, `compare/typed-controls-v01.bend`, and the substitutions in `verify/core-v04.bend`, `render/reuse-v04.bend` and `render/registry-v05.bend`. Reference comparators are the unchanged `p134v_*` declarations at lines58229–58323 of the selected Phase137 source, plus the preceding Phase140 scalar header/constructor/render comparators. No target execution was performed for this audit.

No semantic discrepancy was found. The change specializes the generic higher-order list comparison to concrete element types. It does not use pointer identity, weaken equality to hashes or selected fields, or introduce new native calling conventions.

| Compared value | Coverage checked against the original |
| --- | --- |
| `N111Type` / `N_WordKind` | All3 type and4 word-kind variants; unlike variants remain unequal. |
| `N111Value` | All5 variants; both constant words, exact names and variant identity retained. |
| Argument / binding | Type/value and ID/name/kind respectively, in original order. |
| `N111Stmt` | All9 variants and every field, including call arguments, branch order, memory offsets, allocation size/alignment and nested statement lists. |
| `P113DStmt` | All5 variants, result/again distinction, result destination order, call target and argument order. |
| Function header | Name, ordered complete bindings, result count and public flag. Body exclusion is intentional and matches the original header predicate. |
| Complete function | All header fields plus complete ordered body. |
| Raw segment header / constructor | Name and all original numeric metadata; constructor name/arity/hot flag. |
| Concrete lists | Exact empty/nonempty shapes, head comparison then ordered tail comparison, original `&&` behavior. |

The recursive routines retain `@unsafe` where the original recursion was unsafe; this is not an additional termination or stack-safety proof. String, integer and Boolean comparisons retain the same operations. No admission based on equality is broadened by the source changes reviewed.

## Call-site substitutions

`verify/core-v04` was compared with v03, isolating the typed-comparison changes from the earlier metadata-cache extension. Raw bodies use `p140e_scalars`; metadata contexts use exact raw headers and constructors; direct contexts use exact headers; unchanged-body reuse uses full function equality. These are the same judgments as before.

Render v04 replaces table, worker, datum and string list calls with concrete recursions over the same original element predicates. Scalar/private-function comparisons use their complete typed equivalents. Registry v05 substitutes raw-header, constructor and U32-list equality; its already first-order string predicates and Boolean comparison remain unchanged. No higher-order `p134v_list`, scalar or function comparator remained in these three updated files at review time. This statement does not claim that all generic comparisons elsewhere in the compiler have been replaced.

## Controls and integration caveat

The19 proposed controls compare all pairs in finite value/argument/binding/statement/function/header/constructor sets against the original predicates, include nested branch differences, and test list shape and empty/nonempty mismatches. This is useful differential coverage, not exhaustive mutation of every field or a formal equivalence theorem. Some scalar variants have only one representative, so their same-variant field checks are established by the source review rather than independently exercised by those matrices. No extra tests that merely duplicate every line of the implementation are required by this audit; the existing integrated exact-output and negative-invalidation gates remain relevant.

An integration name collision was found: `p140ec_controls` was already the erasure-control export. The coordinator assigned a separate `p140tc_*` prefix for the typed controls, preserving the five existing erasure gates rather than silently replacing them. The renamed source and its checked API/finite receipt must be bound independently; this note makes no claim that those later executions have completed.
