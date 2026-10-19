# Phase112: exact hot call boundaries

The next useful boundary is ordinary argument evaluation between a saved
continuation and its call. A strict adjacency recognizer misses common, pure
assignments. This explains both ray's unchanged frames after widening and a large
compiler string-equality opportunity. Other hot functions need genuinely broader
work: non-tail recursion, recursive groups, or nested Boolean evaluation.

This is a bounded source/QBE audit, with no target execution or production edits.
The proposed pure-gap extension was pending during this audit. Observed event
counts below are from already-qualified diagnostic runs, not time shares. No
claim is made that the proposed transformations have passed or improved timings.

## Compiler: four hot functions

Counts come from the word compiler's unchanged `lexer-scan` request. Frame counts
are obtained by decoding each function's static frame-target IDs and summing
their dynamic `frame_fid` buckets. These continuation IDs are unique in this
snapshot. Public-call attribution includes private runtime work charged to the
last dispatched segment, so it is not an exclusive native-call-stack profile.

| Public function | Measured entries | Attributed public runtime calls | Live frames originating here | First boundary |
|---|---:|---:|---:|---|
| `$direct.p88_string_eq_go` | 1,447,631 | 8,559,744 | 964,973 | Two pure argument copies before an already-private character equality call |
| `$direct.String.append` | 1,313,535 | 3,778,021 | 1,232,243 | Non-tail self-recursion; readiness cannot be established |
| `$direct.p88_digits` | 1,087,899 | 11,105,052 | 2,288,829 | Nested retained values and frames; structured Boolean computations inside gaps |
| `$direct.String.cmp` | 548,651 | 6,750,443 | 514,711 | Two pure copies before character comparison, followed by a recursive reconstruction group |

### Consuming string equality: the cleanest general opportunity

The [checked source](../../selfhost/build/phase112/word-source02/compiler.bend:6)
consumes two strings, compares their characters, and tail-recurses on the tails.
The [generated frame](../../selfhost/build/phase111/p112-word-full-emit01/program.ssa:693407)
captures the two tails. Two copies then prepare the characters before calling the
existing private `Char.is_eq`. The continuation at line693474 only loads its two
captures and the comparison result, then tail-jumps to `p88_string_eq_go`.

The callee is already admitted, the continuation is small, and the source recursion
is tail recursion. A correctly guarded pure-gap fusion can expose the self-tail
transition to the region planner. This is distinct from accepting arbitrary
recursive private calls. The measured candidate opportunity is **964,973 frames**
and their return/capture transport, with no need to change the string algorithm.
It still requires actual admission, ownership/output qualification and timing.

### String append: a real non-tail recursive dependency

The [Base definition](../../selfhost/.bootstrap/upstream-phase66/bend2/base.bend:1886)
constructs `SCon{head, String.append(tail, suffix)}`. Its
[frame](../../selfhost/build/phase111/p112-word-full-emit01/program.ssa:704563)
keeps the head until the recursive result returns; the continuation at line704580
constructs the final cell. There are two ordinary copies before the recursive
call, but removing that gap is insufficient: fusion requires the recursive
callee to be in the frozen ready set, and this function cannot enter that set
while it still contains its returning self-call.

Current readiness handles self-tail loops and already-established callees; it
does not establish a private ABI for a non-tail recursive group. Options include
an explicitly qualified recursive calling convention or a proven destination/
accumulator transformation. A direct C-stack recursive call needs depth and stack
behavior qualification; it should not silently replace the runtime continuation
stack. The 1,232,243 observed frames are applicability evidence, not all safely
removable by the proposed pure-gap change.

### Digit parsing: Boolean evaluation is now the visible structure

The [source](../../selfhost/build/phase112/word-source02/compiler.bend:37953)
checks digit range, length, leading-zero rules and overflow before tail-calling
`p88_digit`; that helper tail-calls `p88_digits`. The emitted function's 12 live
frame sites execute **2,288,829 times**, three frames per 762,943 digit cases.
Other syntactic frame sites in this function have zero counts in this request.

