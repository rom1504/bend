# Independent occurrence-summary audit

Source review at `4fd100d5cac64e168d0288cde0db04922e858107`. No compiler,
benchmark or checked-API execution was performed for this audit. No production
declaration, runtime or admission condition was changed.

**No semantic blocker found for finite, runtime-valid inputs.** Both candidates
compute the original freshness Boolean. The interval candidate removes the
explicit occurrence-set construction as well as repeated syntax scans. This is
a source-equivalence argument, not an accepted Bend theorem or a performance
result. Type checking, independent finite execution and real-input comparison
remain separate gates.

## Reviewed identities and original contract

The reference is
`selfhost/build/phase142/indexed-source02/compiler.bend`, SHA-256
`15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1`.

| Source | SHA-256 |
|---|---|
| [core-v01.bend](../../selfhost/tools/performance/phase143/occurrences/core-v01.bend) | `e4af503d30605ed798ff1ba0c2184121d5be79b026daf4f8e18a045f4d31fd6b` |
| [range-v01.bend](../../selfhost/tools/performance/phase143/occurrences/range-v01.bend) | `64c6ce1bd8b97de2c26ddbb2bc59164b7248d935ae9ed2b0dd41f9f46cbbeb80` |
| [controls-v02.bend](../../selfhost/tools/performance/phase143/occurrences/controls-v02.bend) | `2c5b29c26dc204697e68e76e758d6a6a6e8e235487b54290d92ca47f981cb0df` |
| [range-controls-v01.bend](../../selfhost/tools/performance/phase143/occurrences/range-controls-v01.bend) | `4d80fd8f77514c29feb017b505835f2c4969965353e194139a1c787c9caf5081` |

Exact reference locations in the pinned assembled source:

| Lines | Contract used |
|---|---|
| 32513–32516 | `nd_comb_fresh`: zero count succeeds; otherwise reject a syntax occurrence or a non-sentinel environment result, then increment `n` and decrement `left`. |
| 31656–31657 | `nc_id(n) = U32.sub(4294967295,n)`. |
| 31678–31714 | Original occurrence traversal and existing `nc_uses`/membership interface. |
| 31470–31511 | Existing persistent Patricia insertion and lookup; exact U32 keys, not probabilistic hashing. |
| 31515–31519 | `nc_word`: first matching binding wins; missing returns the literal sentinel. |
| 5546–5580, 38238–38250 | Actual `ix`, `ks` and `p98_tag_eq` behavior for all three KTerm variants. |
| 30437–30440 | `nt_choose` invokes only the selected branch closure. |
| 32536–32545, 36048, 38410–38416 | Existing callers: an arity-dependent request and two requests for 64 IDs. |

## Modular interval argument

Let `M = 2^32`, with all arithmetic in the following equations reduced modulo
`M`. At original-loop step `i`, the candidate variable ID is
`c(i) = M - 1 - ((n+i) mod M)`. The function `nc_id` is its own inverse.
Therefore, for any U32 `id`, the unique matching step in `[0,M)` is
`i = (nc_id(id)-n) mod M`. The original loop asks exactly for steps
`0 <= i < left`; a U32 `left` never reaches `M`.

Consequently `U32.is_lt(U32.sub(nc_id(id),n),left)` is exact. The proof does not
require a non-wrapping interval or a small count. In particular:

- `left=0` admits no ID, and the public candidates return True before visiting
  syntax or performing environment lookup.
- With `n=MAX`, steps zero, one and two correspond to IDs `0`, `MAX`, `MAX-1`.
- `left=MAX` means `M-1` candidates, not a full cycle; exactly one ID is excluded.
  At `n=0` that excluded ID is zero; at `n=MAX` it is one.
- Signed interpretations are not introduced. The existing Base definitions use
  fixed-width `Word(32)` increment/subtraction and unsigned comparison
  (`bend2/base.bend:1418`, `:1439`, `:1504`).

The 14 explicit interval controls have correct expected results, including both
MAX-count exclusions and the wrapped 64-element endpoint. They avoid attempting
billions of original loop iterations.

## Syntax, environments and evaluation

Both summaries use the same tag test and getters as `nc_occurs`. A `Var` is a
leaf: its ID counts, its malformed raw children do not. A non-Var binder's own
ID does not count, but its children do. `KLambda` has the tag `Lam` and exposes
its children; `KLiteral` has the tag `Lit` and exposes no children. Neither
summary reads removed-name metadata, spans or binder quantities as occurrences.
No binder subtraction or lexical free-variable analysis has accidentally been
introduced: this remains the original syntactic occurrence predicate.

For the set candidate, induction over the same traversal gives membership in
the union of body/argument Var IDs. The reused Patricia operations preserve
exact keys and duplicates do not change membership. This audit relies on that
existing set invariant; it does not constitute a new machine-level proof of its
implementation. The interval candidate instead commutes two finite existential
quantifiers: "some requested ID occurs in syntax" becomes "some syntactic Var
belongs to the requested interval". Negating this predicate yields the original
all-clear condition.

Both environment loops call the original `nc_word` with the original ID
sequence. A first binding whose word literally equals
`NATIVE_UNBOUND_VARIABLE` is still treated as unbound, even if a later duplicate
is non-sentinel. The reverse order is bound. An empty String is bound. Binding
kind is ignored exactly as before. This behavior must not be replaced with a
plain set of environment IDs.

Evaluation and reclamation order can change: the set candidate builds a summary
before checking the first environment entry, and the interval candidate groups
all syntax checks before the environment loop. Only the outer zero-count
branch's avoidance of these computations is explicit in `nt_choose`. This audit
does not depend on a particular backend short-circuit implementation of `&&` or
`||`. On finite pure inputs the Boolean algebra is sufficient; it does not
establish equal allocation, failure timing, stack usage or behavior for forged
runtime pointers/cyclic structures. `@unsafe` and `+` annotations do not establish
those runtime properties. "Allocation-free summary" should mean **no NU_Set
construction**, not that the emitted program performs no allocation or RC work.

## Small additional controls and next gate

The existing 30 concrete cases cover raw Var children, raw non-Var IDs, aliases,
duplicate IDs, argument occurrences, both sentinel-shadowing orders, empty
binding words, high bits and syntax wraparound. Four cheap additions would close
the most useful gaps before integrating:

1. Actual `KLambda` with a colliding binder ID but no colliding child (True),
   plus the same compact variant with a colliding child (False).
2. Actual `KLiteral` with nonzero numeric payload (True); current literal case
   is a generic `KTerm` tagged `Lit`.
3. Empty syntax, `n=MAX,left=2`, with a binding for ID `MAX` (False), then the
   same binding at `left=1` (True). This checks wrapping in the preserved env
   loop independently of syntax.
4. An irrelevant binding before the first relevant duplicate, with different
   `N_WordKind` values, to exercise traversal and confirm kind independence.

No new broad campaign is required to answer these. The highest-information next
gate is to compare all three checked exports on actual captured
`nd_comb_fresh` inputs while requiring the unchanged original compiler's complete
output. Separate count-one/immediate-collision cases from count-64/all-clear
cases. Construction and reclamation belong inside each measured call. Only then
choose a production policy or pay for a native compiler image. The active-context
percentage from the prior profile is not an exclusive cost or an upper bound on
the complete-build gain.
