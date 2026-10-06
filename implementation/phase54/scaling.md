# Direct call-graph scaling

The selected Phase54 source is graph02: compact graph traversal plus a shared
4,096-definition production limit. Its checked build and independent 15-case
fact/10-case boundary controls pass. Nine earlier graph jobs cover sparse scales
through 3,004 vertices and the initial budget refusals. Five actual checked
source chains through 3,004 declared functions now emit successfully and return
the exact oracle 37 in fresh generated-program smoke tests.

This is analysis work, not a generated-program optimization. The first graph01
candidate deliberately retained 512 before the capacity successor was authorized.
Fact parity, emitted-byte parity, large source acquisition and compiler-image
qualification remain distinct. The full 77-export direct compiler-image attempt
timed out; this phase does not claim that migration or a self-emitted fixed point.

## Scope and preserved behavior

The graph algorithm changes only
[direct/calls.bend](../../selfhost/src/back/js/direct/calls.bend). The capacity
successor also changes one bound expression in
[direct/reach.bend](../../selfhost/src/back/js/direct/reach.bend). There is no new
manifest entry, runtime representation or neutral graph module.
The current graph storage uses the compiler's `KDef`/`KTerm` name indexes, and its
edges represent specifically direct-backend tail calls. Extracting a generic
interface before a second consumer would add an abstraction without reducing
these dependencies.

The typed tail scanner and row builder are byte-identical to the predecessor.
This retains erasure, partial/overapplication, matcher demand, emitted numeric
row pruning, foreign/native handling and unknown-closure classification. A known
native operation remains terminal; creating a closure does not execute its body.
Named cycles alone do not require bounce forcing.

Public queries remain `jd_calls_valid`, `jd_component`, `jd_component_id`,
`jd_same_component` and `jd_may_bounce`. Component members retain selected source
order, the leader is the first member in that order, and IDs are dense from zero.
Singletons include their own name. Unknown names retain empty members, false
membership/bounce and the existing `4294967295` missing-ID sentinel.

The independent controller may call the retained
`jd_calls_context_rows(book, Some(rows))` seam. A new diagnostic seam,
`jd_calls_context_bounded(book, rows, vertices, edges)`, supplies explicit budgets
without raising ordinary source admission. Rows require unique names, `JDCall`
metadata and `Ref` edges to admitted rows. Duplicate edge occurrences are legal;
duplicate row names, missing targets and exhausted budgets refuse the plan.

## Algorithm and storage

1. Validate and index the forward rows. Build reverse adjacency once and collect
   the definitions with unknown-tail seeds.
2. Run a forward depth-first traversal using explicit enter/exit worklist items.
   Each vertex expands once; exit items build descending finish order.
3. Traverse reversed edges in that order, marking each strongly connected
   component. Visited state is an indexed map, not a scan of the stack.
4. Traverse reverse edges once from all unknown seeds. The marked definitions
   are exactly those that may reach an unknown tail call.
5. Scan original rows backwards and prepend members to their component lists.
   This restores source order independently of private DFS order. Enumerate each
   list once to assign IDs and install compact facts.

Adjacency batches use tail-recursive `List.reverse.go` when pushed onto a
worklist. Their private traversal order is irrelevant after canonical member
ordering; this avoids the non-tail recursion in `List.append` on a large row.

One `$JD.Calls` metadata row owns two immutable indexes: per-function
leader/position/bounce facts, and one member list per component. The analysis no
longer retains a reachable-name set or index for every function. Installing one
row also avoids a separate book-list replacement for each graph vertex. No other
maintained source reads the old private `$JD.Call:<name>` row encoding.

There are `O(V + E)` graph visits and retained graph data, rather than
`O(V(V + E))` visits and potentially quadratic closure storage. This counts graph
operations, not an unconditional wall-clock bound: exact-name hashing, trie
lookups and full-hash collision buckets still cost work. Type normalization and
source scanning are outside this graph-only complexity statement. No compiler
throughput improvement is claimed from source inspection.

## Initial graph01 resource contract

The first graph01 source scan still accepts at most 512 eligible definitions and
8192 tail nodes per definition. The graph also validates its vertex budget,
including diagnostic row input that formerly bypassed the source scanner.
Its total input edge-occurrence ceiling is 4,194,304, the product of those two
existing source bounds. Worklists terminate structurally after the admitted
vertices and edges; they do not rerun a closure walk from each vertex.

