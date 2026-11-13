# Phase192 parity frontier: consume the existing recursive-region plans

The strongest new avenue is **porting QBE's existing checked recursive-region
selection into direct x86**, preserving its bounded local continuation loop and
runtime stack semantics. The x86 public renderer currently ignores this entire
capability. Fresh physical profiles show substantial continuation, wrapper and
dispatch work in expression, tree and lexer. They do not support making another
small register-allocation or isolated Boolean cleanup the primary parity effort.

This is a missing lowering route, not a request to invent native recursive
calling conventions. Existing local plans and their admission rules already
describe the transformation. Root selected a bounded experimental H-plan port;
this investigation made no production edits and ran no target/compiler jobs.

## Exact missing boundary

`selfhost/src/back/x86/program.bend:x181_prepared` consumes the shared
`P169Prepared` cursor after unchanged admission. The cursor's `P134Context`
retains `ids,index,direct,ready,view,lookups,heap,mode`. At
`x181_program_public` (line 202 in the inspected source), x86 ignores the fusion
index and callable registries and always calls `x181_segment(segment,ids)`.

QBE's corresponding `stream-emission.bend:p134e_public` passes the same public
segment/context to `p124r_public`. In `helper-resume.bend`, this chooses the
existing direct/H/R/G/extended-H routes before the generic/fused fallback.
`local-continuations.bend` supplies typed `P114HPlan`, `P114RPlan`, and `P114GPlan`
before its QBE text renderer. Therefore neither the shared cursor nor the
verified semantic input inherently prevents x86 from taking the route.

The [exact symbol inventory](../../selfhost/build/phase192/parity-audit01/recursive-coverage.json)
authenticates all 45 retained QBE and Phase191 products. QBE has `p114r_*`
workers in every case; x86 has none. Excluding ubiquitous `String.length`
leaves **27 eligible cases across 14 families**: tree, expression, lexer,
symreg, BST, text, Map, records, editdist, raytrace, generic rows and three
functional tests. This is candidate coverage, not measured hotness; the current
checked cursor must still re-admit each plan. The retained QBE compiler is older.

Specific witnesses from the authenticated
[machine audit](../../selfhost/build/phase192/parity-audit01/report.json):

| Worker | Phase191 x86 | Retained QBE |
|---|---|---|
| Expression `eval` | 302 instructions, three `p111_rt_jump` sites and one `p111_rt_return`, ordinary `p111_FID` worker | `p114r` core: 204 instructions, internal descend/unwind loop, no `rt_jump`/`rt_return` in core; outer wrapper retains return |
| Tree `warp` | 596 instructions, two `rt_jump`, two `rt_return`, 21 static calls | `p114r` core: 301 instructions, 20 calls, direct ready-helper calls and local continuation loop |
| Tree `scan` | 205 instructions, one `rt_jump`, one `rt_return` | `p114r` core: 141 instructions and direct `stat_join` helper call |
| Lexer generator | Ordinary public `gen` plus continuation segments | QBE has a `p114r` generator region |

The expression QBE loop starts at `0x409d30`, pushes captured continuation data
on the existing runtime stack and branches back locally. X86 `eval` is at
`0x40d0f7`; its continuation transitions leave the worker through runtime calls.
Instruction totals include alternatives, helpers differ in representation, and
these are not instruction-per-iteration or speedup estimates.

## Fresh profiles: where the cost actually sits

Root captured [profile01](../../selfhost/build/phase192/profile01/report.json)
from frozen Phase191 baseline/C products. The offline
[assessment](../../selfhost/build/phase192/profile-analysis01/report.json)
verifies all plan/manifest/raw identities, recomputes all 12 raw analyses,
and reproduces the pooled comparison. Every pool is adequate under the
maintained comparator, with two periods (8/13 ms), no rejected capture, zero
loss/overrun, at least 99.911% whole-child CPU coverage and 99.9995% sampled-thread
coverage. Raw `profilesUsable=false` does not invalidate these pools: individual
captures are below 500 samples; identical within-role pools exceed that floor.

