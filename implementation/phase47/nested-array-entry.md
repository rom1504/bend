# Array facts at private tree entries

Status: read-only source diagnosis followed by the authorized P47-005 source
checkpoint described below. The counter producer and new compiler candidate are
not executed by this agent. No nested-guard relaxation or speed promise is made.
The parent reports the completed array04 corpus batch0 shows about 1.724× on
local-pair and 1.000× on editdist. This note explains a concrete path difference;
it does not attribute the timing ratio quantitatively.

## The optimized public entry is bypassed

Both saved modules come from `selfhost/build/phase47/array04-full/manifest.json`:

| Module | Bytes | SHA-256 |
| --- | ---: | --- |
| `modules/local-row.mjs` | 148609 | `7c4189c223634ad528b31c2d21f5d0e3ab4dca2cd5de13170d5e59237f482c63` |
| `modules/editdist.mjs` | 147698 | `9fdb5e6dff177aafbd503e79a0a1d9dc1cda19261d101b474ba8a39afb892ebc` |

Their `G["pair"]` declarations are identical. Each contains the newly guarded raw
helper closure, one raw-root marker, and the unchanged old private/generic paths.
The exported editdist bench instead calls `G["batch"]` with a Nat depth and seed.

The `G["batch"]` declaration spans offsets 128325–147059 in each saved module.
Its existing scalar-tree path has its own local `$R_112_97_105_114` (`pair`)
function and the complete handle-based array helper graph. Each tree leaf calls
that local function directly:

```js
{const x3576=$s1;$value=$R_112_97_105_114(x3576,);}
```

That declaration contains no `arrayViewHostGuard`, raw-root marker, or
`regionProofOpen`. Thus positive depths can execute the old private tree and
never attempt the optimized public pair entry. The initially suspected inherited
`regionProof` refusal is not the mechanism in this path. The zero-depth matcher
instead calls public `G.pair`, so the maintained zero-depth variation is a useful
internal contrast. A root marker's presence anywhere in a module is not proof
that a benchmark reaches it.

## Counter experiment prepared before execution

The data-only producer
[nested-array-entry-probe.py](../../selfhost/tools/performance/phase47/nested-array-entry-probe.py)
pins both entire modules, the exact checked API/runtime, acquisition receipts,
source/catalog/attempt identities, and Node. It changes only counter stores and
one wrapper around the existing guard call. Original conditions and bodies remain.
Additional frames/allocations make the derivative ineligible for timing and for
host-introspection conformance claims.

The emitted runner checks the maintained oracle for each point and these static
path predictions:

| Point | Public pair / raw entries | Tree entries | Local tree-pair calls |
| --- | ---: | ---: | ---: |
| local-pair `pair(0)` | 1 / 1 | 0 | 0 |
| editdist `bench(0,17)` | 1 / 1 | 0 | 0 |
| editdist `bench(2,0)` | 0 / 0 | 1 | 4 |
| editdist `bench(3,123)` | 0 / 0 | 1 | 8 |

Separate counters record actual guard invocation, its result, and whether an
inherited proof was present at public or private entries. A mismatch preserves
its observations and fails rather than rewriting the hypothesis.

```sh
python3 selfhost/tools/performance/phase47/nested-array-entry-probe.py \
  selfhost/build/phase47/array04-full/manifest.json \
  selfhost/build/phase47/nested-array-entry04
# Root schedules this through the existing bounded execution queue:
node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/build/phase47/nested-array-entry04/run-entry-controls.mjs \
  selfhost/build/phase47/nested-array-entry04/report.json
```

## Small general composition proposal

The existing [tree emitter](../../selfhost/src/back/js/tree.bend) already has a
complete typed plan at `j_tree_done`: separately checked `fastZero`, checked
successor/combiner in `j_region_term(s)`, and one complete guarded helper list.
`j_tree_shape` proves the two self children, predecessor argument, parallel RHS
scope, and combination. `j_tree_body` implements their existing frame stack.
No new tree recognizer, stack machine, or workload-specific branch is needed.

1. Add a bounded tree entry adapter to the shared array audit. Require the same
   canonical scalar root signature, internal Array.new dependency, full executable
   node audit, and complete helper audit. Audit both `fastZero` and the successor
   plan. Supply the already-proved root definition only to the allowed-call lookup
   so its exact saturated self calls are legal; do not treat an unchecked root
   body as an additional helper. The existing tree proof supplies their recursion
   and demand legality. Unsupported syntax and fuel exhaustion still refuse.
2. Emit one additional lexical raw-tree closure beside the existing handle helper
   declarations. Reuse `j_array_view_normalize_defs`, the private book marker,
   `j_array_view_normalize`, and `j_tree_body`. The raw closure's own scalar `$sN`
   parameters feed the existing tree frame algorithm. Retain the root self Apps
   consumed by `j_tree_enter`; normalize other helper/native Apps consistently.
   Every helper used by that closure must share its raw representation.
3. In the existing exact Succ entry, after its original argument-slot reads but
   before old observable input/dependency checks, add the same fresh host guard,
   existing scalar/predecessor input checks, existing `$s0<32n` bound, then the
   original full dependency guard. On success call the raw closure. On failure,
   fall through to the entire old tree/generic selection unchanged. Keep Zero
   matcher ABI and evaluation unchanged. A proposed distinct activation marker is
   `/* private raw array tree */`.

Estimated scope is roughly 45–70 additional/refactored Bend lines in
`array-view.bend` and the `j_tree_done` assembly boundary, with no runtime change.
This is an implementation estimate, not a requirement to build a new framework.
Keep `j_tree_body` and the old tree path shared. Duplicating helper declarations
adds generated size and compiler work; record those costs alongside runtime.

The raw audit excludes residual callbacks, so this new branch does not need
`j_tree_scope` to open any inherited permission. Keep `arrayViewHostGuard`'s
current refusal when `regionProof` is non-null. The known editdist path does not
need a nested-guard exception.

## Independent qualification and limits

Before timing, require a renamed binary-recursive scalar tree whose leaves
allocate and mutate two local arrays inside a custom record, then return a scalar.
Test depth zero and several positive depths, varied seeds, noncommutative child
mixing, and a leaf helper transferred through distinct countdown/record helpers.
Require raw-tree activation on positive depths and unchanged zero behavior.
Retain public object/refusal, dependency mutation, Number/fill replacement,
late fill-to-Number mutation, numeric prototype setter, and reentry/error controls.
The parallel children must keep their original order and separate local arrays.

A separate future nested-entry API could force both host and dependency guards to
ignore inherited proof (host first, scalar inputs second, fresh dependencies
last), with the old fallback intact. Changing only the current early refusal
would be insufficient because `regionHostGuard`, `localGuard`, and `scalarGuard`
all have proof shortcuts. Temporarily clearing global proof would need strict
finally restoration and no possible callbacks inside the check. Explicit fresh
checks would be easier to reason about. Neither option fixes the measured tree
path and neither belongs in this bounded follow-up.


The authorized initial P47-005 implementation uses exactly the proposed boundary:
net +32 compiler lines (array-view 197→221; tree 1164→1172). Its raw helper closure
is named `$arrayViewTreeBody`; the marker is a statement inside successful entry
immediately before its return. Independent review and root-owned build/controls
remain pending. See the [design](../../design/phase47/tree-array-composition.md)
and [experiment record](../../experiments/phase47/P47-005-tree-array-composition.md).
