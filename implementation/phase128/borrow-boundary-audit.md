# Phase128 inverse-wrapper boundary audit

Source-only review of
`selfhost/tools/performance/phase128/borrow/next/restore-boundaries.bend`:
144 lines, 6931 bytes, SHA256
`c545871ba61b999918f66f39fcbdb177d691850656b63e04fce014793e2d3ec4`.
No target execution or build was performed. This review supplements the
[scalar](borrow-audit.md), [borrowed-call](borrow-calls-audit.md) and
[layout](borrow-layout-audit.md) audits; it does not replace their obligations.

No blocking source-level issue was found. The transformation can restore a
verified public observer boundary after a former thin wrapper was inlined into
its callers. It derives the equation from the original direct-function body;
there is no benchmark, SCC or function-name recognizer.

## Exact equation being inverted

A rule requires an original public single-result function with exactly:

```text
result = worker(pattern_of_formals_and_constants)
return result
```

The result name must be identical, with no intervening statements, side effects,
additional outputs or changed return value. Every wrapper formal must occur
exactly once in the worker argument pattern. Non-formal positions must be exact
`N111Const` values, including both low and high 32-bit words. Other locals,
constructor/function IDs and unsupported argument forms decline. There are at
most four formals and eight pattern slots.

For example, the equation `observer(a,b) = worker(1,a,b,0)` permits a later call
`worker(1,x,y,0)` to become `observer(x,y)`. A changed selector, high word, padding
or arity prevents the match. A repeated/discarded formal prevents rule creation.
`p128bi_argument` has a defensive zero return on lookup failure, but the admitted
bijection and exact-length match ensure that branch is unreachable for a valid
rule. It must not become an independently trusted inversion API.

The original equation is established by the checked original direct function.
The selected new observer adapter is independently derived as equivalent to
that original source. Both facts are needed; a structurally matching arbitrary
raw function alone does not grant semantic optimization authority.

## Arguments, aliases and ownership

Actual arguments are existing `N111Value`s, not delayed computations. The inverse
only permutes them back into the original wrapper's formal order. It does not
evaluate expressions, insert/drop references, move effects across statements or
change the caller's destination names. Two distinct formals may receive aliased
actual values; their existing ownership multiplicity is unchanged. The new
adapter's guard then handles those aliases under the already-audited contract.

Constant positions are reintroduced by the wrapper's original equation, rather
than becoming new owning arguments. Because every formal occurs exactly once,
the wrapper neither duplicates nor silently discards an incoming owning word.
Unsupported extra work in a wrapper, including a keep/sink before its call,
prevents rule formation.

The index groups rules by exact old callee identity. If more than one rule
matches the full constant/parameter pattern, the original call is retained.
This avoids an arbitrary choice among competing reconstructions.

## Ordering and exclusions prevent a fallback cycle

`p128bi_walk` processes functions in their existing order. Upon a selected
wrapper, it inserts the replacement group unchanged and only then publishes
the rule derived from the original wrapper. Later unpatched function bodies
may use that rule. Earlier functions cannot call the newly restored boundary.

Generated borrowed readers, new public adapters and copied owning fallbacks
inside replacement groups are never traversed by this rewrite. In particular,
the fallback's original call to the worker cannot be redirected back to its
own adapter, which would create recursion. Ordinary seed additions precede the
first selected replacement and therefore encounter an empty rule index.

The existing `p113d_passes` closure preserves that seed/original prefix and
appends newly admitted ordinary functions. Rules are extracted from the actual
wrapper at its current post-closure position, not from an assumed stale order.
If earlier preparation changes a wrapper so it no longer has the exact two
statements, no rule is published.

`p126bp_complete` still validates the entire final projected function sequence
from an empty ready set. Missing targets, forward/cyclic direct calls, duplicate
identities or argument/result count mismatches remain errors. The inverse
rewrite does not prepopulate a catalogue to bypass those checks.

## Decisive coverage and negative controls

The expected compiler-shaped case is a later caller of an already-inlined
private worker with selector/padding constants. Selection must be established
by a before/after direct-call census or generated QBE: correct output from an
unreached public observer is insufficient. In particular, demonstrate that the
hot caller now reaches the selected adapter and borrowed reader, while its
copied fallback still calls the original private worker.

The important finite rejection controls are wrong low/high constant, argument
arity, mismatched return name, repeated/discarded formal, foreign local, extra
statement and ambiguous matching rules. Ordering controls should show calls
before publication unchanged, later matching calls redirected, and replacement
groups byte-identical. Alias and unique-input ordinary controls should retain
their correct adapter/fallback behavior. Native qualification and runtime gains
remain the parent campaign's separate responsibility.

The selected CPU runtime's failure path was also rechecked: `p111_rt_fail`
reaches `_exit(1)` through `err_post`/`err_fail`, so a helper failure cannot return
a fake scalar and continue. Exact runtime identities and the device limitation
are recorded in [borrow-calls-audit.md](borrow-calls-audit.md).