| Case | Role | Own repetitions | Samples | Unknown weighted share | Clean CPU µs / repetition |
|---|---|---:|---:|---:|---:|
| tree-bitonic | x86 | 3,538 | 558 | 4.662% | 784.030 |
| tree-bitonic | C | 17,378 | 580 | 0% | 165.636 |
| expression-32 | x86 | 460,297 | 540 | 2.056% | 5.790 |
| expression-32 | C | 1,254,826 | 552 | 0% | 2.189 |
| lexer | x86 | 1,291 | 528 | 4.788% | 1,967.527 |
| lexer | C | 6,766 | 553 | 0% | 385.774 |

Each role has one independent clean observation. Fractions use period-weighted
samples; estimated leaf CPU multiplies that fraction by its own clean CPU and
divides by its own repetitions. Startup/warmups/validation remain included.
There are zero cross-role pooled comparisons. All native pools fail the older
additional zero-unknown rule, though the maintained comparator keeps unknowns
in denominators and admits them. Lexer sampled/clean wall ratios are 1.043 x86
and 1.056 C, so disturbance remains material. Counts are not confidence bounds.

**Expression is the clearest structural witness.** Its x86 `eval` owns 20.13%
of samples, estimated 1.166 µs/repetition. C's generated `eval` owns 52.01%,
estimated 1.138 µs. These physical leaves have different inlining boundaries,
but the comparable absolute estimates contradict the idea that scalar
instructions in the named evaluation worker alone explain the total 5.790 vs
2.189 µs gap. Anonymous x86 continuation leaves own 33.36%; explicit
`rt_jump`/`rt_return`/`set_regs`/`work_loop` leaves own another 14.43%.
The generic public `p37.expr.pick` wrapper alone is 6.09%; `p37.expr` is 5.18%.

**Tree combines region and ownership costs.** The current x86 `warp` is 13.41%
(105.12 µs); `ctor2` is 10.07% (78.91), `take2` 7.97% (62.48), work loop 8.28%
(64.89). Anonymous continuations total 19.84%; the four explicit dispatch
leaves total 15.59%; all ctor/take leaves total 19.03%. Generic and direct
`warp_leaf` workers are 7.14% and 4.21%. The previously inspected generic-Boolean
`warp_leaf.go` has **zero sampled PCs** here, so its impressive static
simplification is not evidence for a large whole-tree gain. C's leading physical
workers are warp_zip 22.92%, warp 15.25%, and warp_leaf 11.80%; these inline
runtime work and are not scheduler overhead despite their `WL_FID` prefix.

**Lexer is not chiefly the classifier.** `$product.lex`, which includes the
classification region, is 8.61% (169.42 µs); zero-cost removal of the entire
leaf would save at most that measured share under unchanged execution. Its
actual classifier is only part of the leaf. The product `step.at` is 6.07%
(119.53 µs), versus C's corresponding product leaf at 107.22 µs—even though
static x86/QBE/C bodies have 652/270/315 instructions. The x86 public generator
owns 9.44% (185.81), its `gen.at` wrapper 7.55% (148.57), its direct `gen.at`
6.19% (121.76), two leading anonymous continuations 15.01% together, and explicit
dispatch leaves 12.93%. These are stronger targets than classification alone.

## What the C comparison does and does not establish

C generally exposes ownership/constructor fast paths inside generated workers,
while x86/QBE make calls to `p125_rt_ctor*`, `p125_rt_take*`, and scheduler
helpers. For example tree `warp_leaf.go` has 186 x86 instructions and six
constructor call sites; C has 52 instructions with only allocation-miss calls.
Larger C workers may contain *more* static instructions than x86 because they
include heap/ownership slow paths that native helpers hide elsewhere. Whole
symbol bytes are therefore not a useful parity metric by themselves.

The old [authenticated tree profiles](../../selfhost/build/phase192/parity-audit01/retained-tree-profiles.json)
reinforce this distinction: old QBE constructors/takes own 18.11%/15.98%, and
the four dispatch helpers 15.26%. Its binary differs from today's QBE reference,
has 6.69% unknown weight, and no clean denominator; those shares must not be
transferred to current x86 or used as a speed ratio. The C tree binary matches
the current C reference. Both old raw analyses per role were recomputed.

