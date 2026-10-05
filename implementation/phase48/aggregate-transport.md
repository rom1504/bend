# Private tuple transport checkpoint

Date: 2026-10-05. Baseline: installed array06 (`ee54723`).
Status: the corrected checked candidate passes 26 independent synthetic IR
graphs / 69 observations; candidate03 also passes two actual-emission graphs /
30 observations and 74 source oracles / 13 boundaries / four activation checks.
Decision: **defer production integration**. Both scalar-register and flat-vector
variants pass their source controls, but neither shows useful, consistent speed
improvement on six scaled diagnostic points. The unchanged full45 aggregate has
not been rerun for either candidate. No promotion or general speed claim.
No candidate compiler, generated-program execution or timing has been run by
this owner. The root agent owns serial execution and promotion.

The [design](../../design/phase48/aggregate-transport.md) targets an allocation
that the deferred Phase47 inliner did not remove. In the exact array06 RLE
library, `rle.step` returns two nested state tuples. Its false arm also creates a
pair and list cell containing an encoded run; its true arm creates only the two
state tuples. `rle` immediately passes this result through its next tail
iteration. The encoded list is subsequently consumed by both `llenp` and
`expand`, so those persistent objects remain necessary.

The implementation adds private argument and result decomposition over typed
JW, followed by local removal of projection-only tuple shells. It retains the
function list, indices, names, source guards, public entry signature and public
result layout. Tagged records are not scalarized: a tuple transporting a record
can disappear while the record itself remains allocated and shared.

Multiple results use explicit `JWCallValues` / `JWReturnValues` instructions.
The first field is returned normally; up to three additional fields use private
lexical return registers. Every producer evaluates all leaves into its own
locals before committing registers. Every caller captures them into locals
before another call or frame write. The continuation emitter restores its
frame before committing results. Consequently the proposal does not replace
each tuple with a result buffer or callback allocation.

The pass is bounded to 32 formal-parameter cuts and 32 result cuts per graph,
four formal cuts per function, at most 12 parameters and four result fields,
and 64 dominated tuple-shape facts. It trusts the existing typed lowering;
function `valid` flags are not an independent verifier for arbitrary malformed
IR. Unknown shape or unsupported use retains the original convention.

Static review identified one concrete draft bug: a direct inline constructor
in a return position could have its field expressions duplicated during
decomposition. The implementation now accepts only an already evaluated slot
with a dominated canonical tuple-shape fact. The ordinary lowerer already
produces that form, but the refusal is explicit and independently testable.

Field evaluation is retained even when a shell disappears. Each original field
is assigned once, in order, at the former allocation site. Branch-local slot
facts do not flow into another branch. Result rewriting cleans only the affected
producer after each cut, avoiding repeated cleanup of unrelated functions.

The source fixture and controller under
`selfhost/tools/performance/phase48/controls/aggregate-transport-*` cover a
renamed run-state graph, two consumers of its persistent encoded list,
a non-tail recursive caller consuming multiple results through depth 513, a tuple containing a
record, checked overflow in an unused field, error-hook reentry, public shared
child identity and mutable descriptor fallback. Diagnostic AST instrumentation
counts executed array literals inside the exact selected public assignments.
That establishes constructor evaluation, not physical heap allocation after
V8 escape analysis; GC/allocation profiling remains separate evidence.
Its state witness observes removal of `2*n + 2` array-literal executions for
`n=0,1,8`: two per transition and two for the initial state. These are executed
constructor counts, not measured physical heap allocations. A separate owner supplies independent synthetic JW
interpreter controls. The source fixture v1 contained computed tuple matches,
which the language syntax forbids; it was preserved before acquisition. V2
uses formal tuple matches. Its baseline acquisition then found a second syntax
issue: a local alias preceded a later parameter match. The pinned
`body_flatten(Local)` closes that parameter-matching scope. V3 moves the state
match before the local alias, following the maintained RLE example; it preserves
all v2 value/allocation oracles. V3 then passed parsing but failed checking:
a reusable list requires a `Data` element, while its tuple shorthand had kind
`Type`. V4 adopts the maintained RLE's explicit reusable Sigma pair alias only
for list elements, adds local type annotations and marks the twice-used
`public_shared` input reusable. Transient state tuple types and every controller
oracle remain unchanged. These fixture failures occurred before optimizer
execution and are separate from the synthetic branch-cleanup bug.

