# Phase140: binding ripple, the warm-build floor, and render dependencies

This is an independent source/artifact audit, not a compiler optimization or a
performance experiment. No compiler, generated program, or machine build ran.
The inspected selected source is
`selfhost/build/phase137/integrated-source03/compiler.bend`, SHA-256
`2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38`.
Line references below refer to that exact source. The root campaign owns new
implementation and measurements.

## What the historical edit really invalidated

Phase132 changed `%result` to `%answer` in the compiler's generated main-function
text. The [original census](../../phase132/incremental-evidence/census.json)
found 476 changed QBE functions. Its first classification explained 377 through
changed `copy` operands and left 99 unclassified.

[literal-graphs-v01.py](literal-graphs-v01.py) streams those 476 bodies and the
two static images. Its [complete receipt](literal-graphs01.json) authenticates
all inputs and records the result:

| Observation | Result |
|---|---:|
| Changed functions | 476 |
| Changed numeric operands | 1,995 |
| `copy` / `store` / `call` / other operands | 1,732 / 96 / 82 / 85 |
| Changed operands denoting exactly equal decoded values | 1,995 |
| Previously unclassified functions explained | 99 / 99 |
| Rejected non-numeric instruction changes | 0 |
| Static-image words, old / new | 45,977 / 45,989 |
| Reachable constructor nodes decoded in each image | 2,974 |

Every differing operand in those bodies is a valid static constructor reference
whose offset changed while its complete reachable constructor value stayed
equal. The comparison checks identical constructor-arity tables, valid tags and
bounds, exact leaf bits, disjoint node extents, and backward DAG edges. It
interns exact structural tuples across both images; it does not infer equality
from a numeric delta or a hash alone. Non-numeric instruction text and line
counts match for each compared function.

**This is not whole-function equivalence.** An address that is unchanged in an
instruction can refer to changed pool contents. This audit examines changed
operands, not every literal dependency in every function. In particular, the
actual edited string can change behind an unchanged address. Replacing numeric
addresses with an arbitrary normalized number is therefore not a sound cache
key. A semantic constant reference must include its complete value dependency,
and final relocation must still bind the current image.

The result strengthens the case for retaining symbolic constant identities
before numeric placement. It does not justify a textual QBE cache or skipping
the final verifier. Equal-length source strings also do not guarantee stable
placement: this edit grew the pool by twelve words.

## What must disappear for a 5–10× warm build

The current [Phase137 cold reference](../../phase137/README.md) is 346.391s.
A 5× warm loop needs about 69.3s; 10× needs about 34.6s. These are targets for
changed-source work with a fixed qualified producer, not cold-build forecasts.

The older [Phase135 native edit](../../phase135/README.md) spent 175.080s in
frontend work, 62.179s in raw preparation, 68.360s in later optimization, and
72.677s in rendering/writing/backpressure. Its 92% late-cache hit rate did not
make the complete edit faster. The cleaner [Phase136 stage run](../../phase136/README.md)
measured 152.111s of frontend work, including 44.745s parsing and 53.149s
checking. These are historical decompositions, not a new decomposition of
Phase137.

Consequences:

- Eliminating the historical render interval alone saves at most 19.2% of
  Phase135's request interval: about 1.24×, before cache overhead. It is a useful
  bounded step, not a route to 5× on its own.
- Object reuse acts after expensive Bend work. Its own matched warm improvement
  cannot be added to a native-stage percentage, and partitioned cold compilation
  was slower than the monolithic backend.
- A 5× loop must avoid most unchanged parsing/checking **and** backend
  preparation/rendering. Matching owners only after whole-source preparation
  cannot meet that target while these costs remain.
- The first worthwhile milestone is a causal warm saving with independently
  exact output, total A→B cost, acquisition cost, and retained-memory cost.
  Partial-stage or hit-rate wins should not stand in for this milestone.

