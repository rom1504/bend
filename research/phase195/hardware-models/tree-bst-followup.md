# Tree/BST follow-up: measure the path before selecting another model

This pre-capture assessment led to the authorized
[current-product profiles](tree-bst-profile-results.md), which now identify
constructor inlining boundaries and a small inorder share. The original
missing-observation assessment below is preserved as the decision trail.

Offline inspection of the actual Phase195 N1-produced `native45-01` products
finds no newly established hot straight-line kernel for a useful simulator A/B.
Tree's existing resume-transport hypothesis survives in the new machine code;
BST still mixes traversal, zipper construction and ownership paths whose dynamic
weights are unknown. The next distinguishing observation is exact-product
profiling/path attribution, not another flattened whole-function model.
No target, compiler, sampler or simulator ran for this note.

## Current gap and surviving machine work

Fresh four-round `broad-runtime02` medians, milliseconds per invocation:

| Case | N1 candidate | C | QBE | Candidate/C |
| --- | ---: | ---: | ---: | ---: |
| tree-bitonic | 0.515432 | 0.164908 | 0.390555 | 3.12558 |
| BST32 | 0.025450 | 0.006035 | 0.016705 | 4.21734 |
| BST64 | 0.027969 | 0.007344 | 0.018446 | 3.80856 |

All three tree sizes have family ratio3.158785× C; both BST sizes give4.007740×.
This is a whole-program gap. The current and baseline products plus exact C/QBE
references were SHA-verified against the fresh runtime receipt.
[Evidence and narrow compressed disassemblies](tree-bst-evidence/evidence.json)
retain their identities, current acquisition/runtime/profile receipt pins,
function inventories and reference-substitution calculations.

Current tree `p114r:$direct.warp` still has557 decoded instructions versus QBE302;
`p113d:$direct.warp_zip` has298 versus205. Counts include alternative/error paths
and alignment instructions; they are not dynamic work. Current warp has the same
instruction count and helper-call census as Phase194. Its concrete resume path
loads the post-pop SP from `[r12+0x10]` at `0x411ee6`, `0x411eee`, `0x411ef7` to
restore three captures. No call intervenes. QBE's corresponding resume retains
its cursor across loads. This narrowly bounded block is technically modelable,
but its dynamic frequency and fraction of the new product's runtime are absent.
It repeats the already proposed SP-snapshot experiment in
[remaining-findings](../profiles/remaining-findings.md), not a newly discovered
opportunity. Current warp_zip still calls take2 and ctor2 at three static sites
each; cold/error paths mean those counts cannot establish per-visit allocation.

Current BST64 `p113d:$product.bst.down` has154 instructions and retains take3,
two ctor3 and two ctor2 static call sites, versus QBE214 with the same helper
classes/counts. The x86 function is shorter here while the program is slower.
`p113d:$direct.bst.up` has205 versus QBE140 instructions; its take2/take3 and two
ctor3 calls also remain. `p114r:$direct.inorder` has171 versus QBE98 and one take3
site. These are competing plausible physical costs, not sampled hot owners.
C's corresponding workers inline representation/ownership logic and retain
allocation/hand-off/RC paths; fewer separately named helper calls cannot prove
less semantic ownership work. A comparative whole-function MCA loop would
artificially execute mutually exclusive branches and ignore helper bodies.

## What the retained profiles do and do not establish

The existing Phase194 tree profile puts338.066µs in generated workers and
186.674µs in named ownership/product helpers, versus QBE266.709/76.457µs.
Within x86, ctor2/take2 account for95.330/85.322µs and warp121.622µs.
These support tree ownership and continuation transport as large categories.
They do not identify removable work or current N1 branch/ownership frequencies;
the tree profile also retains2.147% unknown weighted samples. There is no BST
capture in these retained Phase195 priority/remaining profile pools. Source
inspection shows insertion consumes/rebuilds the tree and creates a zipper,
followed by destructive inorder traversal, so the retained-root owned-result
observer cannot simply be transferred to these owners.

Do not repeat blanket take inlining (Phase186 regressions), removing only frame
calls (Phase192 negative witness), recognizing already-borrowed Map.bit, or the
retained-root observer's2.45× synthetic result as tree/BST predictions. The
[ownership frontier](../ownership/frontier.md) already distinguishes mutating
warp_zip from preserved-root reads; BST insertion also mutates its root.

## Falsifiable next observation and honest suite scope

Use the existing profiler on **exact current N1 tree-bitonic and BST64**, with
matched retained C/QBE products and independently checked outputs. First ask
whether BST time resides primarily in `bst.down`/step construction, `bst.up`
rebuilding, inorder continuation, or runtime take/ctor paths. Join hot PCs to
these pinned functions. To choose a uniqueness/retention optimization rather
than a scheduling change, subsequently obtain per-invocation owner-associated
take/ctor counts and raw/RFC/count-one/shared path frequencies; samples alone
cannot distinguish extra calls from slower calls or memory stalls. Neither
hardware stall counts nor those ownership-path frequencies exist here.

If the refreshed tree profile still selects the capture-resume owner, the already
specified cheap A/B is one post-pop SP snapshot for all capture loads, preserving
capture/FID order and never carrying it over a call or stack mutation. Require
actual elimination of repeated loads without new spills, then paired complete
tree/lexer runtime and existing continuation controls. No BST benefit is assumed.
Without current path weights, there is no defensible expected whole-suite ceiling
for that A/B, so no new implementation/model fixture is prepared here.

For scale only, an **oracle substitution of all five tree/BST workloads** with
their complete QBE timings would multiply the44-case suite geomean by0.962544
(3.75% lower); replacing them with C gives0.868035 (13.20% lower). Tree-only and
BST-only QBE substitutions are0.981035 and0.981152. These are reference parity
counterfactuals with every other case fixed, not achievable limits, forecasts,
ownership-removal fractions or equal-family scores. They quantify the stakes
without inventing the missing dynamic attribution.
