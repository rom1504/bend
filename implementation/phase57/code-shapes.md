# Compiler-image code shapes

The clearest static difference is **literal-choice transport**. Raw checked
JavaScript and direct B2 each contain 3,315 calls to the compiler's three choice
helpers and 6,630 closure-wrapper sites. The installed B1 derivative removes
those sites through its separately reviewed transformations. This is a concrete
optimization hypothesis, not a measured explanation of B2's slower execution.
The allocation profile now exposes wrapper-related costs; CPU correlation and a
controlled ablation are still needed.

The 2.13× file-size difference is a separate observation. Metadata comments and
extra public export text account for 80.7% of the B2−B1 byte gap. Neither extra
comments nor a count of cold wrappers establishes a hot execution cost.

## Exact comparison

All three images originate from the same frozen Phase56 `string01` Bend assembly,
SHA256 `5356ec9963db7b300e8cbdf5474328b72150f582df96b01aeea29d6a07868244`.
The raw image is the pinned upstream TypeScript compiler's output **for the Bend
compiler source**; it is not the TypeScript implementation itself.

| Image | Bytes | Generated named functions | Default exports | SHA256 |
| --- | ---: | ---: | ---: | --- |
| Raw checked API | 1,807,265 | 3,060 | 77 | `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52` |
| Installed derived B1 | 1,830,723 | 3,060 | 77 | `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea` |
| Qualified direct B2 | 3,896,951 | 3,054 | 2,999 | `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e` |

The B1 derivation records one String equality replacement, **3,315 literal-choice
rewrites**, and **329 return-choice rewrites**, including 301 deferred generated
calls. B2 emits native String equality from Bend source. Its six absent functions
are `String.order`, `String.cmp`, `String.cmp.fin`, `String.cmp.rec`, `Char.cmp` and
`Pair.snd`; all other 3,054 generated names map across the three images. Removing
that source dependency chain is already implemented, not a future opportunity.

Evidence is the [compact inventory](../../selfhost/tools/performance/phase57/static/summary.json),
[complete compressed inventory](../../selfhost/tools/performance/phase57/static/code-shapes.json.gz)
and [exact representative bodies](../../selfhost/tools/performance/phase57/static/representative-bodies.md).
The [analyzer](../../selfhost/tools/performance/phase57/static/code-shapes.mjs)
parses saved bytes with Node's bundled Acorn; it never imports or evaluates a
compiler image. It binds the attempt, bootstrap, assembly, derivation and emission
roles, verifies reversible generated-name mappings, and rehashes its inputs.
An independent static review passed before the successful CPU0 inventory run.
The initial launcher found no `node` on PATH; the successful invocation used the
recorded absolute Node executable. No compiler job or benchmark ran here.

## Size, exports and duplicated components

| Syntax extent | Raw checked | Derived B1 | Direct B2 |
| --- | ---: | ---: | ---: |
| Named generated function text, bytes | 1,787,866 | 1,811,324 | 3,477,271 |
| Default export object, bytes | 9,732 | 9,732 | 403,229 |
| `JD_USE` / `JD_REF` comments, bytes | 0 | 0 | 1,274,113 |
| Exact copied PC-loop groups | 23 | 23 | 23 |
| Functions in those groups | 56 | 56 | 56 |

There are 62,803 metadata comments in B2. Subtracting just those comments and the
extra export text explains 1,667,610 of its 2,066,228 extra bytes. After removing
each module's export object and B2's metadata comments, the remaining text is
2,219,609 bytes versus B1's 1,820,991 bytes, about 21.9% more. This accounting is
not minification and does not estimate executable machine-code size.

The B2 export set contains all 77 required API names plus 2,922 additional
helpers. [`jd_exports` / `jd_host_exports`](../../selfhost/src/back/js/direct/host.bend:220)
walk the entire selected definition list, while the seed library exposes the
explicit bootstrap API list. Internal calls use lexical generated functions;
they do not route through these public wrappers. A narrower export policy could
reduce emitted text, host-wrapper analysis and module initialization, but it
would change the image interface and needs explicit inventory/consumer gates.
No such policy change is made here.

Both emitters already lower the **same 23 mutual tail components** as copied PC
loops: grouping identical loop suffixes yields the same member-name sets. B2 is
not missing SCC lowering. [`jd_definition_loop`](../../selfhost/src/back/js/direct/core.bend:275)
intentionally follows the pinned upstream policy of giving each public entry
its own copy. Sharing components is a possible size experiment, with call-entry,
stack and JIT tradeoffs; the static duplication alone does not justify it.

## Calls, closures and forcing

These counts cover generated function bodies, excluding public export wrappers
and runtime definitions. They count syntax sites, including duplicated SCC bodies;
they are not call frequencies or allocation totals.