There is already a native retained-state vehicle: Phase134's
`session/session-v04.bend` retains the prepared Base seed and the typed
`P134UCache` between two source requests; Phase135's
`machine/session-v01.bend` adds framed output. Both inputs are read before
outputs are opened, and each sealed result is drained and closed before the
next write. This is an experimental session, not the selected Phase137
ordinary CLI. It retains late optimizer state and still runs `p86_plan` for B.
Extending its typed result/cache boundary is smaller than building a daemon or
serializing unchecked compiler objects, but does not itself supply early reuse.

## Low-cost real edits and falsifiers

Prefer edits that change executable compiler behavior without adding binders,
constructors, signatures, imports, or names. Concrete starting points in the
selected source are tighter existing profitability limits:

1. `p113i_eligible` body-size limit 512→511 (46799–46804).
2. Its stack-size limit 8192→8184, tested separately from the first edit.
3. `p112c_try` fusion-site limit 8→7 (43879–43882).

These decline some optimizations rather than changing the language's semantic
admission rules. They are meaningful policy edits, but are deliberately related
fast falsifiers, not a sufficient three-family representative edit set. Tight
boundary controls should establish the intended changed behavior. Generated
program speed can regress when profitable inlining/fusion is declined, so these
are experimental source revisions, not automatic production recommendations.

Even these edits are **candidates** for stable bindings, not assumed stable.
Compare actual ordered checked/header observations and fresh counters, exact
prepared owner identities, FID/CID maps, static image dependencies, full fresh
QBE output, and the reuse mask. A global-name or placement change must invalidate
the affected cache. The cheapest negative controls change a used signature,
continuation body, formerly missing continuation, or current literal value;
they must refuse a stale hit even if the owner text is unchanged. An edit to an
unused unrelated owner should demonstrate the converse without bypassing checks.

## Public rendering: a bounded exact dependency rule

The root's proposed render cache has a concrete source-level boundary.
`p134e_public` (57928–57935) is a pure function of its exact `N111Segment` and
`P134Context`. The context stores `ids,index,direct,ready,view,lookups,heap,mode`.
Mode zero uses `p112c_plan_index`; the admitted path uses `p124r_public`
(52846–52855), whose fallback chain tries the existing H/R/G/local-resume plans
and finally ordinary fusion. Keep all non-index context values exact once per
revision; including `lookups`/`heap` is conservative for this public route.

The only seven renderer-reachable reads of the fusion index are:

| Lookup site | Where its name originates |
|---|---|
| `p112f_target`, 43221 | `P112FusionFrame.name` |
| `p112c_target`, 43868 | Same frame name |
| `p114r_finish`, 49169 | The frame found by `p114r_scan_frame` |
| `p114r_hygiene`, 49273 | That R plan's continuation |
| `p114g_finish`, 49528 | The frame found by `p114g_scan_frame` |
| `p114g_hygiene`, 49552 | That G plan's continuation |
| `p114h_close_seen`, 49898 | A frame discovered while closing the region |

Both frame parsers, `p112f_frame` (43057) and `p112c_frame` (43850), take the
name directly from **argument index 1** of a call to `p111_rt_frame`, specifically
an `N111FuncId`. They do not derive an index key from a string prefix or a helper
symbol. `p112g_finish` (44152–44159) preserves that name while stripping a pure
tail gap. `p112f_value` (42982–42985) renames only local variables; FuncIds stay
unchanged. `p124r_resume_found` (52773) retains the original continuation name;
its separate tail target is resolved through the independently retained ready
view.

The index lookup implementation (42878–42914) resolves one exact name using its
hash and first matching bucket entry. Index construction and lookup are the only
code that destructures `P112FusionEmpty/Leaf/Node` or calls its internal bucket
lookup. The compatibility `p112f_find` at 42972 has no callers in this source.
No public-render path scans all index entries.

**Transitivity is necessary.** `p112c_scan_try` (43896) rescans copied continuation
bodies after successful fusion. `p114h_close_found/close_cont/close_scanned`
(49905–49935) scans fetched continuation bodies and queues their frames. Checking
only the original segment's direct frames would be unsound.

A sufficient conservative certificate for the inspected source is:

1. Match the exact original segment and the full fixed non-index context.
2. Walk all branches of its body and collect literal FuncIds at argument 1 of
   `p111_rt_frame` calls. Collecting even currently inadmissible frames is safe
   extra invalidation; no need to duplicate frame-admission semantics.
