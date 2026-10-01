# Private tree operations: measure coverage before extending the compiler

This is the pre-execution design for Phase37's optimization experiment. The
coverage campaign first freezes additional programs and inputs and measures the
installed Phase36 compiler. These files can be prepared concurrently, but root
alone executes all acquisitions, controls and measurements, serially.

## Evidence and hypothesis

Phase36's unchanged tree-bitonic case is 80.62 times slower than pinned TypeScript
at depth 8 and seed 0. Its candidate CPU self samples assign 23.77% to `apply`,
9.58% to `invokeExact`, 7.74% to `callOwned`, 7.45% to `force` and 14.23% to
`warp`. `warp`, `warp_zip` and `warp_leaf.go` are prominent allocation owners.
These samples support an experiment; they do not give an additive speed estimate.

The hypothesis is that a complete, privately owned tree operation can avoid
generic matcher and application descriptors while preserving its current tagged
representation. Begin with `warp_zip`; if that is insufficient, widen to the
complete `warp` component using the same representation and existing source
algorithm. Do not implement a new optimizer representation before testing this.

Current source inspection shows why this workload remains generic:

* `j_fold_type` already recognizes its closed `Tree` sum, but folds require a
  scalar result and strict recursive child reductions.
* `j_region_prefix_on` admits Bool and selected Nat branches, then complete
  single-constructor unpack. It does not admit arbitrary finite-sum matches.
* The producer plan starts from a scalar countdown with two independent recursive
  children. Bitonic also consumes existing trees, matches multiple inputs, and
  recurses through `warp` and `flow`.
* `Bool.xor` is a native runtime wrapper without a scalar snapshot. The current
  `JPure` residual-native whitelist covers only `F32.to_u32`. Expanding match
  recognition alone therefore cannot prove this entire graph.

Lexer is a later, distinct extension. Besides its finite sums, it requires native
String/Char and a `Mode & U32` state. The smaller tree component is a better first
discriminator than extending all these boundaries at once.

The pinned TypeScript emitter is useful here: `js_call` emits direct calls,
`js_func` consumes function parameters and pattern fields, and `js_match` emits
branch chains over original constructors. Tail cycles are handled separately.
That separation supports direct first-order workers, but does not justify
discarding the selfhost compiler's public stages or stricter host boundaries.

## Frozen saved-output ablations

Parent: Phase36 checked03 tree-bitonic module, SHA-256
`6ba1adf3a5ba6aeae722f63dd16adef0a32ff846027d563fcd322c428cdff696`.
Pinned upstream remains `018751270e800bc222a93dad7f257083ee53a5f7`.
The derivation parses every output with the same pinned Acorn version as earlier
experiments and records source, tool and module hashes.

| Variant | Change |
| --- | --- |
| original | Byte-identical Phase36 generated module |
| guard | Original root body inside one complete scalar proof boundary |
| zip | Guard plus direct private `warp_zip` at its existing saturated site |
| finite | Zip plus direct private leaf comparison; recursive warp stays generic |
| warp | Guard plus an iterative private `warp`; leaf comparison stays generic |
| component | The same `warp` plus direct private leaf comparison/construction |
| TypeScript | Unchanged pinned generated module, clean timing only |

The prototype snapshots `Bool.xor` explicitly and guards every source dependency
of the complete `bench` graph. This is a manually reviewed saved-JS condition,
**not an implemented compiler proof**. The actual compiler must eventually
establish an equivalent condition without benchmark names or frozen binder IDs.

The original public function descriptors and staged matcher paths remain. Only
the scalar `bench` root gains a checked exact-entry wrapper. Raw code, partial,
oversaturated, noncanonical input and mutated dependencies take its original
expression. Direct tree operations are selected only while the root's whole
dependency proof is active. Existing `bad` proof suspension and `finally`
restoration remain unchanged. No global proof is cached across calls.

Each clean timing module is generated without counters. Diagnostic modules have
explicit root/zip/warp/leaf entry counters. Generated modules cannot be called a
compiler improvement; only a later checked compiler build could establish that.

## Demand, sharing and error obligations

Purity is insufficient. The concrete existing call sites add stronger facts:

1. The `bsort` parallel right-hand sides call `callOwned`, which completely forces
   each returned constructor before binding it. Left is evaluated before right.