A representative live sequence starts at
[QBE line24118](../../selfhost/build/phase111/p112-word-full-emit01/program.ssa:24118):
an outer frame, retains of scalar values, a second frame, another retain, a third
frame, then comparison computations before the private `Bool.and` call. The
comparison operations are already structured `N111Bin` plus `N111If` from
[`p112_scalar_compare`](../../selfhost/tools/performance/phase112/scalars.bend:61).
They are **not** merely late QBE text expansion. A flat Set/Bin gap recognizer
therefore still stops at the first structured branch. Outer retains and frames
are additional barriers even if pure branches are later supported.

The source types also identify duplicated `acc`, `digits` and `d` as U32 values;
their generic `keep` calls are scalar ownership overhead. They are not evidence
that arbitrary Boolean or heap owners can be dropped without checking their
representation. `Bool.and` is already a private worker; `Bool.or` still appears
as runtime primitive68 in the continuation. A general scalar/Boolean fact pass
and structured predicate lowering could simplify this graph before continuation
construction. Simply renaming more call sites cannot do that. Even after local
fusion, the `p88_digits ↔ p88_digit` mutual tail-recursive dependency needs an
appropriate group/loop treatment for full private admission.

### String comparison: local fusion plus a larger recursive group

The [character-comparison frame](../../selfhost/build/phase111/p112-word-full-emit01/program.ssa:712199)
has the same two-copy gap and calls an already-private `Char.cmp`. Its continuation
tails to `String.cmp.fin`. Removing this frame could help the public path even
without admitting the complete recursive group.

However, [Base `String.cmp.fin`](../../selfhost/.bootstrap/upstream-phase66/bend2/base.bend:1903)
recursively compares the tails and reconstructs both strings through
`String.cmp.rec`. Its equal-character branch creates another
[returning frame](../../selfhost/build/phase111/p112-word-full-emit01/program.ssa:711907),
observed **434,945 times**. `String.cmp.fin` itself has 514,711 entries. Pure-gap
fusion alone does not remove the `cmp ↔ cmp.fin` non-tail recursive dependency
or the reconstruction required by this API's semantics. Reusing a consuming
comparison where ownership and callers permit it is a separate semantic change.

## Ray: why widening did not change the hot graph

The multi-wide source really uses 32 arguments and captures. Its QBE still lacks
private `$direct.sx`, `$direct.sy`, `$direct.isect.t`, `$direct.isect.go2`,
`$direct.isect.go`, `$direct.isect5` and `$direct.nearest`. It does contain private
`fl`, `isect.t2`, `sz` and `sr`. The leading dollar is part of the semantic name;
the similarly named non-dollar exported wrappers are different functions.

- `sx` has a [frame at line18368](../../selfhost/build/phase111/p112-multi-wide-batch01-variation-ray-active-256-2240-emit/program.ssa:18368), then constants35 and10, then `fl` argument stores. `sy` has the same form with6 and10. A single non-tail branch prevents admission of each complete worker.
- `isect.t` has a [frame at line18828](../../selfhost/build/phase111/p112-multi-wide-batch01-variation-ray-active-256-2240-emit/program.ssa:18828), then constants1 and1000 before `fl`. This blocks the readiness chain `isect5 → isect.go → isect.go2 → isect.t`. The `F32.sqrt` primitive in `isect.go2` is permitted by the runtime-call whitelist; it is not this rejection cause.
- `nearest` has an [outer nine-capture frame](../../selfhost/build/phase111/p112-multi-wide-batch01-variation-ray-active-256-2240-emit/program.ssa:20460), a retain, an inner seven-capture frame, then one argument copy before `sx`. Subsequent continuations repeat a frame/copy/call pattern for `sy`, `sz`, and `sr`, with capture counts8,9,9. The four inner frame families account for **143,136** measured frames, **42.85%** of the region ray profile's334,011 frames. This is an opportunity count, not a prediction that all will disappear.

The same profile records55,464 entries each to `sx` and `sy`,53,496 each to
`isect5`, `isect.go`, and `isect.go2`,11,328 to `isect.t`, and39,760 to `nearest`.
The `sx` returning frame executes6,004 times; `isect.t`'s executes11,328 times.
These counts are from the **region profile**, not a new multi-wide profile.