Thus there are three separate opportunities: consume checked recursive regions;
expose known constructor/take fast paths with exact ownership/layout behavior;
and improve machine selection inside remaining workers. Root's predicate/path
and arithmetic work addresses the third. The first has an existing semantic
plan and new dynamic witnesses, making it the best next bounded implementation.

## Minimal general H-plan port and safety obligations

`P114HPlan{valid,params,body,cases}` contains typed `P114RStmt` and
`P114HCase{name,captures,result,pop,body}`. Unlike R-only constructor recursion,
H supports the multi-continuation expression evaluator. The existing
`p114h_plan(segment,index,ready)` enforces one result, no incoming continuation
or flags, arity 1..8, not already callable, <=512 body nodes, clean/hygienic
segment, and a closed table of <=8 cases with exact matching capture counts.
Do not replace these checks with a manually constructed `valid=true` plan.

1. Query the original H plan from the checked cursor. Preserve direct selection
   and mode policy; refuse unsupported nodes as a complete unit. The
   `p124r_view` extended route admits extra ready-helper cases; use it only when
   those callable symbols and result ABI are also validated for x86.
2. Translate to a structured local loop with mode/depth/value and parameters,
   using `P113DAgain` or an equivalently verified structured representation.
   Preserve scalar and frame order. Descend pushes the original continuation
   frame and increments local depth; Again snapshots every argument before
   changing parameter homes. Never turn unbounded source recursion into native
   CPU recursion.
3. Unwind tests depth first. At zero, return without touching the caller frame.
   Otherwise decrement, pop the FID word, read it, select the exact case, pop
   its capture count, restore captures, bind result and pop-status local, then
   resume renamed case code. Keep separate scratch buffers and hygienic names.
   Unknown FIDs retain the existing fail behavior.
4. Preserve `ResumeReady` frame-before-call order and `PushFrame` depth changes.
   Validate callable availability, ABI, call-clobber liveness, full-word values,
   and terminal behavior. Add the private symbol to the x86 availability index;
   retain the public wrapper's argument loads and outer runtime return.
5. Reuse existing allocation/interference validation after lowering. Bind finite
   exact-output controls for zero depth, nested/cyclic continuations, captures
   0..8, live aliases, helper resumes, malformed/refused plans, and deep recursion
   against independent oracles. Source acceptance and reused planner guards are
   not a new equivalence theorem. The checked-cursor diagnostic
   `tests/phase186/continuation-probe.bend` already reports old-H/view-H admission.

## Ceiling and falsifier

The disjoint physical dispatch plus anonymous-continuation shares are 35.44%
tree, 47.79% expression, and 28.33% lexer. **They are not removable-cost
estimates:** continuation bodies compute real results, some calls remain outside
the selected region, and local dispatch still costs work. They provide a useful
upper envelope for that named set of leaves under frozen attribution, not a
forecast for the port; wrapper/caller transport outside the set may also change.
Native constructor/take shares of 19.03%/10.56%/9.24% are another substantial
boundary, but their required allocation/ownership work cannot vanish either.

For perspective, halving all 27 candidate-covered points would reduce the
44-case geometric mean by about 34.6%, taking 2.7366× C to about 1.79×. That is
an intentionally aggressive scenario, not a prediction; symbols may be cold.
Parity requires roughly 63.5% less time across the whole geometric aggregate.
One port cannot be promised to deliver that. Its general coverage and measured
transition traffic justify a larger experiment, while a 2% classifier cleanup
does not answer the parity question.

First require current H-plan admission for eval, warp/scan, and generator. Then
inspect actual output: scheduler transitions must become local loop edges and
every independent output must match. Measure tree/expression/lexer against the
same Phase191 products, and reprofile if the timing win is smaller than the
structural change suggests. Reject a port that merely emits unused helpers,
silently falls back after changing dependencies, or pushes recursion onto the
CPU stack. Keep constructor/ownership and predicate changes separately switched
so any broad gain can be attributed to the actual implemented route.
