# C target: opportunities after the restart investigation

2026-10-11. Investigation only; no compiler source or installed image changed.
Upstream remains `059266225b77c8ca256ac6b25ee5c21449bab151`.

**The strongest new result is a 5.44× array speedup, reaching upstream speed in
a generated-C diagnostic.** The change combines scalar array representation
with proven-unshared access. It identifies a general compiler mechanism worth
implementing, not permission to special-case this program.

## What the 10× target means

The installed Phase67 compiler was 10.41× slower than upstream C on six native
families. This is generated-program runtime, not B1/B2 compilation latency and
not the 45-point JS corpus. Existing Phase68 experimental workers already
reduced runtime by 3.30× geometrically across those six families relative to
Phase67. Subsequent product transport and scalar packing improved selected
families further. These are distinct campaigns; they do not establish a fresh
whole-suite upstream ratio or a promoted release.

We should aim for 10× over that installed baseline, not promise another 10×
over every latest experimental program. The latter is unsupported.

## New controlled experiment

Executed prospective [P68-016](../../experiments/phase68/P68-016-scalar-arrays.md)
against the exact checked products15 array C. All four arms execute 61,440
workloads after 7,680 warmups, CPU3, Clang22 `-O3`. The packed intervention
changes element slots and removes element retain/drop/seal work together;
it does not isolate memory density from ownership overhead.

| Saved-C arm | Three samples, ms | Median, ms | Speedup over unchanged |
| --- | --- | ---: | ---: |
| Unchanged products15 | 1023, 917, 905 | 917 | 1.00× |
| Packed U32 elements | 295, 271, 270 | 271 | 3.38× |
| Direct unshared location | 843, 765, 754 | 765 | 1.20× |
| Both | 169, 169, 169 | 169 | 5.43× |

All 16 smoke observations and 12 timed observations match the independent
16-point seed/iteration oracle. All intervals exceed 100ms. Smokes cover 1/17
repetitions and 1/4 threads, but CPU affinity prevents a multicore safety claim.
Three rotated rounds are not complete four-position balance. Whole experiment:
26.03 seconds, including three C builds; largest observed build tree about
183 MiB RSS. Source admission and preparation predate this execution.

A separate saved-binary comparison used three fully position-balanced rotations
of unchanged, combined and upstream, with identical source, workload counts,
Clang path and flags. It took 6.42 seconds without rebuilding anything:

| Arm | Samples, ms | Median, ms |
| --- | --- | ---: |
| Unchanged products15 | 1017, 1022, 1033 | 1022 |
| Combined diagnostic | 185, 188, 190 | 188 |
| Upstream | 187, 188, 184 | 187 |

Combined/upstream is **1.005×**, effectively parity in this screen; unchanged /
combined is **5.44×**. Absolute clocks drifted between campaigns, which is why
the new upstream samples are compared within their own balanced campaign.
This is a small sample, not a statistical claim of a 0.5% performance difference.

Active machine code confirms the mechanism. Inside `p46.loop`, addresses
`0x19410–0x19443` form a two-element loop using four-byte loads/stores,
arithmetic and an index/loop branch, with no element ownership or array redirect
checks. The previous loop had eight-byte elements and repeated ownership and
redirect branches. Ownership work still exists outside the inner recurrence.
Both arrays fit in cache; this does not demonstrate a bandwidth bottleneck.

[Durable measurements and assembly excerpt](evidence/scalar-arrays-investigation.json).
Full receipts: `selfhost/build/phase68/scalar-array-diagnostic01/{plan,execution}.json`
and `scalar-array-upstream01/{plan,report}.json`. Reproduction methods and exact
literal derivations are under `selfhost/tools/performance/phase68/scalar-arrays/`.

## Ranked next opportunities

Time estimates are focused engineering effort, excluding unexpected correctness
failures and full release qualification. Speculative gains are for affected
programs, not the geometric mean; overlapping mechanisms cannot be multiplied.

