# Phase70: preserve unchanged roots, broaden native coverage, reduce compiler work

The user authorizes all three recommendations after Phase69: one focused
general native optimization, independent generalization checks, then profiling
and improvement of C compilation. Starting checkout is `32d159b`, installed
checked B1 `674e7960…`, genuine B2 `c858dfa5…`; pinned upstream stays `0592662`.
Compiler algorithms remain in Bend. No PR comments are authorized.

The [Phase69 report](../../implementation/phase69/README.md) gives the baseline:
six-family native execution geometric mean 1.0332× upstream, with tree/Map/lexer
at 1.429×/1.595×/1.816×. Its separate three-source C request means are 3.231× B1
and 2.183× B2. These metrics have different workloads and clocks. The closure
advantage must not hide the remaining native tail.

## 1. Analysis before native emission

Implement the bounded [root-preserving observer design](../phase69/root-preserving-observers.md).
Its saved-C Map intervention reached 0.909× upstream; this is motivation, not
credit for a production change. Prove structural identity of returned roots
while preserving all residual scalar computations, errors and recursive calls.
Use branch-local origins, exact constructor fields, capture-safe helper expansion
and bounded self-recursive summaries. No source/function-name admission rules.

First produce a compiler-owned plan/refusal result with unchanged generated C.
Require positive controls over unrelated one- and two-root user ADTs, and
negative controls for changed/reordered fields, escaped children, effects,
mutual recursion, non-tail residual recursion and unsupported representations.
If the first analysis cannot certify the motivating shapes within the stated
bounds, record the specific refusal before extending the emitter.

## 2. Restricted borrowed worker and production runtime evidence

Keep owned roots in an ordinary adapter. The private worker contains only
borrowed cursors and immediate scalar values; it cannot allocate, mutate,
consume or return a borrowed box. Retain simultaneous tail moves and existing
error/poll conventions. On success the adapter rebuilds only the public result
shell, moving each original root exactly once. Shared/static/RFC roots and
aliased inputs receive explicit controls.

Permission comes from the checked compiler boundary, never a user-controlled
book marker. Raw and device routes retain ordinary behavior. The initial
representation domain excludes arrays, scalar Word views, unknown/dependent
layouts and packed single-field recursive nodes. Foreign identity observation
or mutation disqualifies the program unless independently proved safe.

Use a checked B1 development build, small admission/semantic controls and a
Map discriminator before broad validation. Measure against saved Phase69
artifacts and upstream in the same balanced campaign. Operation counts and
generated-code evidence must show removed reconstruction rather than shifted
work. Reject a speedup with changed demand, errors, ownership or stack growth.

## 3. Independent native generalization

Select four to six additional deterministic programs before observing their
performance. Reuse repository examples/tests where possible and include renamed
user ADT observers, different traversal shapes and at least two non-observer
workloads. Inputs, independent checksums, repetition counts and source origins
are explicit. Keep startup and output outside kernel timing; use common work,
balanced roles and adequate clock intervals.

Report this added set separately from the frozen six-family metric. Do not
change corpus membership or weights to make an aggregate improve. Record
refused/unsupported cases and test preserved-root identity independently from
mere output equality. Expand semantic controls when new representation or
control-flow cases are admitted.

## 4. Compilation profiling, then causal optimization

Profile selected B1 and genuine B2 C requests using existing stage timers,
V8 CPU profiles, source-owner attribution and exact output validation. Separate
Base preparation, imports, frontend/checking, native planning/emission, output
construction, Clang and generated-program execution. Diagnose retained/repeated
work rather than assuming all wall time belongs to the Bend compiler.

Use numeric/array as short screens and lexer/Map as larger source checks.
Collect the Phase69 baseline in fresh Phase70 paths; if observer integration
changes compiler cost, profile the selected candidate separately. Rank fixes by
measured time share, avoidable work, implementation size and cheapest falsifier.
Register each concrete optimization before executing it. Reuse accumulated
compiler research and the pinned upstream implementation where relevant.

For pure compiler-speed changes require byte-identical emitted C/JS on the
affected corpus. Preserve diagnostics, cache invalidation and optional-analysis
fallback. Prefer removing repeated analyses and sharing existing facts to a new
general IR or persistent global cache. Establish a controlled paired B1/B2
comparison before claiming a compilation improvement; Clang timing is separate.

## Resource, parallelism and checkpoints

Root owns production integration and one CPU3 target tree with 2 GiB tree RSS,
1 GiB Node heap, 4 MiB stack and 4 GiB available-memory floor. Five independent
source/data lanes on CPU0 own origin analysis, observer emission, adversarial
review, coverage and methods. They do not run compiler/native targets or commit
competing production patches. Bind a shared plan schema before emitter work.

All fresh raw goes under `selfhost/build/phase70`; Phase69 and older raw/tools
are sealed and unchanged. Preserve the installed baseline and unrelated dirty
files. Exact producer versions and failed attempts are retained. Node-based
validation uses the already diagnosed sandbox escalation when necessary, with
the same resource guard. Do not nest guards or broaden tests without a reason.

Commit/push this design first, coherent source checkpoints, then the final
[report](../../implementation/phase70/README.md). Record per-family runtime,
B1/B2 request cost, correctness scope, Bend source/module growth, memory and
guard occupancy separately. Only the selected stable candidate receives the
broader native gate, JS protection, genuine self-hosting and installed-release
qualification. Deferred lexer state/reuse changes stay outside this phase
unless new evidence makes them necessary for the authorized sequence.