| Body syntax sites | Raw checked | Derived B1 | Direct B2 |
| --- | ---: | ---: | ---: |
| `kc` calls | 2,385 | 0 | 2,385 |
| `f_choose` calls | 689 | 0 | 689 |
| `nt_choose` calls | 241 | 0 | 241 |
| `run_clo` / `jd_clo` calls | 6,630 | 0 | 6,630 |
| Arrow expressions | 6,630 | 5,972 | 6,630 |
| `run_loop` / `jd_run` calls | 6,269 | 6,269 | 6,269 |
| `run_tail` calls | 6 | 2,992 | 6 |
| Loop statements | 140 | 140 | 3,053 |

B2's `jd_clo` and `jd_run` are aliases for the same direct-runtime closure and
trampoline operations. [`run_clo`](../../selfhost/src/runtime/js/direct.mjs:142)
creates a wrapper function and links its `.j` to the supplied arrow; `run_tail`
creates a jump record with an argument array. The source
[`kc`](../../selfhost/src/core/term.bend:4) chooses between two Unit callbacks.
B2 eagerly constructs both callback values, then invokes that choice helper.
B1's first transform evaluates the condition and constructs only the selected
raw arrow before retaining the tail boundary. Its second, narrower transform
turns suitable returned choices into direct branches, retaining a jump record
where a terminal generated call must remain deferred.

Thus **zero `run_clo` sites does not mean zero closures or zero trampolines** in
B1. It still has 5,972 arrow sites and the same 6,269 non-tail forcing sites.
Likewise B2's numerous `for(;;)` scaffolds are often single-iteration functions
that return immediately; counting them does not imply repeated work.

## Matched functions

Exact bodies and hashes are retained in the linked representative file. The
following observations hold in those saved images, without execution.

- **String equality:** B1's function has a `typeof`-guarded primitive shortcut
  with the old comparison fallback. B2 directly returns strict equality under
  its documented primitive String domain. The six comparison helpers retained
  in B1 are absent from B2; current B2 does not inherit the old String.cmp hotspot.
- **Indexing:** `index_hash` uses the same string head/tail traversal and
  `Math.imul`-based hash update. `index_find` has the same three-entry PC component
  in both images. `index_remove` and `index_lookup` retain named-field access and
  direct calls. There is no switch from a persistent trie to linear lookup here.
- **KTerm access:** `tg` and `ks` dispatch on the same constructor tags and read
  named fields. `kid` calls `terms_at` in both images. B2's `terms_at` has two
  `jd_clo` sites and one `kc`; B1 instead has a direct zero-index branch and a
  deferred recursive jump record. This is a small, repeated traversal to
  correlate with profiles first.
- **Substitution:** `subst` has four B2 closure wrappers for nested choices.
  B1 retains one selected raw-arrow tail boundary and uses direct inner branches.
  `subst_node` still rebuilds the same named KTerm/KLambda/KLiteral fields;
  `subst_terms` still forces each recursive head substitution in both images.
  There is no evidence here of a different tree representation or automatic
  sharing/rebuild elimination.
- **Evaluation:** `wnf` calls `norm_eval` with the same empty argument list and
  `Absent` fallback. `norm_eval` has two B2 closure wrappers versus B1's selected
  arrow. The ordinary tag-dispatch helpers remain named calls in both images.
- **Checking:** `check_node` has ten nested choices and twenty B2 closure-wrapper
  sites. B1 has no closure-wrapper calls there, but still twenty arrow sites and
  ten `run_tail` sites. Its nine nested force calls are also retained. Eliminating
  all checker dispatch or forcing would therefore be a different, larger claim.
- **Emission:** `jd_host_exports` has four B2 choice wrappers versus B1's selected
  branches. `jd_definitions` remains a recursive traversal with a forced emission
  result. These are candidates for phase-specific profile correlation, not proof
  that export code or recursion dominates the measured generation stage.

## Cheapest discriminating experiment, not executed

If CPU/allocation profiles put choice transport on a hot path, derive one saved
B2 diagnostic using the existing B1 transformation's narrow structural contract:
match exact canonical choice-function bodies and saturated calls with two literal
`jd_clo` arrows; evaluate the condition once; preserve Unit bindings, branch
laziness, callback captures, exceptions and the original forcing/tail boundary.
Start with selected-arrow transport, and treat the narrower returned-branch
transform as a separate ablation. Do not globally inline arbitrary callbacks.

First compare independent semantic outputs and deep-stack behavior. Then measure
unchanged compiler requests or one bounded hot traversal under the same harness.
A negative result rejects the code-shape hypothesis without a production rewrite.
A positive result would motivate a general typed choice/continuation lowering in
Bend, with equivalent call-graph facts; a private-image rewrite alone would not
constitute a maintained compiler optimization.