**The refusal domain is not identical.** The old graph stopped after 65,536
queued items *per reachable closure*. That work counter is removed. Some dense
or repeated-edge graphs below 512 that previously exhausted it can now be
accepted. Conversely, malformed duplicate rows and over-budget direct diagnostic
row input are now explicitly refused. The larger total-edge ceiling therefore
requires resource evidence; preserving 512 alone is not proof of unchanged
admission. No production vertex increase was made in graph01. The independently preserved
graph02 successor raises only the shared definition bound, as detailed below.

In graph01 the exact emitted `JD_REF` reach pass remained unchanged, with its
own 512-definition, 65,536-name and 2,097,152-character-per-definition bounds. It remains
the authority for dead foreign-import pruning. Selected-definition overlays,
repeated emission for exact reach, and printing the whole mutual component at
each entry remain separate scaling costs. In particular, an SCC with `k` members
and total body size `B` can still contribute `O(kB)` generated text. This patch
alone does not establish compiler-sized direct self-emission.

## Preserved source and initial checks

The immutable proposal is under
`selfhost/build/phase54/scalable-graph01/`: `calls.before.bend`,
`calls.after.bend`, `scalable-graph.patch`, `original.json`, and `proposal.json`.
The retained `save-proposal-v2.py` producer verifies the original, confirms the
unchanged scanner/row-builder spans, creates fresh outputs and rehashes inputs.
Its first version used the wrong repository-parent index and failed before
writing proposal outputs; that producer and `save-proposal-failure01.json` remain.
No compiler or generated program was run by either source-preservation producer.

| Source measure | Predecessor | Graph candidate | Change |
| --- | ---: | ---: | ---: |
| Physical lines | 341 | 431 | +90 |
| Nonblank, noncomment lines | 275 | 343 | +68 |
| Definitions | 50 | 60 | +10 |
| Data types | 2 | 3 | +1 |
| Bytes | 17,376 | 22,111 | +4,735 |

These counts cover only `calls.bend`; there is no line-reduction claim. The
change removes the all-pairs closure concept and adds explicit DFS worklists,
reverse adjacency and shared component tables.

Original source SHA256:
`fbdb1f22955df1903b341062f78b4c0063b70007ba9ebb009315544fc63c9fa8`.
Candidate source SHA256:
`797993d96b6eab3a273f979146d0032fa573e56d1178bbe5f3715dfd08417c87`.
Proposal receipt SHA256:
`f1076985406993439390fdf6fdb407d030e5d1a5981bcbb825cdc3663b25388f`.

Independent static review passed the graph algorithm and the final two-site
worklist adjustment. The predecessor checked API passes 14 independent graph
cases at `selfhost/build/phase54/graph-baseline01/report.json` (SHA256
`6d21f9397a8ea43f3bb6da378c8467566e9684904756513872f1862978a12980`).
Those include order permutations, duplicate edges, directional bounce reach,
cycles, isolated nodes and a missing target. This predecessor result is not a
candidate result. Candidate evidence follows; none of these graph tests executes an emitted user
program or proves whole-compiler emission capacity.


## Graph01 execution and capacity successor

The root's serial checked build passes in 59.690 seconds with 1,531,109,376 bytes peak
process-tree RSS (`build-graph01/run.json`, SHA256
`67beff2f1870000490c4d80b32fc1fea3602f1858e9f3a1fd645e4fc861aaa70`).
The candidate passes 15 independent graph cases, including duplicate-row refusal
(`graph-candidate01/report.json`, SHA256
`362189239597f6859ecff408e8c265e3f15fa43e10e319c58eb39e67344ef08f`).
This is the predecessor's 14 cases plus the newly explicit malformed-row case.

The following fresh diagnostic jobs all pass their closed-form graph oracles.
Times measure one invocation of the graph-fact entry after importing the compiler;
they are single observations, not warmed throughput estimates or a complexity fit.
The larger graphs use explicit diagnostic budgets, not the initial production 512.

