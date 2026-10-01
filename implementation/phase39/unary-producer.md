# Phase39 unary producer findings

Status: accepted in installed and verified checked05. Final expression 32/128
execution improves 4.461×/8.052× against Phase37; actual structural/error controls
and selected-image owner closure pass. Root executed all reported runs; the owner
authored source/tools and inspected evidence without target execution.

## Warmed causal experiment

`component-expression-confirm01` completed 40 samples in 65.37 seconds: two
points × four roles × five fresh rounds. It retained the exact installed
Phase37 checked03 tags, arithmetic, generic public implementation and iterative
`eval`, changing only the private expression producer in the existing root.

| Expression depth | Installed, ms | Producer-only, ms | Producer + chooser, ms | Installed / full | Full / TS |
|---|---:|---:|---:|---:|---:|
| 32 | 0.108745 | 0.077771 | 0.020140 | 5.40× | 9.33× |
| 128 | 0.366369 | 0.263965 | 0.041498 | 8.83× | 4.55× |

Producer-only improves 1.398×/1.388×. Most of the available gain therefore requires
direct reconstruction through the chooser as well as replacing recursive
dispatch. Full-component within-sample half drift is at most 2.7%; one original
sample reaches 10.5%. These are saved-output experiments, not source-compiler
acceptance or published compiler results transferred to Bend.

## Source attempts and precise refusal

The first unary proposal reuses `JProducer` with a new unary flag and child index,
the existing typed prefix/argument planner, private helper table and explicit
frames. It adds 142 physical lines and 16 definitions to `producer.bend`.
The reviewed v2 also bounds the rediscovered child index before recording it;
the original v1 patch remains preserved. This adds a new planner/emitter case,
despite introducing no new IR tag or public runtime facility.

Root's `checked04` compiler includes the patch and checked successfully. Its
expression output has **zero** unary-worker markers. `unary-plan-probe01` completed
in 5.629 seconds and reports an eligible Nat producer signature, exactly one self
reference, a three-argument combiner and recursive child at index one. Planning
then fails in `p37.expr.pick`, leaving it residual. No optimization was accepted
or timed as a successful actual unary worker at this point.

Source inspection identifies the precise blocker: `j_region_constructor` uses
`j_fold_terminal_fields`, which accepts terminal variables/literals/primitive
expressions but rejects nested constructor children. The expression chooser uses
`Add{e, Mul{Lit{seed}, Lit{3}}}`. Its existing private Nat prefix is already capable
of consuming the later Expr and U32 arguments; broadening Nat matching is not
needed.

The independently reviewed successor adds 25 lines and three definitions plus
one delegation in `j_region_constructor`. Only the existing whole-graph-proved
`@producer` context may recursively admit constructor syntax. Leaves retain the
old terminal grammar; nonprimitive helper calls, closures and arbitrary effects
inside constructor fields remain refused. Each node still passes normal typed
constructor/argument planning. The small grammar bounds depth/sibling paths;
overall source bounds and shared region fuel separately bound aggregate work.
No public/root constructor domain is widened.

The frozen source SHA after this extension is `daf2d2ae…` for `producer.bend`
and `dcbb0313…` for `region.bend`. Full hashes and preimages are in
`selfhost/tools/performance/phase39/proposals/nested-producer-fields-v1.json`. Root was notified before the
next checked snapshot; subsequent changes require a new attempt.

## Independent actual-source controls

Fixture v1 used a five-field constructor containing Nat metadata, outside the
existing fold/producer domain. It was rejected by source inspection as an
admission witness; this is not evidence that the compiler mishandled the program.
V2 expresses the independent Trail with `Start(U32)`, `Step(Trail,Trail)` and
`Stamp(U32,Trail)`. Two Stamp wrappers share the same recursive child. This keeps
all constructors within the existing two-field U32/recursive domain.

The fixture covers child-first, child-middle and child-last calls, a private
finite Nat chooser, zero and nonzero inputs, and wrapping U32 values. Separate
pure `unary.bump` calls can fail before the child, in its zero branch or after
it. The zero branch uses a typed let before constructing `Start{value}`, so
testing errors does not require accepting helper calls inside constructor fields.
Two nested recursive children are a deliberate refusal.

`unary-acquire-v2.py` retains three checked emissions and explicitly uses the
Phase37 catalog. `unary-compiled-controls-v2.mjs` binds those receipts and adds
only counters, expression-phase marks and returned-tree capture to actual
emitted workers. Its original intended counts were 62 value oracles, 56 complete structural
observations, three admission rows,31 boundary rows and three exact error-order
rows. V2 was superseded by the final v4 fixture/control pair below; these earlier
planned counts are not separate additional passes. Candidate-only
30,000-deep chains are inspected iteratively, including every distinct node and
shared child identity. No deep baseline recursion is required to establish the
new worker's explicit-stack behavior.

## Actual checked05 admission and initial screen

`checked05` passes in 42.29 seconds with peak RSS about 1.195 GB. Its actual
expression module is 83,702 bytes and contains one private unary producer. The
emitted descent stores `BigInt(seed % 3)` before its child, preserves the BigInt
predecessor, and resumes through the direct private `p37.expr.pick`. That chooser
uses its existing Nat-prefix cases and nested tagged constructors. The iterative
consumer is unchanged. This establishes actual source admission, beyond the
saved-output prototype.

`checked05-expression-screen01` completes 18 samples (two points × three roles ×
three rounds) in 7.069 seconds. Baseline and candidate ranges are disjoint:

| Depth | Installed median [range], ms | Checked05 median [range], ms | Installed / candidate | Candidate / TS |
|---|---:|---:|---:|---:|
| 32 | 0.160491 [0.156966–0.185253] | 0.023272 [0.023123–0.026709] | 6.896× | 8.842× |
| 128 | 0.556014 [0.538847–0.629595] | 0.064866 [0.063651–0.075414] | 8.572× | 6.627× |