2. The two recursive `warp` right-hand sides also use `callOwned` before the
   `warp_zip` call. Both are completely materialized before that function starts.
3. `warp_node` receives fields of a previously materialized tree. `flow` forces
   each `warp_node` result before passing it to its recursive invocation.
4. The scalar root cannot accept caller-provided trees. All reachable graph
   functions and the remaining native Bool wrapper are unchanged under the
   complete guard; no foreign or callback-producing operation occurs there.
5. Constructors produced by the direct component keep `{$, a}` storage. No input
   node or field array is modified. Zip preserves each original child reference.
   The iterative warp visits left, then right, then combines, and retains a
   frame per active depth rather than relying on the JavaScript recursion limit.

Consequently, direct matching reads already-forced private fields; it does not
eagerly force deferred public fields. New code must not generalize this argument
to arbitrary pure functions or public tree arguments.

Controls compare complete trees, not only checksums. An independent nested-array
model implements warp equations; a separate sorted-array model computes complete
benchmark results without implementing bitonic sorting. Inputs vary depths,
seeds, directions and mismatched shapes. Sharing modes include repeated child
subtrees and identical root inputs, with frozen nodes/field arrays to detect
destructive updates. A zip witness checks surviving identities explicitly.

Public controls retain dependency wrappers/getters/replacement, raw and forged
entries, saved partial stages, oversaturation, argument getters/reentry/errors,
prototype markers and host arithmetic hooks. A replaced tree producer returns
deferred fields with ordered events and independent left/right errors; private
entry must be refused. Direct public warp/zip calls exercise delayed fields and
throwing/getter behavior through the unchanged generic route.

## Admission and implementation decision

Run controls before timing. The actual benchmark must increment the expected
private entry counter; mutations must both prevent entry and visibly execute
their generic hook. Preserve any failed attempt and revise in a new directory.

Use the unchanged depth-8 case for the first three-round screen. Compare each
variant against both original and guard-only controls. A useful initial result
is a gain exceeding 5% with disjoint observed ranges; an overlapping small result
does not justify another compiler mechanism. The complete expanded Phase37
catalog is the eventual transfer/regression gate, not this one case.

If zip alone wins materially, seek a shared finite-sum prefix plan that extends
existing positional slots and constructor admission. If only the recursive
component wins, first specify a reusable tree-to-tree worker proof, including
ordered child demand and nested pattern matching. Do not scatter benchmark
special cases through `region.bend`. If implementing that proof would add a
large mechanism without demonstrated coverage, report and defer it rather than
force a production patch merely to finish the phase.

Any surviving compiler proposal requires independent review, a checked B1,
focused refusal/alias/error tests, fresh expanded-catalog execution, normal
compilation-cost measurement and integration gates. Record Bend source lines,
definitions/types, runtime lines and emitted-program size separately from speed.

## Selected actual-source candidate after the mechanism screen

The five-round, three-size confirmation finds only 1.03–1.10× for zip alone,
but 1.32–1.33× consistently for zip plus leaf selection. The complete recursive
component gives 2.60–3.56×. Test a bounded inline finite prefix first; the larger
recursive worker remains a separate architecture decision.

The candidate has one 163-line Bend module with 19 small helpers. It reuses the
original typed Lam/Mat representation, `JPure`, materialized constructor layout,
existing scalar dependency/host guard and existing generic expression. It adds
no optimizer IR or new runtime worker table. Native `Bool.xor` keeps generic
dispatch but gains an exact typed purity predicate and captured descriptor.

Admission requires a known saturated nonnative callee, at most eight arguments,
at most 256 executable source nodes and prefix depth below 32. The prefix permits
original parameter bindings, complete matches on private nonnative sums or Bool,
and total variable/literal/primitive/inert-constructor leaves. Helper calls,
recursive selector bodies, lets and native constructors other than Bool refuse
this route. The mandatory independent typed prefix proof validates branch
completeness and erased/variable/type obligations.

At an eligible call, an IIFE captures actual arguments in original left-to-right
order, then follows the original prefix using fresh source binder identities.
It is selected only when an active whole-graph scalar proof covers the callee.
The complete scalar graph guarantees already-forced compiler-owned fields, so
inspecting earlier matched fields before/after evaluating later arguments crosses
only total tag/field reads. Purity without this ownership fact is insufficient.
Outside that scope the exact original generic expression remains.

