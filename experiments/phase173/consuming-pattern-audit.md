# Consuming pattern substitution: independent source audit

Reviewed `selfhost/tests/phase173/borrow-consuming-pattern01.bend`, SHA256
`41aa5051cb13258c1602d19762c622d6fbd24b42b84d56e29727f4c95fd20af7`,
against canonical `selfhost/src/front/elaborate.bend:f_pattern_sub` and the
`KTerm` accessors/rebuilders in `selfhost/src/core/term.bend`.
No target was run and no production source was changed by this audit.

**No semantic blocker found.** The replacement preserves the signature and
changes only decomposition of the source record. The equivalence argument has
three cases:

| Input variant | Original behavior | Replacement behavior |
| --- | --- | --- |
| `KTerm` | Test exact `tag == "Var"` and matching ID; on a hit call `f_pattern_value(value, begin, end)`, otherwise replace children only. | Same predicate, same unchanged hit helper, same unchanged list recursion and all eight original fields. |
| `KLambda` | `tg` is always `"Lam"`; recurse through children with `k_with_children`, preserving quantity-presence and metadata. | Always recurse through children and preserve name, ID, quantity, removed names, both spans and quantity-presence. |
| `KLiteral` | `tg` is always `"Lit"`, `ks` is empty, and `k_with_children` returns the literal unchanged. | Return the original literal unchanged, regardless of its arbitrary kind, number, text and spans. |

Induction over the finite child lists therefore yields the same complete term
values. The recursive list helper is unchanged. This is a source-level argument,
not a BendTT-checked theorem or a proof of backend correctness.

Particularly important preserved behavior:

- A `KLiteral` whose kind is `"Var"` is still not a variable.
- A `KTerm` tagged `"Lam"` remains a `KTerm`, rather than becoming a `KLambda`.
- A lambda's ID does not stop recursion or shadow this substitution: the
  original helper also traverses those children unconditionally.
- A matching variable with children discards those original children and does
  not recursively substitute inside the replacement. Only the unchanged
  `f_pattern_value` processes that replacement.
- Occurrence spans are passed unchanged to `f_pattern_value`. Its existing
  positive-begin rule determines whether replacement spans are overwritten;
  zero-begin occurrences retain the replacement's original spans.
- An unknown tag, static tag, nonmatching variable, removed-name metadata and
  explicit/implicit quantity information retain the original behavior.
- The function signature still permits sharing. Consuming its current ownership
  token must not mutate a separately retained source/replacement alias; ordinary
  checked lowering and runtime ownership remain responsible for that contract.

The eight new complete-value source controls cover the literal-kind trap,
arbitrary literals, variable hit/miss with children, legacy and specialized
lambda variants, quantity-presence, spans and unknown tags. The existing AST
workload additionally retains input and replacement aliases. Compare all output
fields with the original independent upstream execution, then use the same
native complete-output gate. No full compiler qualification is implied.

The hoped-for ownership benefit still needs generated-code evidence. The new
source does not explicitly retain the old `KTerm`/`KLambda` parent across child
recursion, but the literal branch still returns `t`. The compiler's branch
liveness and lowering determine whether other arms actually avoid keeping the
parent. Count or inspect that work rather than treating the source rearrangement
as proof that it disappeared.

## Backend transfer: `nq_layout_subst`

Independently reviewed `borrow-consuming-layout01.bend`, SHA256
`b32ec3101ac39c4982af1c809f86f29e478dba32e00ff196d8cbac808311d7f1`,
and its helper prelude, SHA256
`152bf8b28198f151996832a3e044fd3c0d689456da5b2edcc87fd638fe0f722e`.
No semantic blocker was found. This is source review only, with no target run.

This substitution differs from `f_pattern_sub` in two important ways. The
variant preserves both exactly:

1. A `Var` with a nonmatching ID returns unchanged, even if its child list is
   nonempty. It does not descend into those children.
2. A matching `Var` returns `value` unchanged. It does not apply occurrence
   spans or traverse the replacement through `f_pattern_value`.

The original outer `p98_tag_eq(t,"Var")` branch and its nested ID test remain
unchanged. Only the non-Var branch enters `p173nq_owned`. Its KTerm and KLambda
cases supply precisely the fields that the original accessors passed to
`k_rebuild`, with recursive substitution of the same child list. KLambda's
quantity-presence bit survives. Both the original `k_rebuild` and the new
literal arm return any `KLiteral` unchanged; a literal kind named `"Var"` is
not a variable. No beta reduction or other evaluator is introduced.

The private helper is equivalent on its admitted non-Var inputs; it should not
be advertised independently as a general replacement for `nq_layout_subst`.
The surrounding `nq_layout_subst_small` expansion check and evaluator fuel are
untouched. The complete-value workload includes variable hit/miss with children,
arbitrary literal kinds, legacy KTerm-lambda and KLambda variants, retained
aliases, absent IDs, metadata and replacement observations. The independent
full-output gates and emitted ownership evidence remain necessary before
performance or integration claims.