| Graph | Vertices | Edge occurrences | Analysis ms | Receipt directory |
| --- | ---: | ---: | ---: | --- |
| Predecessor chain |128|127|226.907|`graph-baseline-chain128-01`|
| Candidate chain |128|127|38.245|`graph-candidate-chain128-01`|
| Candidate chain |512|511|202.801|`graph-candidate-chain512-01`|
| Candidate chain |513|512|180.397|`graph-candidate-chain513-01`|
| Candidate grouped components |1024|1024|229.588|`graph-candidate-components1024-01`|
| Candidate chain |3004|3003|470.318|`graph-candidate-chain3004-01`|
| Candidate isolated vertices |3004|0|410.790|`graph-candidate-isolated3004-01`|

All directories are under `selfhost/build/phase54` and retain `report.json` plus a
separate supervisor receipt. The 3,004-node chain job takes 3.920 seconds including process
startup/import, with 482,263,040 bytes peak tree RSS. Its graph result receipt is
`49ab023bc8270f446d09e44c1cdeacc913fbfffda35ad625fe251c387d45ae05`; its
supervisor receipt is
`9cb74bb651c5f15410fc7f6410580d5d6ef1d78a53d2ae76bd1a779ec2bfd2c7`.
The 128 comparison demonstrates a lower observed analysis cost on one graph; it
does not establish a 5.93× compiler-wide speedup.

The initial production seam correctly refuses 513 vertices
(`graph-candidate-default-refusal513-01`); the explicit edge seam refuses the
127-edge chain with an edge budget 126 (`graph-candidate-edge-refusal128-01`).
These results verify those resource boundaries independently of value correctness.
They do not validate worst-case memory use at the 4,194,304-edge ceiling.

The capacity successor adds `jd_definition_budget() = 4096` and uses it at exactly
three sites: source row collection, graph input validation and exact emitted
`JD_REF` reached-definition accounting. It changes no traversal or generated-code
logic. The graph-edge 4,194,304, source-tail 8,192, exact-reach queued-name 65,536 and
per-definition 2,097,152-character limits remain unchanged and independent. The
first candidate's 512-refusal result remains historical evidence; it is not
relabeled as the successor's expected behavior.

The new proposal is preserved at `scalable-graph02/` with both before/after
sources, `definition-capacity.patch`, a fresh data-only producer and
`proposal.json` (SHA256
`01edf9fdf3ada19efbe65a2f54a63b6dae4d93680e89314f680d0e419e4ed0e8`).
The source identities are:

- `calls.bend`: `3b8129d1976a2016a7aef5a9e3cdd175fe7f5f9d5aec5ab220a427b37e1f0255`
  (435 physical lines; +4 over graph01).
- `reach.bend`: `3f0780000d1003e5fcc28243b210f39259c2b0716e2a975c0130ebcdbf3e0a1b`
  (one constant replaced by the shared budget call; no added lines).

Independent static review passes this narrow numeric-bound change. Its executed
gates follow; a graph with 3,004 synthetic rows is not an emitted compiler.


## Selected graph02 qualification

The checked graph02 build passes in 59.889 seconds, with 1,529,864,192 bytes peak
process-tree RSS (`build-graph02/run.json`, SHA256
`67a908c5c9cba6dd77d02d0f61ec79bc306bebf84cff75927c3e14c6140b83b2`).
Its exact checked compiler API is
`d7d0396cda189918299ddeb0105e9d682f6a22bffa70004ab6d0ebeac20f4857`;
its attempt receipt is
`594381ea67444070290efeb516458997c528829f9cd4b65385109afc2d0d4a76`.

Two fresh suites use that API:

- `graph02-parity01/report.json`: 15/15 pass, including source-order permutations,
  singleton/self/mutual components, directional unknown-tail propagation,
  duplicate edges and missing/duplicate-name refusal. SHA256
  `b71c3f9484e944933c89c9178e48d7f1815f36842e153e608714c3f0720e1410`.
- `graph02-boundaries01/report.json`: 10/10 pass using explicit per-case budgets.
  Empty 0/0, exact vertex/edge budgets, one-short refusals, duplicate edge
  occurrences and missing targets are independently checked. SHA256
  `f0c9e4b82bba5d3817cb3df5102bff6741664459d36b1a9e9b1c96faafdffdbe`.

These suites do not include source parsing/checking or user-program execution.
The nine graph scale/boundary jobs above comprise one predecessor measurement,
six successful candidate sparse-graph measurements and two expected refusals;
they remain bound to graph01. They are not relabeled as fresh graph02 executions.
The source-chain gate below fills that distinct selected-source gap for five
sparse chains, without claiming coverage of arbitrary compiler-sized programs.