These are short-screen numbers, not warmed acceptance. Candidate half drift
reaches −27.4% at depth 32 and +59.8% at depth 128; baseline drift reaches −40.9%.
The final five-round comparison and broad regression/compiler-cost gates below
supersede this initial screen.

## Versioned fixture corrections

V3 retained V2 and added two refusals: a nested constructor field containing a
helper call, including its Nat-overflow witness, and recursion using constant
zero rather than the immediate predecessor. `unary-cohort02` rejected the latter
in the source termination checker before any candidate execution. Although it
terminates after at most one recursive call, the structural checker does not
establish that fact from this source shape. This is a fixture admission mistake,
not an optimizer correctness failure. V3 and its receipt are preserved.

V4 adds `@unsafe` only to that deliberate nonpredecessor refusal, following the
pinned `tests/run/unsafe_tail_cycle.bend` source convention. It leaves all worker
proofs and V3 control assertions unchanged. The frozen files are
`unary-fixture-v4.bend` (`29f8b130…`), `unary-acquire-v4.py` (`9d746901…`) and
`unary-compiled-controls-v4.mjs` (`f46b46b3…`). `unary-cohort03` checks identical
fixture bytes with the installed baseline, checked05 and pinned TypeScript.

`unary-actual-controls01` **passes** in 1.006 seconds, about 159 MB peak RSS:
83 value oracles, 56 complete structural observations, three admission rows,
32 boundary rows and three error-order rows. Each first/middle/last worker has
18 actual entries and each private chooser 132 entries in the admission sample;
these are live observations, not marker-only checks. The two 30,000-depth chains
each validate 90,001 distinct tagged nodes and 30,000 preserved shared-child
identities. The observed overflow sequences are exactly `entry,pre0`;
`entry,pre0,pre0,zero`; and `entry,pre0,pre0,zero,post2`. All three refusal
functions remain generic. ABI/dependency mutation and Error reentry observations
match the baseline and leave no active proof.

The controls bind checked emission receipts to source, module and compiler
identities. The final API is
`04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`;
the actual fixture candidate module is
`e187aa1cf653c59a9e9687c505d97d13725380e371169ed240c8b8204187dc00`.
The final owner closure separately binds the checked snapshot and these exact
versioned tools; the diagnostic module is excluded from timing.

## Final execution, profiles and acceptance

The final `final-exposed01` comparison completes all six points of the former
holdout partition, with five paired rounds per role. Expression informed this
phase's optimization, so it is now explicitly exposed rather than unseen transfer
evidence. [Aggregate results](execution/report.md) retain all 45 primary points
and separate canary confirmations. Final expression medians [ranges], in
milliseconds per export, are:

| Depth | Phase37 | Final checked05 | Phase37 / checked05 | Checked05 / TS |
|---|---:|---:|---:|---:|
| 32 | 0.105447 [0.104402–0.117690] | 0.023637 [0.021333–0.024011] | 4.461× | 10.465× |
| 128 | 0.391518 [0.385809–0.430375] | 0.048626 [0.047765–0.053152] | 8.052× | 5.239× |

Both observed ranges are disjoint and all ten candidate/Phase37 pairs improve.
Candidate half drift stays within 2.03% at depth 32 and reaches +9.65% in one
depth-128 sample; TypeScript at depth 128 reaches −10.34%. The result is a substantial actual emitted
speedup with retained measurement limits, not proof of full JIT stabilization.
It differs from the handwritten prototype and short-screen ratios above; only
these same-run final ratios describe the selected source implementation.

The final [profiles](profile-findings.md) show depth 128 sampled allocation
600,248→102,413 bytes/call (−82.94%). Generic dispatch no longer dominates: CPU
moves to the producer 22.39%, private chooser 17.19%, evaluator 9.93% and outer host
guard 18.02%. Remaining tagged construction and explicit frames are visible in
allocation. Their percentages are instrumented shares, not predicted speedups.
The expression module grows 1,037 bytes; source-owned array/object literal sites
increase 45/3→59/4 even as dynamic allocation falls. Retained fallback plus private
workers make static site counts a poor substitute for actual execution evidence.

The [four-owner identity closure](new-owner-gates.md) passes as
`new-owner-close03/report.json` using the versioned v4 closer/spec. It binds the
83 value oracles, 56 structures, 3 live admissions, 32 boundaries and 3 exact error
phases to the final API, checked receipts, diagnostic parents and bounded run.
The two 30,000-depth alias witnesses and all three refusal shapes remain required.
Earlier failed fixture/audit-schema attempts stay preserved.

[Normal compiler cost](compiler-cost.md) passes 27 fresh checked emissions with
all frozen output hashes matching. Local/numeric request changes are −1.60%/−1.68%
with overlapping ranges; tree request increases 3.50% with disjoint observed
ranges. This cost gate covers three separate source workloads and does not
isolate the unary planner or time expression compilation. The implemented unary
case and nested-constructor grammar add 167 physical lines and 19 definitions in
`producer.bend`, plus one existing-region delegation; there is no new IR tag,
but the new flag/planner/emitter case is a real complexity increase.

Checked05 is installed and release verification passes. Its unchanged CLI smoke
retry passes 42/42; the first environment-only `clang EPERM` failure is preserved.
The [integration report](integration.md) and [campaign report](README.md) bind the
remaining release ledger and final audit. This optimization retains generic
public entry, tagged values, subtree identity, bounded JS recursion and original
argument/error order within its proven domain; it is not a claim of whole-language
conformance or typical-program speed.