The fixture revision also exposed a real current limitation: forwarding a
result through another helper loses the local constructor-shape fact, so a
recursive producer expressed that way remains boxed. Actual same-SCC multiple
return emission therefore needs a separate synthetic emitted-IR gate; the
renamed source alone does not qualify it.

This change adds more compiler code than the rejected 405-line local cleanup.
It is justified only if actual across-call allocation removal, correctness and
useful runtime benefit survive measurement. Compilation cost, generated size,
representative benefit and regressions are all currently unknown. A failed
activation witness or negligible benefit should lead to a narrowed or deferred
patch, not a claim of architectural progress alone.

## Preserved first executable failure

The root built `checked-values01` and executed the independent JW controls.
Ten cases completed, including actual tuple-count reductions in basic private
parameter/result transport. The next case, `branch-join-remains-conservative`,
failed: a branch constructed slot 1, and the shared continuation read it after
the case. Local cleanup treated the branch remainder as the complete use scope,
removed the shell, and the independent interpreter observed `undefined-slot:1`
instead of 5.

Although ordinary JW lowering emits terminal cases, the failure was retained
and the test was not weakened. The successor adds an explicit upfront structural
check: a case with following instructions makes the entire graph retain its
original form. Terminal cases recursively check both arms. This makes the
scope precondition executable rather than relying only on the producer.

Evidence: `selfhost/build/phase48/jw-values01/report.json`, SHA-256
`c6ef46852198891ce5f2fc2ee446e6ef1de10454a1b4619457d0a6c151594de7`.
The consumed checked API is
`b12e7a3e2f6c5f95bde554d01d10c3007d827692e3fa77056b597759601ee58f`.
The isolated successor is `integration-values02`, receipt SHA-256
`86328a6c4e8545d73cf8a2dd4a2c3aec7cdf59d31ab9d3d982063910bed1e6b2`;
its 443-line values module is
`d7d0ddf8e02243c09dc995affa39ff2b8f6cb7134eb7efe51a49ad58b71785fe`.
These are correctness-development receipts, not timing results.

The root subsequently built `checked-values02` (reported wall time 51.2s) and
ran the synthetic controls successfully: **26 graphs, 69 observations**. The
original nonterminal-branch counterexample remains in that passing suite.
The checked API is
`4173911617bcc221c5004b257e71b6293ffa7a59d10476e8fc158e74ff7f1bb3`;
`jw-values02/report.json` has SHA-256
`5aa2adf1f617651d934dfb435fd827ff11622beb42691c4919cb09d2f8ba9456`.
These results exercise the actual checked transformation through an independent
logical interpreter, including tuple-count reductions. They do not by themselves
qualify generated JavaScript, public ABI behavior or physical allocation.

A subsequent static lifetime check identified another improvement before
promotion: extra result registers must be cleared after capture. Otherwise the
root closure retains its last returned child unnecessarily. Clearing occurs only
after every result is captured into caller-owned lexical locals, before any
frame store. The preserved candidate02 remains useful correctness evidence;
the retention correction requires its own source successor.


