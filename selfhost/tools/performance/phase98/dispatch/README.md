# Phase98 shared observations and dispatch

This directory prepares isolated source candidates from the authenticated D04
compiler and authenticates each edited declaration against canonical modules.
It never runs a compiler or generated program. Existing output paths are refused.

```
python3 selfhost/tools/performance/phase98/dispatch/prepare.py \
  --variant hoist-core --out selfhost/build/phase98/dispatch-frozen01
```

`hoist-core` caches `tg(t)` once in each of actual `infer_node` and `check_node`.
Their 20 syntactic observations become two, with all branch bodies and ordered
comparisons retained. The literal fast path in `check_node` additionally observes
the total `tg`. No tag is equated with constructor identity: a generic KTerm with
tag `Lit` remains distinct from a KLiteral for `core_literal`.

The frozen receipt contains exact before/after declarations, source spans, input
hashes, canonical bridges, replay assertions, and static counts. The complete
candidate compiler and canonical module are isolated under the supplied output.
The parent runner owns admission, exact output checks, native code inspection and
timing. Static projection reduction is a hypothesis, not a performance result.

`--variant dispatch-check4` instead extracts ordered pure tag selectors for
`infer_node`, `check_node`, `ka_node`, and `ka_type_node`, then matches the selected
enum in a typed unsafe caller. The original complete branch expressions remain
unchanged. Literal gates stay before tag selection. The infer fallback retains
its original tag/literal diagnostic expression. This costs252 source lines.

`--variant dispatch-wide` adds15 bounded actual callers from core evaluation,
conversion, checker continuations and native lowering. `direct.py` lifts only
complete outer `kc`/`nt_choose` trees into Bool-parameter helpers. Conditions and
both branch expressions remain in order; no observer is evaluated earlier. It
removes85 choice calls across19 functions, costs525 lines, and retains the exact
historical Phase84 native-text rope adaptation in D04. `direct-hot` isolates the
additional15 callers if needed. No generalized syntax rewriting is attempted.

`controls.py --candidate FROZEN_CANDIDATE --out FRESH_CONTROLS` freezes41 independent
full-value expectations and extracts exact selectors, `tg`, `core_literal`, and
complete term observers. It emits compatible genuine-JS runner inputs plus a
native main and exact stdout. Cases distinguish generic Lit from KLiteral and
Efq's shared Mat arm, and keep the original term and escaped tag alive. They do
not execute the unsafe recursive branch bodies or establish universal ownership.

`code-shapes.py` counts exact upstream WL_CASE families without running them. Its
hoist audit confirms fewer tag projections but unchanged closure allocation;
the corresponding six-source screen is neutral and the hoist is unpromoted.

Proof boundary: equality of exact safe term observations is reusable evidence;
it does not establish equivalence of unsafe recursive callers or native reference
count handling. Native complete-value alias checks and compiler screens remain
required. Phase97 `f_find` is deliberately absent from this patch.
