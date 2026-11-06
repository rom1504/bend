# Branch-thunk hypothesis: already optimized in the selected compiler

Bounded read-only audit, 2026-11-06, source frontier `fbdf8a0`. No compiler
target or benchmark was executed. The supplied Phase170 native-chain receipt
identifies the exact installed image and its retained QBE. The offline census is
in [choice-frontier.json](choice-frontier.json).

**Do not implement another `nt_choose`/`f_choose`/`kc` specializer.** The selected
native lowering already expands these small selector computations structurally.
There is no evidence that two branch closures plus a generic chooser call remain
at each compiler conditional.

## Actual source-to-QBE trace

- [`nt_choose`](../../selfhost/src/back/native/text.bend#L12),
  [`f_choose`](../../selfhost/src/front/lexer.bend#L68), and
  [`kc`](../../selfhost/src/core/term.bend#L82) match a Boolean and invoke one
  Unit callback. Their result-type argument is erased; their three remaining
  arguments fit the native bounded selector interface.
- [`nd_ref_arity`](../../selfhost/src/back/native/direct.bend#L266) dispatches
  saturated calls to `nbc_saturated` in
  [`closed-match.bend`](../../selfhost/src/back/native/closed-match.bend).
  The latter requires at most four actuals and at least one literal lambda.
- `nbc_definition` obtains the original source body. `p152c_source` and
  `p152c_select` require a bounded, closed selector body, matcher structure,
  applicable argument usage and fresh IDs. The prepared-static correspondence
  gate permits only independently authenticated nullary constructor substitution.
  These are structural gates; they do not recognize helper names.
- `nbc_evaluate` puts **nonliteral actuals into ordered outer lets**. Literal
  lambdas are substituted only under the closed-selector usage conditions.
  `nbc_expand_match` distributes applications through exclusive nullary matcher
  arms. The ordinary beta/match lowering then emits local branches. This matters:
  replacing arbitrary computed callback expressions with lazy branch bodies
  would change their strict construction/effect order, and is not what this gate
  allows. Stack-safe scheduler targets still use their ordinary target lowering.

The exact installed QBE is 97,488,970 bytes, SHA-256
`661b62664acdac83d12bc3192b5f9113a2bb946dd331433e64ca0452f6f83850`.
Its 60,569 function names, decoded from the decimal `FID` encoding, contain no
`nt_choose`, `f_choose` or `kc` function. The remaining names containing `choose`
belong to different computations (`j_fusion_choose`, `p140sp_choose`); a
`Bool.pick` worker also exists. Names alone would be insufficient evidence, so
the census also inspects actual verifier workers:

| Actual generated function | Conditional branches | Closure helper calls | Apply helper calls |
|---|---:|---:|---:|
| `$direct.p111v_counted_call` | 8 | 0 | 0 |
| `$product.p111v_counted_call` | 8 | 0 | 0 |
| `$direct.p147v_counted_call` | 8 | 0 | 0 |
| `$product.p147v_counted_call` | 8 | 0 | 0 |

These source functions contain nested `nt_choose` applications. Their local
branch implementation is direct counterevidence to the proposed blanket cost.
The latest full caller capture has zero physical leaf samples attributed to
`p111_rt_closure` and `p111_rt_apply`, versus 94 to `p111_rt_jump`. That does **not**
prove zero closure cost, and does not assign every scheduler transition to a
conditional. The complete QBE still contains 22,264 closure and 7,769 apply
static call sites; many are ordinary factories/wrappers. Static totals do not
establish dynamic hotness.

This is separate from the JS-only `j_choice_call` recognizer and Phase121's
restricted U32 closure-factory-chain fusion. Extending either based merely on
the abundant source spelling `nt_choose` would repeat work already removed by
native closed-selector lowering.

## Next opportunity and required evidence

The current static-seal experiment is more discriminating: it removes an actual
runtime wrapper allocation for immutable static graphs, whereas this chooser
hypothesis asks to remove closures absent at the inspected sites. Finish its
same-machine-object tests and full request comparison before another compiler
image acquisition.

Beyond that, the strongest general **hypothesis**, not a measured gain, remains
eliminating owned reconstruction across an actual hot producer/consumer
boundary. `k_with_children`, `k_with_span` and `k_rebuild` in
[`core/term.bend`](../../selfhost/src/core/term.bend#L666) expose concrete
replace-fields operations. A useful next audit would identify an actual hot
caller where the old term is dead, the replacement consumes the same retained
fields, and the current generated path still takes/seals/allocates/drops those
fields. The desired transformation preserves an owned constructor destination
through that complete computation, with a normal shared/static fallback.

This is **not** a recommendation to revive generic cell credits or declare all
`+t` parameters uniquely owned. Borrowed source APIs and surviving aliases may
make the proposed reuse impossible, while existing destination optimizations
may already cover eligible sites. First require dynamic ownership attribution
and one actual before/after code slice establishing missing reuse. If either
fails, reject the experiment. Existing broad ownership sample shares are not a
valid gain estimate for this narrower transformation, and nothing in this
audit establishes an 80-second saving or a route to 100 seconds.

The census is reproducible without execution: parse the retained QBE's
`function ... $symbol(...)` blocks, decode each `_FID_` numeric suffix, count
`jnz`, `call $p111_rt_closure(` and `call $p111_rt_apply(` per block, and sum
matching `leafSymbol` rows in the pinned caller-matrix JSON. The JSON records
both input hashes and the exact examples so subsequent artifact changes cannot
silently redefine the observation.
