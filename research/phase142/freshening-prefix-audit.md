# Independent challenge: parser hits and freshened-prefix reuse

2026-10-26. Source-only review of Phase141 integrated-source02, SHA256
`f5bfca6d1fe9b378955d6c89ba5ec2428ec1627d7d008eb0c15eac1b51c8a06a`.
No compiler execution, prototype, measured gain, or formal theorem accompanies
this review. The small inputs below are proposed falsifiers, not recorded test
results. This supplements [freshening-boundary.md](freshening-boundary.md).

## Finding

The freshener's composition boundary is sound by inspection. A parser hit alone
is not a sufficient identity certificate for the **completed** prefix. The first
prototype should compare the actual completed prefix exactly, then reuse its
freshened product and ending counter. Avoiding that comparison needs an additional
proof of every completion dependency; it should not be an initial requirement.

The existing proposal already requires the same logical source path and completion
context. Those are material additional conditions, not consequences of the parser
hit flag. No successful, same-context suffix-only mutation of an earlier completed
definition was found in this audit.

## A concrete path falsifier

Use the same seed and this same source text at `/a/main.bend` and `/b/main.bend`:

```bend
import Base

def native.apply(step: U32 -> U32, value: U32) -> IO(U32):
  import "./foreign_runtime_apply.c"
  import "./foreign_runtime_apply.js"

def main() -> U32:
  0
```

Checkpoint after `native.apply`, before `main`. This foreign syntax is present
in `tests/io/foreign_runtime_apply.bend`; the test here concerns loader products,
and does not require executing or linking either foreign file.

`P140PCache` stores source text, scope, origin, tokens and parser state, but no
logical source path. `p140pl_load` derives the same source origin from the same
Base seed. `import Base` supplies the same alias scope. Consequently the parser
hit conditions can remain satisfied after the directory changes. Completion
still calls `f_path_defs`, which recursively rewrites `Path` values inside
`Foreign` bodies using the **current** source directory. The prefix's completed
foreign paths therefore change from `/a/...` to `/b/...`.

This is a source-derived counterexample to `parser hit => completed-prefix
identity`, not a counterexample to the stronger same-path contract. An exact
completed-prefix guard should reject it regardless of whether a separate path
gate was remembered. Absolute foreign paths are a useful positive control.

## Law fills and contextual completion

Local law fills do not provide a retroactive prefix mutation in the current
implementation. `p140p_context_publish` always prepends a newly parsed declaration
to the raw accumulator. A later fill is a distinct event; it does not rewrite
the earlier law event. A small useful positive case is:

```bend
import Base

law claim:
  U32 -> U32

def before(x: U32) -> U32:
  x

def claim(x):
  x

def main() -> U32:
  claim(0)
```

Put the cut before `def claim` and edit its body. Compare complete declaration
events, including the earlier unfilled law, rather than a name-indexed/deduplicated
book. A changed fill can change checking and later fresh IDs without changing the
retained prefix. Full current validation and checking must still run.

Imported fills are also elementwise: `f_graph_fill_defs` maps declarations using
the fixed imported `scope` and `imports`; `f_graph_fill_alias` does not consult
later user definitions. A valid fill can replace its own children with `Nil`,
so only **top-level event count** preservation is justified. A flattened count
including constructor children is not a safe cut. Changed imported law/type or
alias context must miss; retain an imported-fill test even though the ordinary
P86 loader restricts imports to Base.

There is a real error-path dependence. `f_context_result` passes
`String.is_empty(error)` to `f_context_defs`. Complete parses lower declaration
types with `f_context_lower`; incomplete/error parses retain their contextual
forms. Appending an invalid body after an unchanged prefix can therefore change
how that prefix is represented before validation. Never splice a successful
freshened prefix into an unsuccessful completion, and never publish a freshening
checkpoint from an error product. Compare the original complete diagnostic on
invalid suffix and subsequent recovery.

Module qualification is likewise elementwise but depends on `ns`; path
qualification depends on the source directory. Neither dependence is a reason
to reparse unchanged text, but both belong to completion identity.

## What an exact prefix guard buys

For the first prototype, retain a private product of a successful old request:

```text
(producer/seed identity, n0, complete top-level cut,
 actual completed prefix P, fresh(P,n0) = (FP,n1))
```

For a new request:

1. Preserve the existing parser gates, including first-token/lookbehind checks.
2. Complete and validate the current source normally. Do not shortcut errors.
3. Split its actual completed user fragment at the certified top-level cut.
4. Require exact current-prefix equality with `P`, including definition variants,
   all fields, child definitions, term fields, quantities, flags and source spans;
   require the same actual starting counter `n0` and trusted producer/seed.
5. Reuse `FP,n1`; freshen the **entire current tail**, then join the products.
6. Otherwise use the original full freshening path. Failed requests retain the
   previous successful capability rather than publishing partial state.

The guard reduces the correctness premise to equality of the freshener's actual
input. It covers overlooked completion dependencies without claiming that raw
parser-prefix equality is enough. Comparing headers, names, textual prefixes,
counts, hashes or already freshened inputs does not provide this guarantee.

This still scans the prefix and retains an additional graph. The expected saved
work is term renaming/reconstruction and associated allocation, **not all prefix
work**. Charge comparison, retention, split/join and cold acquisition costs in
the discriminator. A native identity shortcut may make equality cheaper but is
not required for correctness and must not be assumed in the cost estimate.

## Freshener boundary and smallest test set

`ffd_walk/type/value/frame` process a declaration's type with empty environment,
then its value with empty environment, then all children before the next
top-level declaration. Only the global counter crosses that completed boundary.
`ffw_*` has no book lookup. Thus the documented compositional equation follows
from this traversal; it is not a proof permitting cuts inside All/Lam/Let or a
constructor-child list. New suffix binders must change later IDs and the final
counter exactly as a complete freshening would.

The cheapest differential screen should compare the entire `FFreshDefs`
(including final counter), then the complete loader product, for:

- A late body edit with All/Lam/Let and nested constructor children before the cut.
- The local law/fill example and an imported-law fill with a changed imported type.
- Relative foreign paths with the same versus changed logical directory.
- An invalid suffix followed by recovery; no success cache published on failure.
- A suffix binder-count change, UTF-16/non-BMP spans, and a prefix edit forcing miss.
- A changed first suffix token that can extend the prior expression: preserve
  the existing operator/lookahead refusal rather than treating every raw offset
  as a complete declaration boundary.

Relevant selected-source anchors: `f_context_result`11897,
`f_context_defs`11903, `f_context_modules`11915, `ffd_walk`14084,
`f_path_defs`14209, `f_graph_finish_indexed`14671,
`f_graph_fill_defs`14895, `f_prefix_trace_validated`15561,
`p140p_context_publish`58443, `p140p_scope_same`58645,
`p140p_resume_lexed`58760 and `p140p_resume`58777.