The reviewed retention correction is frozen in `integration-values03`, receipt
SHA-256 `9b67f7c3f0f97afdd18a3ece5ad398d7d67bbccc1d92090b518fd7ec92eaafcc`.
Its sole compiler delta from02 is a nine-line clear helper and its insertion
between complete lexical capture and caller stores. The emitter SHA-256 is
`e92932f6209557bb2170fde4fc7c08e71abe5ca2e291b13481b39ecebb78bff7`.
The emitted-IR controller distinguishes commit, capture and clear, and checks
that consumed return registers hold no retained result after calls and replay.
The root built candidate03 successfully (reported wall time 50.59s, not a
controlled compiler-cost comparison). Its real-emitter controls pass **two
graphs / 30 observations**, including pair and four-field recursion, native
budget exhaustion, machine continuation restoration, error/reentry and clear
register replay. Receipt: `selfhost/build/phase48/jw-emission03/report.json`,
SHA-256 `1f4fed5b1344fb47bf465600c7357cae6d3eed1e8e8f55332f83d447c3731ece`.

The unchanged reviewed source v4 also passes **74 oracles / 13 boundaries /
four activation checks** on baseline array06 versus candidate03. This includes
the observed transient state constructor reduction and retained public child
identity. Receipt: `selfhost/build/phase48/values-source03/report.json`, SHA-256
`72a68bc1dd4dab3074cb3106de9864da0b850f1c0593f7f03eee653f46c9b7a5`.
These semantic and executed-constructor witnesses do not establish runtime
benefit or complete corpus qualification.

## Separate scale diagnostic

The [scale plan](../../selfhost/tools/performance/phase48/controls/aggregate-scale-v1.md)
adds six points using **the exact same source v4**: `bench` and `deep` at sizes
32, 256 and 1,024. Independent retained Python oracles determine expected values;
all three compiler roles use ordinary maintained preparation and execution
runners. Larger arguments can distinguish sustained tuple-transport cost from
fixed entry checking. They do not change the primary 45-point / 23-source
catalog, its weights or its aggregate. The later scale results below retain these points as separate diagnostics.

## Maintained RLE witness and first timing screen

The actual maintained RLE library passes its separate executed-constructor
witness: result **11**, one private entry in each role, and **15 → 3** array-literal
evaluations. Persistent `Con` and `Nil` counts remain exactly **24** and **7**.
The three remaining arrays represent persistent encoded-run pairs. This proves
that this candidate removes the intended temporary tuple construction during
execution, while retaining the shared list. It does **not** show whether V8 had
already optimized away some physical allocations, or establish a speed gain.
Receipt: `selfhost/build/phase48/values-rle03/report.json`, SHA-256
`ffc91a91fbb346bb6e0ca524fde3bf02d132bf62746b8b821ef9bb4af36556c5`.

The subsequent four-point screen passes all expected outputs in **29.0175s**:
three balanced fresh rounds per role, 350ms warmup and 150ms target samples.
The measured gain is baseline time divided by candidate time; below 1 is slower.

| Point | Array06 median ms | Values03 median ms | Gain | Candidate / TypeScript |
|---|---:|---:|---:|---:|
| Historical RLE | 0.031643 | 0.033030 | 0.9580× | 57.456× |
| Map / Set | 1.309494 | 1.419670 | 0.9224× | 67.452× |
| Records 64 | 0.564404 | 0.566501 | 0.9963× | 1.911× |
| Records 256 | 1.967484 | 1.898785 | 1.0362× | 1.533× |

This is adverse or inconclusive initial performance evidence despite the positive
RLE constructor witness. The candidate's Map / Set within-sample half drift
ranges from **−29.13% to +5.15%**; its three sample times span
1.341624–1.486850ms. For records256, baseline half drift is consistently
−10.18% to −9.80%, while candidate drift is −5.01% to +12.88%. That modest
median improvement is insufficient evidence of a stable gain. RLE's baseline
sample range is 31.339–32.264µs and candidate 32.975–34.501µs, but candidate
half drift still reaches −9.92%. No confidence interval or causal JIT explanation
has been established. Receipt: `selfhost/build/phase48/values-screen03/report.json`,
SHA-256 `c1a38ee435c37bc9a99f4617c6c06a0e06360feb569b479d80ace0d9318e0621`.