| Priority | Mechanism | Runtime gain evidence or estimate | Implementation estimate / risk |
| --- | --- | --- | --- |
| 1 | Scalar layouts plus independent sharing facts for arrays | **5.44× measured** together on current array diagnostic; broader gain unknown | 6–12h for a conservative closed-flow U32 slice; 1–3 days for broad operation coverage. Medium/high correctness risk at layout/ownership boundaries. |
| 2 | Preserve scalar/product layout facts through private worker arguments and results | Hypothesis **1.2–3×** on other generic-value-heavy code; possibly little where Clang already removes checks | 1–3 days, incremental extension of existing product workers. High potential, medium confidence; raw API and branch joins need conservative fallback. |
| 3 | Known closure targets with explicit captures; broader safe ordinary-worker coverage | Hypothesis **1.5–4×** on closure/dispatch-dominated programs, little elsewhere | 4–8h bounded prototype; 1–2 days integration. Medium/low gain confidence until a fresh saved-C ablation. Preserve escaping closures and bounded-stack behavior. |
| 4 | Immediate scalar facts to omit surviving retain/drop operations | Hypothesis **0–15%** on affected numeric code | 1–3h narrow prototype. First inspect optimized assembly: redundant C text may already be free. |

Priority 1 implements the demonstrated win. Priority 2 makes the representation
lesson apply to records, scalar state and other workers. Priority 3 addresses a
different remaining cost: prior coverage inspection found no ordinary workers
for authored closure workload functions, versus broad numeric/array coverage.
Coverage counts are not execution-time attribution; profile before expanding it.

The common architecture is a small representation/use summary before C text
emission: scalar kind, product fields, ownership, possible sharing and known
call target. Facts join conservatively and unknown values retain the generic
ABI. It is an extension of the current private-worker/product architecture,
not a prerequisite wholesale LLVM rewrite.

## Upstream and external compiler lessons

Pinned upstream `comp.ts::lay_c/lay_arr` selects scalar storage;
`arr_cells/arr_op` retains only boxed leaves; `facts_hot` computes possible
sharing; `arr_loc` can reuse locations with a handle-equality fallback. These
are separate facts. Our closed-flow intervention demonstrates their value on
one hot path. See [source comparison](../../research/phase68/array-after-products15.md).

Go's [directClosureCall](https://go.dev/src/cmd/compile/internal/walk/closure.go)
passes captures as ordinary arguments to avoid a closure allocation. That is a
useful model for priority 3, not evidence for its estimated Bend gain. LLVM's
[scalar replacement pass](https://llvm.org/docs/Passes.html#sroa-scalar-replacement-of-aggregates)
splits suitable aggregates into scalars. Our runtime heap protocol obscures
those opportunities, so exposing fields before emitting runtime operations is
the relevant lesson. The existing
[compiler survey](../../research/phase68/world-compilers.md) also covers GHC
worker/wrapper and Lean ownership-aware reuse; there is no need to repeat a
large literature survey before implementing the measured representation win.

## What to deprioritize

Earlier saved-C reference-count-read changes improved arrays 5.6% but made the
lexer 1.1% slower. Selected lexical storage reuse sites improved Map about 0.6%
and tree about 2.9%. Those finite experiments do not disprove every form of
reuse, but they do not support making it the main parity strategy. Per-let
error checks disappear from the inspected host hot path. More blanket inlining
is also unconvincing: the relevant product helpers already inline.

## Safe, fast implementation sequence

1. Add one conservative scalar-array representation path. Prove producer and
   consumer compatibility; prove sharing separately. No admission by benchmark
   name and no trusting an arbitrary raw type annotation.
2. Cover all reachable consumers before permitting a packed producer. Unknown,
   foreign, escaped or mixed-layout flows fall back. Broad integration must
   handle new/get/set/swap/clone, destructuring, joins/splits, atomics and ABI
   boundaries. A separate checked entry is an architectural option, but its
   authentication boundary must be audited first.
3. Use small non-benchmark correctness controls for scalar boundaries, retained
   aliases, branches, clone/mutation and fallback. Build checked B1, then run the
   fast actual-generated-C array comparison; diagnostic C alone is insufficient.
4. Extend facts to independent tree/map/closure programs only after inspecting
   their remaining active work. Require a cheap ablation before a broad pass.
5. At integration, run six-family C timing, actual B1/B2 C-emission timing, JS
   output/runtime protection, conformance and line/module counts. Only then
   consider release promotion.

The six-family geometric mean prevents an array-only success from solving
everything: 5.44× on one of six equally weighted cases improves that aggregate
by only about 1.33×. Achieving the full baseline-to-parity target requires
general representation improvements across the remaining families.

No subagents, compiler rebuilds, broad conformance runs or PR comments were
needed for this investigation. Three diagnostic C builds and 21 timed runs
occupied about 32.5 seconds of guarded execution in total. The main remaining
cost is correct compiler integration, not measuring this hypothesis.