A residual scalar root may open the scope if its complete pure graph contains
a useful selector. It fully forces the original generic result before closing
the proof. It opens only when no proof is active: nested root→matcher→root tail
cycles must return jumps to the outer force loop, avoiding nested JS stacks.

Readiness uses nested `kc` gates because Bend Boolean operators evaluate their
arguments eagerly. The match scan strips annotations after the executable-node
budget check. This avoids expensive readiness on nonsaturated or unsupported
calls, but repeated per-call analysis and duplicated inline text remain cost
risks. Normal checked compilation costs and emitted sizes are promotion gates;
the patch is not accepted merely because its runtime benchmark wins.

The actual-source fixture tests three-constructor sums, first/last Bool matches,
two input trees with a type alias, nested constructors and surviving child aliases,
declined helper/native/higher-order/array shapes, 30,000-step self/mutual tail
cycles, and actual argument overflow with Error mutation/reentry. Diagnostics
count actual emitted selector branches, not a substituted handwritten worker.
See the versioned outcomes in
[`implementation/phase37/optimizer/attempts.md`](../../implementation/phase37/optimizer/attempts.md).

The accompanying independent native-cast experiment also identified a missing
host-guard dependency: mutable DataView methods and a previously captured shared
float-view instance. Both candidates require that guard correction before
promotion. Its cost must be measured on active floating workloads, where a
complete outer proof may not be available to amortize descriptor checks.

### Profitability successor before checked03

The actual active-ray ablation establishes 1,968 successful tiny helper scopes
per call (984 each in `fmax0` and `shade`). They add exactly 1,968 full host checks:
4,941 in the candidate versus 2,973 when new roots are disabled. The timed export
uses an older scalar root without a proof scope, so the unused new `bench` root
cannot amortize these costs. The issue is excessive small scope entries, not
failure to enter the new roots.

Narrow only the **usefulness predicate for creating a new finite root**. At least
one admitted finite callee in its proved graph must have an argument or result
outside the existing scalar signature predicate. Scalar-only min/max and Bool
selectors can still inline inside an already active proof, but cannot alone
justify a new complete host/dependency check. This reuses `j_region_signature`
and requires no new analysis, worker, runtime state or proof assumption.

The tree zip/leaf/stat selector signatures touch private sums and should retain
their scopes. Ray's three finite selector names are scalar-only and should no
longer create the eight new finite roots. Verify those static shapes, actual
tree/fixture private entries, active-ray execution, normal compiler costs and
the expanded catalog in a fresh checked03 acquisition. Keep checked02 and the
failed/regressing evidence unchanged. The DataView correction remains required;
its independent cost is not a reason to remove it from production.

## Root commands

All paths below are relative to the repository. Use new output directories.
The derivation and controls need the outer supervisor; the comparison already
owns the shared lock and must not be nested inside that supervisor.

```sh
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 60 --rss-mib 1024 --available-mib 2048 selfhost/build/phase37/tree-derive-outer01 -- taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node --max-old-space-size=512 selfhost/tools/performance/phase37/optimizer/tree-derive.mjs selfhost/build/phase36/full03/modules/tree-bitonic.mjs selfhost/build/phase36/baseline02/portable/typescript/modules/tree-bitonic.mjs selfhost/build/phase37/tree-derived01
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 180 --rss-mib 2048 --available-mib 2048 selfhost/build/phase37/tree-controls-outer01 -- taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node --max-old-space-size=1024 selfhost/tools/performance/phase37/optimizer/tree-controls.mjs selfhost/build/phase37/tree-derived01 selfhost/build/phase37/tree-controls01
python3 selfhost/tools/performance/phase35/compare.py selfhost/build/phase37/tree-derived01/compare.json selfhost/build/phase37/tree-screen01 --node /home/ai/.nvm/versions/node/v24.18.0/bin/node --cpu 3 --budget 60
```

The experiment owner prepared these tools without executing compiler builds,
generated programs, controls, timings or profiles. Outcomes belong in the linked
Phase37 implementation report after root's serialized acquisitions.