Exact byte accounting joins inspected libraries to the modules used by that
screen. All changes are confined to existing complete one-line `G` assignments:

| Library | Baseline bytes | Candidate bytes | Delta | Changed assignments |
|---|---:|---:|---:|---|
| Historical RLE | 114,274 | 115,097 | +823 | `main.out` |
| Map / Set | 390,090 | 397,828 | +7,738 | `chk_get`, `chk_union` |
| Records | 240,898 | 244,203 | +3,305 | `bench` |

There is no new public-root admission in these three libraries. RLE's private
state producer now returns three scalars, and its loop grows from two parameters
to four. Its tuple constructions are replaced by field captures, copied locals,
return-register commits, immediate caller captures, clears and wider tail
argument transfers. Map and records also transform comparison tuple transport
and private parameter conventions; their generated scalar-transport markers
alone do not prove how frequently those paths execute. Several forwarded return
shapes still remain boxed, as described above.

This identifies a concrete cost tradeoff, not a proved explanation of timing:
fewer tuple constructors come with more scalar transport instructions and wider
continuation frames. V8's treatment of the original tuple and revised locals is
not yet measured. Do not add another cleanup or alternate calling convention
merely to rescue this screen. First inspect the already planned larger ordinary
workloads; retain this implementation only if measured benefit justifies its
compiler complexity, generated size and regressions.

The data-only inspection producer is
`selfhost/tools/performance/phase48/controls/aggregate-output-v1.py`. Its retained
report `selfhost/build/phase48/values-inspection03/report.json` has SHA-256
`73c35d2d136cbc08716fc53bcb1731178bff3f8b40bfe7b77694b78182d5cc0b` and preserves
input hashes, complete changed-assignment hashes, byte deltas, sample ranges and
drift. Compiler cost and the unchanged full45 aggregate have not been measured
for this candidate.

## Isolated physical-convention alternative

The [flat-vector proposal](../../design/phase48/aggregate-flat-vector.md) keeps
the same typed decomposition analysis but returns one flat private vector,
unpacked once by the caller. It removes shared return-register state and 28
emitter lines. This is a separate candidate, not a change to scalar03 or its passing
zero-temporary-shell witnesses. Separate controls expect RLE
15→8 constructor evaluations, compared with scalar03's observed15→3. Its subsequent scale screen, reported below, also fails to establish a useful
speed gain. The two conventions were measured in separate fresh paired runs;
their raw times are not a direct scalar-versus-vector experiment.

## Scaled workload outcome: defer both conventions

Both scale screens complete all **six points / 54 samples**, using the same
source v4, pinned TypeScript, three balanced fresh rounds, 350ms warmup and
150ms target samples. The scalar run takes **43.3058s**; the vector run takes
**43.8884s**. Each candidate is compared with its own freshly measured array06
baseline. The unchanged full45 corpus is not reweighted with these points.

| Point | Scalar-run baseline ms | Scalar03 ms | Gain | Vector-run baseline ms | Vector01 ms | Gain |
|---|---:|---:|---:|---:|---:|---:|
| bench32 | 0.052756 | 0.053262 | 0.9905× | 0.051606 | 0.051497 | 1.0021× |
| bench256 | 0.101623 | 0.101648 | 0.9998× | 0.098751 | 0.096689 | 1.0213× |
| bench1024 | 0.326832 | 0.316719 | 1.0319× | 0.311740 | 0.317342 | 0.9823× |
| deep32 | 0.043595 | 0.044091 | 0.9887× | 0.043867 | 0.043315 | 1.0127× |
| deep256 | 0.057826 | 0.057745 | 1.0014× | 0.056881 | 0.056955 | 0.9987× |
| deep1024 | 0.114497 | 0.122156 | 0.9373× | 0.114141 | 0.121884 | 0.9365× |

