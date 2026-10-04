# P45-014: emit proved native constructors directly

Status: isolated worker14 passed the record boundary controller and a two-point paired timing screen; it is included in combined candidate worker16 for broader qualification. These are not full-corpus gains. The parent is frozen `source-worker11`, independently of alias admission P45-013. Root owns all builds, execution and timing.

## Hypothesis

Worker11 profiles attribute about 11% of Map and 15% of record-program samples to runtime `ctor`, according to the [worker11 profile analysis](../../implementation/phase45/profile-worker11.md). These samples identify a useful experiment, not an independently measured removable fraction. Typed worker IR already knows the constructor's canonical layout, name and complete fields. Emitting the corresponding native expression can remove the generic tag dispatch and, where it is only temporary, its argument array.

With every other cost held fixed, eliminating an 11–15% self-cost would predict about 1.12–1.18× improvement; some constructor work remains necessary. That conditional estimate is not an upper bound when changing code also changes inlining, allocation or JIT behavior. Profile shares cannot establish causality or guarantee that V8 will retain the same surrounding optimization decisions.

## Narrow transformation

The isolated patch changes only `ir/worker-emit.bend`:

| Proved layout, exact name and field count | Expression |
| --- | --- |
| Bool, `True`/`False`, zero | `true` / `false` |
| Closed native Sigma, `Tuple`, two | Fresh `[left,right]` |
| Native String, `SNil`, zero | `''` |
| Native String, `SCon`, two | `(typeof head==='string'?head:String.fromCodePoint(head))+tail` |
| Native Char, `Chr`, one | `checkedChar(value)` |

Unknown layout/name/arity combinations retain the exact existing `ctor(name,[fields])` fallback. Private tagged construction is unchanged. Nat is unchanged: Number-Nat graphs already have their typed number operations; other Nat constructors retain their previous runtime path. U32/F32 constructor handling is not widened. Both native and explicit-stack worker printers use the same value emitter, so the transformation composes with existing SCC selection and stack fallback.

## Why this preserves the admitted computation

`jw_layout` proves canonical native owners through existing primitive/String/Char/Sigma checks. In particular, source types or constructors merely named `String`, `Chr`, `Tuple`, `True` or `False` do not acquire native admission. `constructorNative` is an internal null-prototype table initialized from those constructor definitions before source definitions; it is not exported or changed by exported `ctor`. The direct expression consumes the already established native layout fact rather than assuming all constructors with a particular spelling are native.

`jw_args` lowers field computations left to right, storing nontrivial results in private registers before the constructor instruction. Inline literal leaves remain possible. A tuple evaluates both fields exactly once and in the same order, including an F32 literal that emits a `bitsFloat` call. Its one fresh array is the same result allocation that the two-field runtime Tuple case returns; it is not a cached/shared tuple.

A Char constructor still calls the exact lexical `checkedChar` helper once. Unicode range/surrogate errors and Error-hook reentry retain that helper's behavior. A String cons head is a typed Char slot or inert literal, and its tail is a String slot or inert literal. Repeating the head read introduces no repeated source computation. `String.fromCodePoint` is looked up only on the numeric-head branch, its receiver remains `String`, and the method lookup precedes the argument read and call just as in runtime `ctor`. The tail's nontrivial computation has already run before that lookup in both forms. No String intrinsic is replaced with a speculative code-point algorithm.

The exact-entry, complete graph, source dependency, scalar input and full host/String guards remain unchanged. The supported host domain is the existing [standard intrinsics at initialization and guarded post-import mutation contract](../../docs/PHASE42_GENERATED_JS.md#runtime-boundaries-and-maintenance). This experiment does not claim equivalence for arbitrary custom host hooks captured before import. Public `G` mutation, ordinary constructor APIs and generic fallback behavior are not rewritten.

## Qualification and decision

Before timing, establish emitted activation for each supported constructor shape and refusal for unknown names/layouts/arities. Differential controls should include Bool branches, nested pairs with distinct values and shared private children, supplementary-plane String cons, empty strings, invalid/surrogate/out-of-range Char inputs and error/reentry replay. Post-import `String.fromCodePoint` replacement/getter and relevant prototype hooks must select the existing generic fallback and preserve its observations. Shadowed native owners remain excluded. Exercise both native and machine worker paths.

Run the existing worker11 semantic suites and deep recursion controls, then a paired Map/records screen against the same frozen parent. Record generated source bytes and compiler cost. Only a measured survivor proceeds to broader corpus qualification. Keep the experiment separate from alias13 so constructor gains and admission gains are distinguishable.

Artifacts: `selfhost/build/phase45/native-constructors-patch01/native-constructors.patch`, its before/after emitter files and `identities.json`. These are an isolated patch, not maintained production changes. No target program was executed while preparing it.


## Isolated worker14 evidence

The root executed `record-controls14/report.json`: **PASS**, four complete values, 57 mutation/error/boundary observations and 61 activation observations. The raw report SHA-256 is `a6fc8baa952c989ae3c45bc23a7d49aaba7a786099e7c2c430d5d1d19803a23b`. This is the actual record-program controller; its success does not alone qualify every constructor shape listed above.

The paired `runtime-worker14-vs11/report.json` completed all 18 samples: two points × three compiler roles × three rotated rounds. Its SHA-256 is `60996270b37dbafecf9f0ccc132275052ea25b33517dbe8fbf6f3bf20afeb0d4`. The six medians below were independently recomputed from each raw sample's execution time divided by its repetition count. All raw samples were complete/pass with successful processes.

| Point | Fresh TypeScript ms | Worker11 ms | Worker14 ms | Worker11 / worker14 | Worker14 / TypeScript |
| --- | ---: | ---: | ---: | ---: | ---: |
| Map128 | 0.785829 | 2.305620 | 1.254793 | 1.837450× | 1.596777× |
| Records256 | 1.250376 | 3.164049 | 2.299743 | 1.375827× | 1.839242× |

This serial screen took 15.09 seconds, using pinned Node24.18.0 on CPU3, 350ms warmup, 40ms calibration, 150ms target samples, a 1GiB heap and 2GiB RSS limit. Timing processes used the existing 4MiB stack setting; separate deep controls, not this screen, establish stack behavior. Import and first-call measurements remain separate in the raw report.

The improvement exceeds the simple constant-other-cost estimate from the earlier profile. That supports measuring a structural change instead of treating sampled `ctor` self-time as its total effect. The screen does not identify how much comes from inlining, temporary vectors, GC, different JIT decisions or sampling differences; fresh profiles would be needed for that attribution. Within-sample drift is material: Map worker11 reports about +19–21%, while Records worker14 reports about +21–35%. The result is sufficient to advance to broader, longer qualification, not to declare a stable universal speedup or parity.

Both reports are under `selfhost/build/phase45/`. The combined worker16 source merges corrected monomorphic admission13b, this constructor change14 and tail-only SCC emission15. An independent static inventory comparison finds exactly two changed source files relative to worker11: `jpure.bend` equals the reviewed13b derivative byte for byte, and `ir/worker-emit.bend` equals the exact composition of the separately reviewed14 and15 changes. Runtime, lowerer, typed IR model, Number-Nat pass and manifest are unchanged. Combined performance and correctness require their own receipts; isolated14 timing must not be relabeled as worker16 evidence.