Graph02's `calls.bend` is 435 physical / 346 code lines, 61 definitions and 3 types:
+94/+71/+11/+1 against the original. `reach.bend` adds 19 bytes but no lines.
The historical graph01 table above intentionally keeps its earlier counts.
Neither the replacement nor the capacity change is presented as line reduction.

### Checked source-chain gate

Five checked source-chain acquisitions and their generated-program smoke tests
pass under graph02. Every module's `bench(37)` returns 37 on its first,
calibration and final invocation. The unchanged smoke runner uses Node's default
stack, with no stack-size override. These are 15 scalar observations across five
cases, not a warmed runtime benchmark.

| Declared functions | Checked acquisition seconds | Peak process-tree bytes | Emitted module bytes |
| --- | ---: | ---: | ---: |
|128|6.921|575,291,392|49,522|
|512|11.932|584,249,344|158,194|
|513|11.744|574,578,688|158,477|
|1024|18.324|580,501,504|303,090|
|3004|43.714|623,955,968|863,430|

Acquisition includes loading, checking and direct emission. The five process
wall times total 92.635 seconds; the smoke process times total 0.463 seconds. These are bounded
acquisition observations, not steady compiler throughput or a performance
comparison. Declared source functions are distinct from eligible tail-graph and
exact-reach definition counts, which can also include retained Base definitions.
A separate final graph02 check now verifies that the ordinary
`jd_calls_context_rows` entry refuses a chain with 4,097 vertices and 4,096 edge
occurrences. Its default bound is used, without diagnostic budget overrides.
The graph analysis takes 162.649 ms; the supervised process takes 3.619 seconds
and peaks at 455,180,288 bytes. This is a default graph-entry refusal check, not
a 4,097-function source compilation. The independent parameter tests above also
exercise exact/one-short budgets on smaller graphs.

The refusal report is `graph02-refusal4097/report.json`, SHA256
`86ab6e13e57e3924d919d46eaf73beaed7172c149948182205f44abcc7d835ab`;
its `graph02-refusal4097-supervisor/run.json` has SHA256
`4de9038b7ce15785370bc1611f7fed5bd2cbd9c12236d22127bd7092dcf28c8e`.

The final fixture catalog is `scale-sources03/catalog.json`. The first source
generator omitted `import Base`; its successor used unavailable forward
declarations. Both failed acquisitions are preserved. The third version changes
declaration order so each referenced helper is already defined; it retains the
same chain workload and oracle 37. These are fixture repairs, not ignored
compiler failures or changed expected values.

Exact selected receipts under `selfhost/build/phase54`:

- `prepared-scale-graph02-v3/manifest.json`, SHA256
  `f84f0e74527b6f45ca4d2b1015e136e007460b291b176749551a5bb8b9e4c1e3`.
- Its `preparation.json`, SHA256
  `f4b036fdf789d7c67e45b9d446d57cdec714f45e9e3db0a03622f23d05cf76fd`,
  binds all five source identities, checked emissions and process bounds.
- `smoke-scale-graph02-v3/report.json`, SHA256
  `8ab57dc39d0d9a005de2c4966feb35c494b3ecc6ad44d5a66b90e11f030c57d4`,
  binds the emitted modules and all five oracle results, with final rehash.

### Remaining compiler-image limit

The full 77-root direct compiler-image emission hit its 240-second process limit
without an out-of-memory failure. A subsequent instrumented diagnostic separates
exact emitted reach from final emission; the detailed outcome belongs in the
[bootstrap report](bootstrap.md). This graph replacement therefore earns retention
as a tested scalability improvement, not as proof that the whole compiler can
already be emitted or self-reproduced through the direct backend.

A read-only follow-up identified repeated `book_put` list replacement in
`jd_selected_context`, called before exact reach and again before final emission.
A possible replacement can reuse `book_final_fast` for the exact declaration
order and separately fold selected updates into the original cache index. Its
finite checked-context invariant must preserve last-selected value, reverse
last-occurrence list order, original unselected definitions and cache bound.
The proposal remains unimplemented: the actual profile instead identifies hot
constructor lookup/missing-result paths, and no further emitter fix is selected
in this phase. Neither possible mechanism is assigned a speed benefit here.