The allocation correlation below uses the independent profiling workstream's
completed evidence. No ablation or speed claim has been executed by this static
workstream. Export narrowing, metadata removal and shared SCC bodies remain
separate hypotheses so that code size cannot be mistaken for runtime cause.

## Existing B1 stages can be measured separately

Before inventing a B2 rewrite, the retained derivation supplies exact intermediate
hashes. A cheaper grouped experiment can compare the unchanged raw image,
equality-only image, equality-plus-choice image and final B1 image. This isolates
the existing transforms on the same upstream-generated code, without claiming a
benefit necessarily transfers unchanged to B2.

| Existing stage | Recorded SHA256 |
| --- | --- |
| Equality only / input to choices | `0d4a58b3b2e4133d4a1747609173ce78b23f279773b6daa7eb67692bbb57943f` |
| Choices complete / input to tail choices | `769818565235c7a39cb88778a71265c40b00785faf3e8e058f87ac2d870435e6` |
| Final installed B1 | `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea` |

The prepared [intermediate producer](../../selfhost/tools/performance/phase57/static/derive-intermediates.mjs)
uses the exact frozen maintained transformer, exposing its two private stage
helpers only in a fresh Phase57 copy. It reconstructs the equality-only image
from the two exact String.eq bodies and requires the already recorded hash;
then it requires exact stage reports, intermediate hashes and final B1 bytes.
Historical transform versions three/four are not substitutes: their protected
Base equality bodies differ from this pin. No checked bootstrap sidecar is
fabricated, and the producer never imports a generated compiler image.

Root executed the producer successfully. Its complete/pass receipt is
`selfhost/build/phase57/transform-stages01/report.json`, SHA256
`1f856fd87762f47ecf24a481ac35fff231870e4bc4a971143a4de4019311da02`.
All four exact outputs were verified: `raw.mjs` (1,807,265 bytes),
`equality.mjs` (1,807,347), `choices.mjs` (1,824,731), and `source.mjs`
(1,830,723). These are diagnostic images, with `newBootstrap: false`;
no intermediate becomes a fabricated checked attempt. The producer can be
replayed into a fresh directory with
`node selfhost/tools/performance/phase57/static/derive-intermediates.mjs . selfhost/build/phase57/b1-intermediates01`,
using the recorded absolute Node path and CPU0 outside clean timing. Subsequent
compiler requests remain separate, root-owned executions with unchanged sources,
outputs and request boundaries. Any comparison needs the same ordered workload,
warmup and rotated rounds; the stages are not isolated by comparing old timings.


## Allocation correlation: lexer request

The independent data-only profile comparison passes at
`selfhost/build/phase57/allocation-analysis01/report.json`; its raw inputs are
bound to the same image hashes as this inventory. See the
[profile report](profiles.md) for complete accounting and scope. This section
uses its existing summary rather than running another profiler or analyzer.

B2's sampled allocation estimate is **2,177.8 MB per request**, versus
**927.4 MB** for derived B1 (`source`). These are decimal MB of sampled allocated
bytes, including collected objects, across three and five profiled requests
respectively. They are neither peak/live memory nor exact allocation totals,
and they do not measure uninstrumented latency. Sample/tree accounting
differences and absent-node samples remain explicit in the profile report.

| Retained frame | B1 sampled MB/request | B2 sampled MB/request | B2 self share |
| --- | ---: | ---: | ---: |
| `run_clo` | Not in top-20 summary; no generated call sites | 80.1 | 3.68% |
| `run_tail` | 21.4 | 43.1 | 1.98% |
| named `kc` | Not in top-20 summary; no generated call sites | 34.7 | 1.60% |
| named `terms_at` | Not in top-20 summary | 44.6 | 2.05% |
| one anonymous frame within `terms_at` | Not in top-20 summary | 53.6 | 2.46% |
| named `sk_char` | 206.3 | 218.9 | 10.05% |
| named `subst_terms` | 33.9 | 98.9 | 4.54% |
| named `subst_node` | 24.5 | 80.0 | 3.67% |

These are individual self frames, not summed inclusive stacks or complete
per-definition totals. An anonymous frame is mapped to its containing saved
Bend definition without relabeling the actual frame. Compiler inlining and
allocation attribution can also put callee work on a caller: for example, the
reported B2 `kid` frame has 87.2 MB/request even though its source body merely
calls `terms_at`. This does not establish a new allocation directly in `kid`.

The correlation strengthens the **known literal continuation** hypothesis:
B2's saved `terms_at`/`subst`/`check_node` bodies contain the exact closure
transport eliminated from B1, and the profile exposes allocation in that runtime
and those traversals. It does not show that removing 3.68% from one sampled
frame would produce an equal latency gain, or attribute the entire 1,250 MB
estimate difference to `run_clo`.

