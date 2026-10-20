# Bounded local resume helper

Optional source-only profile, frozen in `modules01.json`. It composes on the
unchanged recursive04 modules and keeps that narrow route first. No compiler or
program has been executed by the author. Coordinator receipts determine actual
admission, complete outputs and performance.

`P114GPlan` separates the original descent body from one continuation identity,
its ordered capture names, its incoming result, its pop-result name and its
checked resume body. Entry arity and capture count are each bounded by eight.
The original `p112f_cont` parser limits the continuation to 128 statements.
`p112w_scan` authenticates scalar/runtime operations and terminal calls to the
existing immutable private-worker registry. An additional traversal rejects
every `Again`, a call to the recursive owner, or a private call above eight args.
The owner itself must not be in that ready registry. Thus the resume helper
cannot introduce a native recursive edge back into this region.

Each descent retains its exact capture stores and frame call, then transfers
arguments through the existing parallel snapshots. A local depth counts these
frames. At a result, `pop(count+1)` removes the same captures and FID as the
original return plus continuation pop. All captures are loaded into fresh
argument locals before invoking the resume helper. The helper first reproduces
the original pop result zero, then restores capture locals in order and the
incoming result local. This also preserves the case where a later restored local
overwrites the pop destination. The original safe resume instructions run in
their original order. A resulting Term is fed back to local unwind; a private
terminal call returns its one owning Term to the same point.

The native stack is bounded by the main worker, one resume helper and the
already admitted private call graph. Existing private self-tail loops remain
loops. The explicit worklist still occupies `count+1` words per recursion level;
allocation order, sealing and failure behavior remain with the original runtime.
Each helper has a fixed scratch buffer. Pure Boolean diamonds reuse source31's
explicit width legalization. No global register, next-FID or result-count update
is observable by the admitted helper body. Exact copied failure suffixes retain
the pinned sequential CPU fail-stop premise.

The primary new witness is the unchanged list pipeline's `keep_gt1`. Its actual
recursive04 QBE captures two head aliases, descends first, then computes the
predicate and calls the admitted `keep_gt1.at`. The prototype preserves that
strict order. This is a broader continuation than an immediate constructor; it
does not move the predicate before recursion or infer a new ownership fact.

The sole override remains `p113e_public_chunk`. Existing complete direct entries
and narrow recursive04 entries retain precedence. Unknown calls, recursive
resume edges, multiple frame sites and unsupported prefixes retain the exact
prior fallback. The independent original/program verifier remains mandatory.
The internal reflected plan is not a public certificate for arbitrary IR.

The inspection export is `p114g_inspect_request`. The sibling `inspect.mjs` uses
the same arguments and authenticated ordinary frontend transport as the narrow
driver. Its entries report possible general plans; public emission may choose
the already qualified narrow plan first. Full native output and actual called
worker inspection remain separate gates.

This representation leaves a bounded continuation-table extension possible:
record several `(FID, capture layout, resume body)` cases, pop the exact saved
FID, restore its matching layout, and dispatch locally. Two-child recursion
would also require a resume body that can push another frame and descend. That
needs a larger local control plan and is deliberately absent from this profile.