3. For each name, call the actual `p112f_index_get` in both contexts. Require
   exact equality of `None` or the **complete returned segment**: name, arity,
   result, incoming count, flags and body. Do not substitute source-list
   membership or body-only equality for the index's real duplicate policy.
4. Recursively collect frame targets in every fetched segment, with a visited
   set. If a 64-name budget or any structural guard is exceeded, render fresh.
   Reaching the budget must never admit a truncated dependency set.
5. Retain fixed producer, runtime, optimization-policy and schema identities.
   A new renderer implementation invalidates this source-audited dependency
   contract. This is not a permanent guarantee about future passes.

Collecting every FuncId is also conservative, but creates unnecessary
dependencies on ordinary calls that only use the already matched ID/ready
maps. Frame-only collection is supported by the complete seven-site audit for
this pinned source. Local QBE numbering is not hidden mutable state:
`p111q_segment` (40724–40728) initializes its own `P111QCode` counter to zero.

Store authenticated rendered bytes outside Bend's retained linked Strings and
let Bend return a validated previous-unit ordinal. The host may copy those
bytes, but must not decide semantic cache eligibility. Bind each ordinal to its
prior successful producer, unit identity/order, payload length/hash, and current
session; retain current global data/main/dispatch products. A failed producer
cannot publish a successful build merely because some payloads were reused.
This removes repeated rendering only: it does not authorize skipping checks,
lowering, independent final verification, or changed global binding work.

The smallest decisive test is a small two-request session with exact fresh
output and deliberately mutated transitive/absent frame dependencies, followed
by one real compiler edit. Measure dependency discovery/equality cost as well
as saved rendering. If full global-context equality almost always fails, or
proof construction costs as much as rendering, this bounded cache should be
rejected before a larger cache architecture is built.

## Review of the bounded v02 extension

The experimental `render/reuse-v02.bend` also keys legacy workers, table headers,
128-datum data slices, table closing text and the fixed main text. These are
additional pure rendering boundaries, not authorization to reuse an old static
image wholesale:

- `p134e_legacy` (57922) reads the exact segment/worker plan plus mode, direct
  view and IDs. The key compares all segment fields, plan validity/calls/params/
  worker statements, rank and sites. Rank/sites are conservative extra fields.
- `p134e_next` (57937–57955) renders a table header using only name, alignment
  and export status. Its body remains a separate current cursor.
- `p134e_data_slice` (57965–57971) consumes at most 128 datum constructors.
  The key must distinguish byte/word/long/relocation/zero variants, both halves
  of a long, relocation symbol and offset, and the first-separator flag. A
  difference at datum 129 permits reuse of the first slice only; the following
  slice must see the changed datum.
- Empty-data closing text and `p111q_main()` have no per-request payload inputs.
  Their reuse depends on a fixed producer epoch. Current cursor progression and
  legacy newline metadata must still follow the original renderer exactly.

The existing `f_fresh_prefix_exact_defs` comparator is **not** fully variant
exact for KDef: a legacy `KDef` with an IndexLeaf getter view can compare equal
to a compact `KIndexLeaf`. Present lookup compatibility does not establish a
general exact-context contract. The root was asked to add variant checks at
every recursive KDef node; the new finite controls deliberately test this
collision at the root and beneath an ordinary parent. No production comparator
was changed by this audit.

Independent experimental controls are in
`selfhost/tools/performance/phase140/render/controls-v02.bend`: the original
`p140rc_controls` contains 25 rows and `p140rc_extra_controls` adds 24 rows.
Besides key mutations, they compare actual `p134e_next` cursor progression with
`p140r_skip`, exercise 64/65 continuation limits and cycles, and verify old
ordinal reuse creates the correct new ordinal. These synthetic IR tests check
cache decisions; they are not semantic admission certificates for arbitrary
constructed IR. Delimiter checks passed during preparation. Compiler checking,
finite execution, differential output and native measurements belong to the
root campaign and were not run by this audit lane.
