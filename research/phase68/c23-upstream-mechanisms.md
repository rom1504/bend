# Compiler23 native parity: mechanisms missing across boundaries

Source audit on 2026-10-11 of candidate23 (`b2ec0a2`, report checkpoint
`4e0d8c6`) and upstream `059266225b77c8ca256ac6b25ee5c21449bab151`.
This investigation changes no compiler, runtime, generated C or installed image.
It ran source/data inspection on CPU0, with no compiler or benchmark target.
Runtime estimates below are hypotheses requiring the campaign's independent
profiles and saved-C experiments; static code differences are not timings.

The [closed measurements](../../implementation/phase68/native-facts-and-calls.md)
give candidate/upstream C runtime ratios 0.992 numeric, 1.006 array, 1.785
closures, 3.118 tree, 1.786 Map and 2.646 lexer: geometric mean 1.724.
These are B1-emitted native programs in a six-family corpus, not B1 compiler
latency, B2 compiler latency or a universal language performance result.

## Priority zero: unreachable bang references change runtime mode

The campaign's native profiler lane found a larger control mismatch after this
audit's initial architectural ranking: candidate23 tree has `BANGS 39`, lexer
`BANGS 16`, but their upstream programs both have `BANGS 0`. Source inspection
confirms a specific mechanism that should be tested **before** representation
refactoring.