A concrete next compiler change, if the grouped ablation supports it, is typed
specialization of a proven choice helper supplied with literal continuations.
Lower the selected branch directly while preserving its Unit binding, pending
argument order and original forcing boundary; update tail-call graph facts so
newly exposed recursion remains stack-safe. Start with the existing maintained
transformation's narrow proof, then generalize structurally. Do not substitute
an eager Boolean operator, inline unknown callbacks, or introduce a benchmark
name selector. The current intermediate experiment can isolate equality,
choice wrappers and returned-choice changes before that source implementation.

The `sk_char` percentages demonstrate why allocation shares alone are misleading:
it is 22.24% in B1 but 10.05% in B2, while its named-frame MB/request estimates
are relatively close. Its underlying parser allocation remains a possible
subsequent algorithmic target, but the present cross-image evidence favors
investigating transport overhead first. Export narrowing and comment removal
remain generation/import hypotheses, not established request-allocation fixes.

## CPU correlation: `run_loop` and `kt`

The next independent summary, `selfhost/build/phase57/cpu-analysis02/report.json`,
admits time-weighted samples for all four lexer roles without correcting negative
timestamps. These are profiled request samples, not the clean latency series.
The [exact hot bodies](../../selfhost/tools/performance/phase57/static/cpu-hot-bodies.md)
retain their parent hashes and source positions.

`run_loop`, `run_tail` and `run_clo` have **identical function-body bytes** in raw,
B1 and B2. In particular, `run_loop` has SHA256
`b1f937dcb68edc1033b01d5a6055938ec2e34103bacd41b68c36f2ea66bd1c8f`:

```javascript
function run_loop(r) {
  while (r !== null && typeof r === "object" && r.$ === "$JMP") {
    r = r.f(...r.x);
  }
  return r;
}
```

The same central indirect invocation can receive many named and closure targets;
this is not a newly introduced B2 runtime protocol. Its observed target diversity,
JIT specialization and jump counts are not established by the body or this CPU
summary. The 6,269 force sites are also identical in count. Choice specialization
can nevertheless change how often those sites receive an immediate value versus
a jump, and how much closure work each jump performs.

B1's `run_loop` self share is 20.19%; B2's is 15.15%. Dividing the corresponding
sample weights by profiled request counts gives approximately **195.2 ms/request
for B1 versus 266.1 ms/request for B2**. These remain diagnostic weighted samples;
the smaller B2 percentage is not evidence of less trampoline work. Similarly,
GC shares of 6.06% and 4.29% correspond to about 58.6 and 75.4 sampled ms/request.
Neither these percentages nor the much larger inclusive `run_loop` share may be
read as time that a runtime rewrite would save.

B2's `kt` frame accounts for 9.28% of weighted self samples, approximately
163.0 sampled ms/request; B1's corresponding function is not in the top-20
summary. Both bodies construct exactly the same property sequence:
`$`, `tag`, `name`, `id`, `quant`, `kids`, `removed`, `originBegin`, `originEnd`.
Both allocate a fresh `Nil` for `removed`; neither boxes the entire KTerm in a
closure, array or legacy descriptor. There is no representation change here.
The concrete emitted differences are:

- B1 uses ordinary literal property names and its five parameters directly.
- B2 uses computed constant string keys such as `["tag"]`, five local aliases,
  metadata comments and an unconditional loop whose first iteration returns.

There are 312 raw/B2 syntactic `kt` calls. B1 has 303 direct calls plus nine
literal `kt` jump targets created by its return-choice transform. This is no
proof of different dynamic construction counts. Likewise the hot B2 frame could
reflect inlining or attribution differences; this profile does not identify a
computed-key or object-shape mechanism by itself.

Two small discriminators follow, separately from any algorithm rewrite:

1. In untimed diagnostic copies, count trampoline entries and loop iterations,
   preserving the original invocation expression. Entries that never enter the
   loop distinguish conservative forcing from actual deferred work. Compare
   the exact existing transform stages before changing forcing analysis.
2. In a saved-output syntax ablation, change only computed **constant string**
   object keys to ordinary quoted keys, preserving property/value order and all
   expressions. Explicitly exclude `__proto__`, whose noncomputed literal form
   has different semantics. Keep aliases and loop scaffolds in this first
   variant; a separate narrow constructor-body variant can test those later.

The second experiment tests a general constructor emission choice at
[`jd_ctor_fields`](../../selfhost/src/back/js/direct/constructors.bend:144), not
special recognition of the lexer or a change to KTerm's layout. Both experiments
remain proposals: no such derived variant, counter instrumentation or production
edit has been executed here. Whole-compiler stage profiles are still needed
before treating the lexer observations as the generation bottleneck.
