# Why body omission has limited compiler headroom so far

This is a bounded source and retained-assembly audit, not a new profile. The
inputs and static counts are pinned in `compiler-generic-census.json`.
Both machine products compile the same 1,556,351-byte Phase164 native source.
`hybrid-native03` was produced by the selected original backend;
`hybrid-n2-03` was produced by the first mixed compiler image. They are different
generations, so their build times are not a clean one-variable phase ablation.

| Static property | Original route N1 | Mixed route N2 |
| --- | ---: | ---: |
| Public segment functions |51,960|47,360|
| Continuation segments |44,060|39,460|
| `$direct.*` public source workers |3,940|3,940|
| Other public entries/factories |3,960|3,960|
| Boxed native `p113d_*` functions |2,096|2,096|
| Ordinary `p112w_*` functions |13,223|14,360|
| Same-owner ordinary forwarders |592|1,147|
| Same-owner public direct adapters |1,359|1,359|
| Emitted QBE bytes |109,886,524|104,739,601|

Thus the image has 4,600 fewer continuations (10.44% of that category), 4.68%
less QBE, and 555 more ordinary forwarding connections. It does **not** have
more final native direct functions. Counts of public direct adapters and
ordinary forwarders are physical emitted shapes, not the number of source
bodies omitted: existing registry-selected direct owners already had some
forwarders, and late admission can add workers after omission selection.

The reported complete build pipeline was 201.931 versus 201.271 seconds, with
emission and QBE overlapped by the bounded relay. That near-neutral single
generation comparison cannot isolate compiler execution, QBE time, verifier
savings or runtime effects. It does rule out calling this observed run a cold
self-build breakthrough. The earlier Phase161 stage profile is of a different
full input and a diagnostic image; its intervals must not be subtracted from
these clean build clocks.

## The remaining generic graph has structural causes

Both images still execute these source workers through the generic ABI:
`p111_lower`, `p113pl_candidates`, `p113k_function`, `p113k_put`,
`p111v_assign`, `index_set`, `p111q_stmt` and `p111q_stmts`.
By contrast `p111v_get`, `p113l_version`, `index_find`, `f_find`, `f_eq`, `kt`,
`String.append` and `nt_text_finish` already have native direct implementations.
The mixed image adds ordinary import paths to several of those existing native
implementations. Their logical hashing, comparison, allocation and text work
still exists. This source evidence supports investigating those costs; it does
not establish their current dynamic fractions without a fresh profile.

A concrete blocking closure is `index_set -> p131i_insert` in
`src/core/index.bend` / `src/core/index-queries.bend`. The ordinary typed-node
branch recursively inserts into one child, then reconstructs `KIndexNode` around
the result. That is non-tail recursion. `p113d_call` explicitly refuses non-tail
self calls, and `p113d_deps` admits only dependencies already in the direct
closure (apart from the separately checked tail-SCC conversion). Consequently
this primitive remains scheduled, and direct candidates depending on it cannot
simply become closed native functions. `p113k_put` and `p111v_assign` still reach
that scheduled store path, despite faster reads.

The generic path is doing necessary stack-safe work: `p111_let_cut` computes
live values, makes a continuation segment and frame, emits the call, and later
resumes the remaining computation. Removing body production for already direct
owners does not eliminate this work for genuinely recursive/tree-producing
owners. It also leaves the frontend, direct candidate creation and most scalar,
ownership and output processing intact.

## Most useful next boundaries

1. **Remove one real recursive map-update boundary without weakening stack
   safety.** The additive `index-zipper.bend` walks typed index nodes with an
   explicit path and rebuilds them in a tail loop. It stops at the terminal
   subtree, where a generic dispatcher uses the unchanged collision, join or
   legacy operation. This keeps malformed masks, duplicate replacement and old
   payloads exact. Native descent/unwind could replace a scheduler chain per
   tree level with two ordinary worker calls. It introduces path/stop objects,
   so allocation and complete teardown must be charged. Shallow updates may
   lose. The first gate is complete old/new trees and retained aliases; next is
   actual insertion/update streams, followed by an actual compiler workload.

2. **Make private analysis facts cheaper, while retaining exact independent
   verification.** `p113k_put` still constructs a nine-field KDef and two
   eight-field KTerms to represent a small fact; it looks up the old epoch and
   hashes the String again for insertion. A dedicated persistent fact record
   and numeric per-function identities can remove work inside the store rather
   than merely accelerate a call to the same generic objects. The useful gate
   remains a complete actual `p113k_function` result with branches, joins,
   versions and relation invalidation. The prior dense-array/conversion
   negatives prohibit forecasting gains from an isolated put loop.

3. **Only then consider general native treatment of non-tail recursive SCCs.**
   A verified explicit continuation representation could cover far more of the
   compiler's recursive traversals than another closed-DAG admission tweak.
   Ordinary unchecked C-stack recursion would change the existing stack-safe
   contract. This is a larger compiler architecture task and needs a complete
   call/return/ownership proof and actual caller workloads. The index zipper is
   a small, falsifiable instance of that direction rather than a justification
   for immediately rewriting the backend.

No current evidence assigns a defensible whole-build percentage to these
proposals, much less supports a five-second result. Imports-only is the smaller
mechanism ablation already prepared: it tests whether the observed generated
program improvements come from connecting existing direct workers rather than
from materializing fewer generic bodies.