Even after the inner chain becomes fusible, `nearest`'s outer35,784 frames need
separate treatment. Retain and nested-frame operations are not pure assignments.
The current forward scanner also prepends an untransformed outer frame before
scanning the inner suffix, so it does not revisit that outer frame afterward.
No frame or ownership operation should be silently skipped by a pure-gap rule.

## Exact rules behind these refusals

[`p112r_target`](../../selfhost/tools/performance/phase112/regions/terminal.bend:34)
finds a target only through contiguous scratch stores followed by jump/return.
[`p112r_tail`](../../selfhost/tools/performance/phase112/regions/terminal.bend:16)
then requires exactly the expected argument stores. The
[multi-region target check](../../selfhost/tools/performance/phase112/region-multi/build.bend:14)
also requires a previously admitted callee. Real retained frames are rejected by
the ordinary [region statement scan](../../selfhost/tools/performance/phase112/regions/plan.bend:22);
only exact fail-stop paths have a separate frame exception. The frozen-ready
rounds establish dependencies in order; increasing their count does not solve a
recursive dependency that never acquires its first ready member.

The smallest useful next qualification is therefore a general, bounded pure-gap
rule that snapshots captures before replaying the gap in order. Pointer/state/
scratch mutation, owner calls, nested frames and unknown effects must remain
refusals unless independently handled. Demonstrate admission and dynamic frame
reduction on string equality and the ray helper chain before broad measurement.
Non-tail recursion and nested predicate evaluation should remain separate
experiments with explicit contracts.

## Evidence pins

| Artifact | Bytes | SHA256 |
|---|---:|---|
| `phase111/p112-word-full-emit01/program.ssa` | 28,462,589 | `bdbf31bcea3c1d99599c896ec48e4fb67430e47b34134c5b834fbed146047617` |
| `phase112/word-source02/compiler.bend` | 1,990,734 | `efac7e31641c32af5e6baf636ee3216210f7cd574ac9412a6cfb20e7d2975128` |
| `phase112/profile-word-compiler01/profile/profile.json` | 5,957,198 | `df395f315a94c94e819f99ac960cc20e4d3d941d8e80dc42b93e83fe53cb33a6` |
| `phase111/p112-multi-wide-batch01-variation-ray-active-256-2240-emit/program.ssa` | 912,452 | `dffb298fde6285169f5bf35dfff4a34191e9dd4aeede6e309538ff1f9c5d3986` |
| `phase112/multi-wide-source01/compiler.bend` | 2,018,574 | `aafea8a20bc9b2d0114eec0c2be3ff86c90b861062032aa5cea61f2c1c08bd39` |
| `phase112/profile-region01/variation-ray-active-256-2240-profile/profile.json` | 142,134 | `c216255f33688f8294bca5541dff0796a13957e199b043e76a902ee946dc1482` |

Paths in this table are relative to `selfhost/build/`. The original compiler
profile's output contract and snapshot differences are documented in
[`profile-comparison.md`](profile-comparison.md). Source-level counters overlap,
instrumentation perturbs execution, and entry frequency alone cannot establish
CPU cost or an expected wall-clock speedup.

## Executed gap01 follow-up

The new `profile-gap01` relinks the exact qualified six-program objects with the
same diagnostic runtime. Every full output passes. It confirms that the runtime
win accompanies fewer actual frame calls, not just additional emitted workers.
Instrumented elapsed time is excluded from performance results.

| Fixed case | Word frame calls | Gap frame calls | Reduction |
|---|---:|---:|---:|
| lexer | 236,043 | 163,303 | 30.82% |
| variation-ray-active-256-2240 | 334,011 | 66,509 | 80.09% |
| coverage-closures-256 | 2,120 | 2,110 | 0.47% |
| coverage-unicode-text-64 | 7,656 | 6,878 | 10.16% |
| coverage-map-churn-128 | 54,382 | 52,128 | 4.14% |
| coverage-numeric-recurrence-1024 | 70 | 56 | 20.00% |

The checked ray admission diagnostic (`p112-gap-diagnosis01/report.json`) finds
332 workers across frozen ranks1–6. sx/sy and the isect dependency chain now
admit; generic nested outer frames remain. The six-point matched uninstrumented
runtime campaign separately measures16.69% less geometric time, including
ray4713→2075ms. These counts and timings support the specific structural cause;
they do not establish the same speedup on every program.