[`nc_bangs_book`](../../selfhost/src/back/native/book.bend#L240) scans the bodies
of **every definition in the supplied book**. Meanwhile `nc_compile_defs`
emits only the closure rooted at `main`. The imported original tree fixture
has an unused original `main` calling `bsort!` and `scan!` at lines143–145;
the imported lexer has an unused original `main` calling `batch!` at
lines238–239. The measured wrappers import these fixtures as `W` and call
`W.bench` without bang. Their live ordinary paths still call the same functions,
so dead bang references mark otherwise reachable functions as banged.

`nc_mark_segments` then copies that function-level bang flag to all generated
segments of the definition. Decoding candidate `FID_FLAG_T` verifies that all
39 tree flags belong to the `scan` and `bsort` segment groups; all16 lexer flags
belong to the `batch` group. These numbers count flagged generated segments,
not39/16 syntactic source bangs. Upstream `file_book` instead collects
`FL.bangs` while walking definitions reached from its roots.

This is operational, not cosmetic metadata. Candidate
`corpus_eval` calls:

```c
work_loop(e, io_stk, t,
  !BANGS && (pool_size == 1 || fid_nofk(term_aux(t))))
```

Thus even the one-thread, GPU-off tree/lexer run starts with `seq=false`.
Candidate `nc_parallel_finish` allocates tasks when `!seq`; sequential execution
uses its already-emitted `nc_lets` fallthrough. Ordinary cuts similarly choose
heap task continuations instead of stack continuations. Workers also retain
`if (!seq && err_seen(...))` checkpoints. Upstream's zero bang count permits
the sequential mode for these same one-thread workloads. False bang targets
additionally exclude functions from `nf_candidates`, although the three
identified recursive/forking functions may already fail worker admission for
other reasons.

**First saved-C diagnostic:** copy each exact candidate C to a new diagnostic
path and change only `#define BANGS` to0, keeping `FID_FLAG_T` and emitted bodies
unchanged. Compile with identical flags; run one thread/GPU off, a bounded smoke
and the independent digest before balanced timings. The pure benchmark paths
do not require foreign concurrent progress, and parallel binding lowering has
an explicit sequential implementation, so no source-visible concurrency or
deadlock dependency is apparent here. This is not permission to force all
programs sequential: reachable explicit bangs, foreign callbacks, async waits,
multiple threads and device execution need separate preservation controls.
Leave the flags unchanged in this first arm to isolate selection of runtime
mode from compiler admission/code changes. This audit does not claim the
result; the parent campaign owns running and measuring it.

**General compiler-fix hypothesis:** derive one bang-target set from the
runtime/erased definition closure rooted at actual entry points, and use it
consistently in scheduler generation, metadata and worker planning. Do not drop
unknown function references or foreign callback roots while computing reach.
Use the existing runtime reachability machinery rather than a new whole-book
analysis. Controls should include adding/removing an unreachable function that
contains a bang, importing a module with a dead bang-bearing `main`, a live
ordinary reference to the same callee, and live explicit bangs through both
known and closure calls. Dead source entries must not change execution mode.

This finding also qualifies the older tree/lexer allocation comparison:
some excess `heap_alloc` may be task/continuation work caused by mode selection,
not data representation. Remeasure task counts and native profiles after the
diagnostic before assigning the remaining deficit to layouts or ownership.

## Finding: the remaining gap crosses representation boundaries

Several important optimizations already exist: full known-call arity, ordinary
C workers with tail-self loops, private product workers, single-field constructor
packing, scalar array storage and a no-sharing array policy. Recommending those
again as absent features would misdescribe the current compiler.

The incomplete part is **compositional coverage**. Native scheduler bindings are
single words. Product workers flatten one fixed outer shell, keep nested fields
opaque, and rebox at scheduler boundaries. Worker admission happens after
scheduler lowering. Every ordinary binding is handled as a potentially owned
generic word, and every constructor is marked potentially shared. Upstream
carries layout, scalar kind and borrowed-root facts through both its scheduler
and ordinary-C paths.

The strongest new evidence is visible in actual candidate23/upstream C:

| Path | Candidate23 | Pinned upstream | Missing general mechanism |
| --- | --- | --- | --- |
| Lexer recurrence | A direct C loop, but allocates a state Tuple, seals fields, then takes/frees it on the next character; `step` returns generic Mode Term plus U32 | C loop carries String plus three `u32` state words; `step` returns three scalar words | Nested sum/product layout and loop-carried field representation |
| Tree `warp_zip` | Takes/frees two Nodes, allocates three replacement Nodes and seals their fields | Reads both unique Nodes directly, reuses both allocations and allocates only the outer Node | Cold-constructor facts plus reuse of consumed storage |
| Recursive Map `seek.go` | Boxed argument Tuple; rebuilds node and nested result Tuples; one-word return | Flattened key/flag parameters and four-word scheduler return, with node reuse | Multiword layout through scheduler calls, continuations and results |
| Tree `scan` | Returns a newly allocated four-field Stat box from each leaf | Returns four scalar words through the scheduler | Product ABI outside ordinary C workers |
| Closure-chain construction | Calls the curried `compose` entry and applies it twice, allocating intermediate capture objects | Creates one closure with evaluated captures directly after the recursive result | Call-site partial-application construction and known-prefix specialization |
| Flat helper called from recursive scheduler code | Jumps to a scheduler entry that then invokes the C worker | Calls `spin_*` directly in the caller/continuation | Caller-aware worker lowering |

The consequence is not merely more text. Facts that could expose plain scalar
operations, direct fields and local values to Clang have already been replaced
by runtime protocols before Clang receives the program.

## 1. Layout must serve scheduler and worker code equally

Upstream [`lay_of`, `lay_pack`, `lay_node` and `fun_of`](https://github.com/bendlang/bend/blob/059266225b77c8ca256ac6b25ee5c21449bab151/bend2/comp.ts#L923)
produce layouts with per-word kinds and constructor arms. Recursive data, arrays,
IO operations, hidden layout cycles and excessive width remain boxed. Small
nonrecursive products and sums can flatten recursively. The layout is used in
parameters, bindings, constructor fields, continuations and result registers,
not just an optional direct-call tier. A flat sum uses a tag word plus an arm
payload; unused slots are padded to the agreed width.

By comparison, [`nq_layout_single`](../../selfhost/src/back/native/product-layout.bend#L14)
admits only a single-constructor shell. Its comment explicitly states that
nested records/arrays remain opaque one-word fields. [`nq_transfer`](../../selfhost/src/back/native/product.bend#L32)
boxes a flat product when the destination is `NC_Scheduler`.
[`nc_params`](../../selfhost/src/back/native/bridge.bend#L32) assigns every ordinary
parameter `N_W64`; [`nf_param_c`](../../selfhost/src/back/native/flat.bend#L72)
emits every worker parameter as `Term`. The IR already contains `N_W32`,
`N_Box`, result widths and multiple register return support; semantic lowering
does not yet exploit them consistently.

**Exact lexer witness.** In
`selfhost/build/phase68/native-facts23-lexer/lexer-selfhost/program.c:17388`,
ordinary `lex` takes String and one boxed state. Its positive branch calls the
product `step` with a two-word output array, allocates a two-field Tuple,
`rfc_seal`s both words and carries that box into `goto nf_again`. Its next
iteration immediately calls `ctr_take` and `spare_free` on that Tuple.
`step` at line18688 returns `[Mode-as-Term, U32]`, so removing only the outer
Tuple would still leave Mode representation less explicit than upstream.
Mode's one-U32 constructors already use candidate23's guarded packed immediate
representation on valid benchmark values: **this is not a second obligatory
heap allocation per character**. Keeping packed Mode in one register might be
as good as, or better than, upstream's two scalar words. The explicit-tag arm
must therefore be measured separately from the definite outer Tuple removal.

In `selfhost/build/phase67/native-heldout-baseline02/lexer-upstream/program.c`,
`spin_22` at line1817 accepts `(Term string, u32 modeTag, u32 modePayload,
u32 accumulator)`. It invokes `spin_18` with three output words and directly
assigns the next loop state. There is no state Tuple allocation. String
destruction remains, because removing a transport Tuple does not remove the
input list.

**Exact scheduler witness.** Upstream Map `seek.go`, line6023 in
`native-heldout-baseline02/map-upstream/program.c`, accepts three register
words and returns four with `WL_RETN(4)`. Candidate23 `$direct.Map.seek.go`,
line32591 in `native-facts23-rest/map-selfhost/program.c`, accepts two boxed
words. In its first terminal branch it allocates an MNode plus two nested
Tuples, seals their fields and calls `WL_RETN(1)`. Likewise candidate tree
`scan` line17930 allocates a Stat in its leaf branch. These routines are
recursive scheduler code on both sides. Expanding only the ordinary-worker
admission set does not address this representation gap.

**Decisive experiments.** First remove only the lex loop's state Tuple in a
saved-C diagnostic, maintaining Mode's existing boxed representation. Then
separately flatten Mode to tag/payload and make known scalar state `u32`.
The second experiment is a multiword return through one recursive scheduler
producer/consumer region, retaining ordinary wrappers at its boundary. Count
the allocations eliminated and compare machine code, not only C line count.

**Correctness.** Current product demand refusal is intentional: raw malformed
values can reach a String match's invalid-tag branch before state is demanded.
The existing `nq_entry_demand` rule must not be globally weakened to claim all
ADTs exhaustive. Use proven constructor provenance or a checked/private entry
with a representation contract, and preserve the generic adapter for uncertain
values. Dependent layouts, erased fields, untrusted raw annotations, width
limits, effects, parent-versus-field disposal and parallel result slots need
explicit treatment. An ordinary C loop can be optimized without changing the
scheduler stack discipline.

## 2. Sharing, borrowing and reuse are three different facts

Upstream's ownership analysis is an emission fixed point, documented at
[`file_new`](https://github.com/bendlang/bend/blob/059266225b77c8ca256ac6b25ee5c21449bab151/bend2/comp.ts#L1299):
boxed parameters start borrowed; use in an owning position marks a root owned;
lending constraints propagate through calls; duplicated box types become hot.
`compile_book` repeats emission until its ownership/hot/static facts stabilize.

The consumers are specific:

- `brw_of` identifies borrowed boxed parameters, excluding arrays.
- `val_own` propagates ownership or lending requirements to the original root.
- `val_owned` restricts keep/drop work to owned `box` words.
- `bind_pop` retains earlier uses only for owned box words and heats their type.
- `node_fields` borrows fields without taking/freeing their parent when rooted
  in a borrowed parameter. Cold owned constructors can use `term_loc` directly.
  Hot/static constructors use `ctr_take`.
- `ctr_build` seals fields only for hot constructors and can reuse a compatible
  spare returned by a consuming match.

Candidate23 instead uses generic `nc_keep_uses`/`nc_drop_dead`, and
[`nc_ctor_specs` plus `nc_default_ctors`](../../selfhost/src/back/native/book.bend#L146)
mark constructors hot. [`nc_destructure`](../../selfhost/src/back/native/bridge.bend#L424)
takes and immediately frees ordinary constructor storage.
[`ne_constructor`](../../selfhost/src/back/native/emit.bend#L27) allocates new
storage. This is conservative, but it loses three distinct opportunities:
omit pointless scalar RC checks; read borrowed values without ownership traffic;
reuse a consumed allocation instead of freeing and allocating again.

**Exact tree witness.** Upstream `warp` at line2121 and `warp_zip` (`spin_10`)
at line1449 of `native-heldout-baseline02/tree-upstream/program.c` read Node
fields through `term_loc`. The common `warp_zip` branch reuses `_sp_3` and
`_sp_4` as its two inner Nodes, then allocates one outer Node; stores are plain
words. Candidate23 `warp_zip` does generic `ctr_take`/free, allocates all three
Nodes and seals fields. Its corresponding scheduler adapter is line21339 of
`native-facts23-rest/tree-selfhost/program.c`.

**Do not repeat the rejected experiment uncritically.** P68-018 already tried
omitting selected user-constructor seals: tree improved only about8%, lexer
became slightly worse. That disproves the premise that seal omission alone
will close parity. It does not test the combination of cold direct reads,
scalar kinds, borrowed arguments and reuse. Conversely it would be wrong to
credit all the allocation gap to RC: temporary products and closure objects
also allocate.

**Decisive experiment.** Use separate saved-C arms for (a) omission of seals,
(b) replacing proven-cold take with direct field loads, (c) retaining/reusing
unique consumed storage, and (d) the combination. Keep generic shared/foreign
fallback. For Map, identify whether the key/String is borrowed across a helper
call or merely kept/dropped: borrowing must remove a real owning round trip,
not just rename a retain. Report fresh per-site allocation counts because
aggregate `heap_alloc` mixes wrappers, data, closures and tasks.

**Correctness.** Cold means the constructor graph cannot be shared in this
closed representation domain; affine source syntax alone is insufficient.
Passing borrowed fields onward must retain the lifetime of their owning root.
Reuse needs unique storage, compatible physical allocation class, no remaining
alias and exactly-once disposal when a branch abandons the spare. A global
whole-runtime RC replacement is neither required nor justified by this audit.

## 3. Direct scheduler-to-worker calls are real, but not the entire answer

The earlier suggestion survives source inspection in a narrower form.
Upstream [`emit_expr` and `emit_body`](https://github.com/bendlang/bend/blob/059266225b77c8ca256ac6b25ee5c21449bab151/bend2/comp.ts#L2395)
use `flat_call` at each call site, including inside scheduler bodies.
`emit_fuse` invokes an ordinary `spin_*` worker and continues locally.
For certain single-site tail calls it instead fuses the callee body into the
same scheduler region without making recursive C calls.

Candidate23 first lowers scheduler bodies, then admits workers in
`nf_finish_show`, then replaces their entry bodies through `nf_wrap_segments`.
The original callers still jump into those adapters; non-tail calls made a
continuation with `nc_let_cut` before the worker plan existed.

The distinction is visible in tree `warp`'s Leaf/Leaf arm: upstream invokes
`spin_9` immediately. Candidate23 jumps to `$direct.warp_leaf`, whose host
entry calls the equivalent worker and then returns through the scheduler.
Upstream's `warp` join similarly calls `spin_10` for `warp_zip`.

However **upstream `warp`, `flow`, recursive Map operations and closure-chain
construction still use scheduler continuations**. They do not generally recurse
on the C stack. Directly compiling arbitrary recursion is not an explanation of
their speed and introduces a separate stack-safety problem. The earlier count
ratios also make this caution useful: tree had only about1.17× as many segment
entries as upstream while runtime was about3.1×. Segment cost varies, so this
is not a bound, but it rejects an argument based on dispatch frequency alone.

**Decisive experiment.** Rewrite a saved-C non-tail call to an already-admitted
worker into a local call plus its existing continuation suffix, preserving
argument order, ownership, error checkpoints and device fallback. Record
removed dynamic continuation/frame entries separately from allocations. A
second arm bypasses only tail worker adapters; it may show a smaller gain.
No new C recursion is needed for either arm.

**Implementation seam.** Compute a validated worker plan before scheduler
lowering and pass it as explicit lowering context. Reuse this plan for worker
emission and reachability instead of rediscovering it. Do not smuggle trusted
worker eligibility through forgeable user KDef metadata. Preserve ordinary
entries for unknown closure/foreign/device calls. Keep stack admission at
acyclic callees plus self-tail loops until a separate argument supports more.

## 4. Closure construction has a parity gap and an upstream ceiling to beat

The candidate already raises full arity and its `nd_eta_entry` creates shared
curried adapters. That is **not** the same as constructing a partial application
directly at its use site. `nd_app_to` recognizes exactly saturated named calls;
partial uses still take `nf_slow_app` and `nc_app_slow`.

In candidate23 `closures-selfhost/program.c:16213`, a positive `chain` step
enters the zero-argument `compose` entry, constructs the add closure, applies
compose's first curried closure, recursively obtains the second argument, and
applies the next curried closure. This produces intermediate allocation and
dispatcher work. Upstream's `call_eta` and subsequent lowering specialize the
known prefix: after recursion, `chain_K38` at line2156 in
`native-baseline02/closures-upstream/program.c` allocates one two-field closure
capturing the evaluated scalar and recursive closure.

**There is also visible headroom beyond upstream.** At upstream
`chain_C39:2171`, applying that closure allocates a one-field closure for the
known add lambda and immediately sends it through `FID_CLO_APPLY`. It then
invokes the unknown recursive closure. A local known-target simplification
could compute the add directly and retain only the genuinely dynamic call.
This is ordinary closure conversion/specialization, not replacing a benchmark
with its closed-form arithmetic answer.

**Decisive experiment.** Arm1 builds partial named calls with evaluated captures
directly, eliminating the curry spine. Arm2 also eliminates the local known
lambda allocation/application in the resulting closure body. Compare both
against upstream and test another higher-order combinator/capture shape. Keep
construction time and application time separate where the harness permits.

**Correctness.** Captures must be evaluated once at the same demand point;
only the final missing argument is delayed. Preserve partial, oversaturated,
foreign and bang calls, captured ownership, constructor-stored function values
and first-error order. Upstream currently leaves the add closure in the body;
its presence is evidence of an opportunity, not proof that our implementation
can eliminate it under every raw input contract.

## 5. Runtime revision is a controlled secondary axis

The two generated C files do not contain byte-identical runtime kernels.
Candidate `term_peek` reads a redirect through `rfc_view`, which performs two
32-bit atomic loads and a conditional acquire. Pinned upstream uses
`w64_load` to read the immutable redirect location; its `ctr_take` reads fields
before acquiring the unique counter. The signatures also differ (`Env` versus
memory pointer), and upstream `term_keep` accepts an explicit increment count.

These differences must be separated from emitter improvements. Earlier
P68 diagnostics already found only modest results from a location-read change,
so this is not the main parity thesis. A small runtime-kernel swap with the
same emitted program is a useful control; wholesale runtime replacement would
confound the result and requires ABI/error/concurrency qualification. Both
host dispatchers already use `musttail` plus `preserve_none`; proposing that
calling convention as a new absent feature is incorrect.

## Experiment order and implementation hypotheses

The purpose of the next session should be demonstrating large machine-code
improvements before undertaking a general refactor. Estimates below exclude
full release qualification and assume one implementer with the checked-B1 loop.
Gains refer to affected families and overlap; they must not be multiplied to
predict the corpus mean.

| Priority | General mechanism | Saved-C discriminator | Prototype / integration estimate | Hypothesized affected-family speedup |
| --- | --- | --- | --- | --- |
| 0 | Reachability-scoped bang metadata | Only change saved-C BANGS39/16→0; confirm task allocations and async checkpoints fall | under1 h diagnostic / 1–3 h narrow fix plus controls | Potentially large on tree/lexer; no gain estimate before the mode ablation |
| 1 | Native layout values, including nested products/sums and scalar kinds | Lex carries three scalar state words; Map/Stat return fields across a scheduler boundary | 2–4 h / 1–3 days in slices | 1.3–2.5× lexer/Map/tree regions; whole-family effect needs profiles |
| 2 | Known partial application and known-target closure simplification | Remove intermediate compose captures; then eliminate immediate known add closure | 1–3 h / 4–12 h restricted scope | 1.3–2× closures; a plausible path below upstream on this family |
| 3 | Per-constructor sharing facts plus unique storage reuse | Tree zipper moves from three new Nodes to one; shared control still takes fallback | 2–4 h / 1–3 days | 1.3–2× affected tree/reconstruction regions; seal omission alone was much smaller |
| 4 | Caller-aware direct worker plan | Remove a hot non-tail continuation and direct-entry wrapper without C recursion | 1–3 h / 4–12 h | 1.1–1.5× where admitted-helper boundaries dominate |
| 5 | Borrow-root summaries | A read-only helper stops keep/take/drop while owner lifetime remains explicit | 2–4 h / 1–3 days | 1.1–1.7× borrow-heavy paths; actual coverage unresolved |
| Control | Runtime redirect-read modernization | Same generated user code, altered compatible kernel only | under2 h / separately qualify | Likely small from existing evidence; do not present as a parity plan |

First compare the profile's inclusive hot costs with these paths. If the lexer
is now dominated by String generation rather than its state loop, move effort
to generated String representation/ownership instead of continuing to optimize
the already-small recurrence. Similarly, Map time may cluster in key bit walks
rather than result reconstruction. A visible source asymmetry is a hypothesis
location, not permission to assign it the whole program's gap.

## A clean architectural direction

The smallest coherent generalization is one native value representation shared
by scheduler and worker lowering: evaluated words, word kinds, constructor
shape and ownership/borrow provenance, with explicit box/unbox adapters.
Associate function summaries with private parameter/result representations,
known targets and admitted control modes. Then let a scheduler destination and
a C-local destination consume the same value facts.

This extends machinery already present instead of adding another independent
optimizer for each benchmark. It should eventually replace the parallel
one-word versus fixed-shell special cases. The common result ABI must be
planned before emitting C text; trying to infer these facts from
`N_Segment.body: String` afterwards creates fragile rewrites. A wholesale
replacement of the entire frontend or language IR is not needed for the first
experiment. Reuse existing JS/backend arity and use summaries where their
contracts match, while retaining native ownership as an explicit target concern.

For parity, match upstream's surviving computation and transport first. For
0.5×, find additional work upstream still performs: immediate known closures,
fresh producer/consumer data that can remain fields, or repeated traversals
amenable to bounded fusion. The closure witness is a concrete example of such
headroom. It does not establish that a twofold advantage exists across all
families. If numeric/array remain at1×, reaching0.5× on this six-family mean
would require the other four to average roughly0.354× upstream; that is a much
stronger requirement than eliminating their present overhead.

## Reproducibility and evidence limits

Source files inspected are unchanged from the selected source checkpoint. The
pinned upstream `comp.ts` SHA256 is
`2b13224ba09a9e39e37cccf06e449c1bdafe5e03a81641654f7d0e455507629c`.
Candidate generated C SHA256 identities:

| Family | SHA256 |
| --- | --- |
| Tree | `277d7adb6bf59b3d70fdd254b40142483ebd1e1878584c05a7487a73dea448e2` |
| Map | `1a4d1a59191ce115af04765dc0373e82803dc4ba6116f7a99bbfbd6d4d09847b` |
| Closures | `eef056e6069ed0c9364f40b5bf5715e2428958143f0b950849bec844d2dcb9ca` |
| Lexer | `5a6a19f98a4ed6f4135333f0f9cce814a3626677b0242f99d17b489ec5bf3cd1` |

Old dynamic counters in `facts-runtime-counts20/report.json` have diagnostic
scope and are not timing-valid. Tree/Map/closures C is byte-identical20→23, but
lexer changed and requires fresh23 counters. Whole-file counts include cold
runtime and device branches; the report above instead identifies explicit
executed-shape witnesses. Actual runtime contribution still belongs to fresh
profiles and controlled ablations in the parent campaign.

This audit builds on [the earlier upstream study](upstream-native.md),
[worker coverage](worker-coverage06.md), [world compiler mechanisms](world-compilers.md)
and [the measured array experiment](../../implementation/phase68/c-target-opportunities.md).
Their historical rankings are superseded where those optimizations have already
landed; their rejected attempts and correctness boundaries remain evidence.