The small positive signs are not consistent across sizes or representations.
Scalar bench1024 baseline half drift ranges −20.46% to +28.91%, while its
candidate ranges −11.88% to −5.33%. Vector bench1024 baseline drifts +27.17%
to +29.09%, candidate −19.64% to −18.22%. These screens do not establish
steady-state throughput. In contrast, deep1024 is around **6.7–6.8% slower**
under both conventions with much smaller within-sample drift: scalar baseline
−0.10% to +0.13%, candidate +0.10% to +0.17%; vector baseline −1.01% to
−0.53%, candidate −0.72% to +0.40%. This is unfavorable evidence even after
scaling beyond the tiny historical RLE workload.

The scalar diagnostic's candidate / TypeScript ratios range 4.531× to 134.458×;
the vector diagnostic ranges 4.613× to 122.619×. These are this deliberately
selected source's six diagnostic points, not a replacement corpus aggregate
or a claim about typical programs. Neither physical convention addresses the
dominant gap demonstrated by these results.

Receipts:

- `selfhost/build/phase48/aggregate-scale-screen01/report.json`, SHA-256
  `9985240e3e523c4d592162cc652f0000fbdf31f448f33398c395fa2c58d3b519`.
- `selfhost/build/phase48/aggregate-vector-screen01/report.json`, SHA-256
  `c479f4abcb9c4a8924ea4c33801a5dfb6058ec9ee9e38bde912f21c797ec2ca2`.
- Vector source controls pass **74 oracles / 13 boundaries / four activation
  checks**: `selfhost/build/phase48/values-vector-source01/report.json`, SHA-256
  `97b8755506e7005b47bc3ecb70b9d9c42d2f1bba09687162f386b7ae157f4c4d`.

Root reports the vector checked build passing in 51.30s. This, like scalar03's
50.59s build, is acquisition wall time, not a controlled compiler-cost comparison.
The first vector scale acquisition failed before emission with `ENOTDIR` because
an `--attempt` argument named `attempt.json` instead of its directory. The failure
is retained in `aggregate-scale-vector01/preparation.json` (SHA-256
`17c04f913ba9efb8b5ce8cd259ba6012eeee118c5b28deb816c6ff5c7ba8a879`);
the fresh successful retry is `aggregate-scale-vector02`. The example commands
were corrected. No source oracle was changed to pass acquisition.

The scalar proposal costs **+565 physical Bend lines, +477 code lines,
+69 definitions and two analysis types**. The vector proposal costs **+537,
+451, +65 and two**, respectively. Both add a module and two alternatives to
an existing instruction type. These are marginal counts over the frozen array06
source, excluding tests/docs and the JSON module line. The vector convention
reduces emitter complexity, but neither variant earns its remaining analysis
cost through measured execution benefit. Controlled compiler cost and full
candidate qualification were not run; there is no reason to spend those gates
on the current weak result.

The lesson is narrower than “aggregate elimination does not work.” The pass
removes real constructor execution, preserves persistence and demand, and uses
no workload-specific recognizer. But constructor count is an intermediate
mechanism metric. Copy chains, larger private signatures, wider machine frames,
and V8 optimization of the original temporary tuples remain possible tradeoffs.
None is independently proved to be the timing cause. Preserve the experiment;
a future attempt needs evidence that a simpler consumer removes dominant work,
rather than another convention or pass justified only by fewer source arrays.

## Durable source preservation

The [proposal directory](../../selfhost/tools/performance/phase48/proposals/aggregate-transport/README.md)
contains complete corrected scalar and vector payloads, full baseline patches,
and the preserved failed01 → terminal-Case02 → cleared-register03 sequence.
The raw checked snapshots and original controllers remain untouched. The
manifest SHA-256 is
`7047e651f72844a69636a832095231fdf9ce5bd53da9259271c65035eb7b8913`.
Every patch was independently applied to its frozen parent text and matched
the next version exactly; both final payloads were materialized and rehashed
without compiler or target execution. The whole patch can be reproduced outside
ignored build evidence. Neither final variant is selected.
