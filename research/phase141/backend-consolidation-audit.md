# Bounded backend consolidation audit

This is a source audit, not an implemented simplification or performance result.
No compiler, target, verifier, runtime or installed selection was changed, and no
target was executed. The inspected qualified source is
`selfhost/build/phase137/integrated-source03/compiler.bend`, SHA256
`2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38`.
The incremental comparison is Phase140 source18 and its selected component
modules, especially `render/registry-v05.bend`.

## Recommendation

The most credible small subsystem is **recognition of local recursive regions**.
Three families, `p114r_*`, `p114g_*` and `p114h_*`, independently recognize the
same low-level statements and produce the same `P114RStmt` representation. They
retain different admission rules and different emitters for useful reasons.

Consolidate recognition and its explicit admission policy; preserve the existing
chosen plan, rendering, runtime contracts and fallback order. A roughly 2× source
reduction is a plausible **hypothesis for the 283-line slice below**. I found no
credible evidence that this change would reduce the entire 1,152-line region
subsystem by 2–3×, much less the complete compiler. Do not turn the smaller
opportunity into that larger claim.

| Current slice | Declarations | Physical lines | Nonblank lines |
|---|---:|---:|---:|
| R/G/H block scanners and their branch/prepend helpers | 17 | 163 | 126 |
| Three prelude/segment-admission pairs | 6 | 46 | 35 |
| R/H namespace-hygiene traversals | 10 | 74 | 54 |
| Proposed bounded consolidation scope | 33 | **283** | **215** |
| Complete `p114r_*`/`p114g_*`/`p114h_*` families | 144 | 1,152 | 863 |

Counts split the pinned source at top-level `def`/`type` declarations and count
each selected declaration up to the next one. Physical counts include intervening
blank lines/comments; nonblank counts are reported to prevent a formatting-only
win. Separate `law` signatures and surrounding type declarations are not included
in the selected 33-function total. Exact selected names follow.

* Scanner: `p114r_{prepend,branch,scan,scan_normal,scan_frame,scan_next}`;
  `p114g_{prepend,branch,scan,scan_normal,scan_frame,scan_next}`;
  `p114h_{scan,scan_normal,scan_target,scan_frame,scan_next}`.
* Entry: `p114{r,g,h}_{prelude,plan}`.
* Hygiene: `p114{r,h}_{clean_name,clean_value,clean_args,clean,clean_stmt}`.

Useful source anchors are the R scanner at line49068, G scanner at49429,
H scanner at49832, R hygiene at49226 and H hygiene at49751 in the pinned file.

## What is genuinely shared

The three scanners all:

1. Check an entire failure suffix before inspecting a normal block, retaining
   the original instructions in `P114RFailure`.
2. Recognize the same return and self-tail transition forms, producing
   `P114RResult` or `P114RAgain`.
3. Recognize continuation frames using `p112f_frame` and retain original scalar
   argument stores rather than reconstructing ownership operations.
4. Recurse through the same `N111If`/scalar list structure, preserving branch and
   frame encounter order.
5. Carry the established negative failure-suffix fact across safe scalar heads,
   avoiding another whole-suffix failure test.

R uses `P114RBody{valid,frames:List<String>,body}`; G and H use
`P114GBody{valid,frames:List<P114GFrame>,body}`. A frame record already carries the
name and capture count needed by the narrow R case. Thus two accumulator
representations and two sets of prepend/branch functions are avoidable in
principle. The actual output statement representation is already shared; a new
universal IR is unnecessary.

The R/H hygiene walkers also inspect the same nine `N111Stmt` variants, local
values, argument lists and branches. Their semantic difference is the forbidden
prefix predicate: R rejects `p114r_`; H rejects both `p114r_` and `p114h_`.
Preserve that difference rather than broadening the narrow path accidentally.

## Differences that must remain explicit

| Rule | R | G | H |
|---|---|---|---|
| Captures | Exactly one | At most eight | At most eight |
| Continuation closure | One narrow reconstruction | One general ready resume | Up to eight mutually connected local cases |
| Tail-argument check | `p114r_arguments` | `p114r_arguments` | `p126r_arguments`, plus ready-call resume |
| Ready helper calls | Not the H call interpretation | Resume uses existing worker scanner | Terminal and local-resume calls, including extended view |
| Entry restrictions | Original R guard | Also rejects existing ready worker | Also rejects known callable, bounds body size512, H hygiene |
| Code generation | Narrow R emitter | General G emitter | Table/dispatch H emitter |

`p114h_scan_target` delegates to `p124r_terminal` or
`p124r_original_target`; those can return to `p114h_scan_frame`.
`p124r_resume` is another admitted frame interpretation. They are not redundant
with the old R/G frame test. Keep these bounded call/ownership contracts intact.

There are only six external scanner callers in the pinned declaration graph:
the three `*_prelude` helpers, `p114h_close_cont`, `p124r_terminal`, and
`p124r_original_target`. This makes the seam tractable. The complete plans also
serve inspection APIs, so a refactor must preserve observable admitted/refused
plan results, or explicitly leave their compatibility wrappers in place and
charge their lines to the result.

## Active route and overlap with Phase140

Ordinary QBE emission goes through `p134e_public` to `p124r_public`.
For an entry without a matching direct worker, the actual selection chain is:

```
H using ordinary ready registry
  -> R
  -> G
  -> H using extended callable view
  -> existing fusion/fallback emission
```

That order is established by `p124r_public_h`, `p124r_public_r`,
`p124r_public_g`, and `p124r_public_extended` (pinned lines52806–52853).
In particular, this is **not** a simple R→G→H progression. A unified planner
must preserve the first successful route, including namespace guards and the
distinction between ordinary readiness and the extended view. Rendering the
broadest valid plan everywhere can change performance and exact QBE.

Phase140 `p140g_miss`/`p140g_scanned` cache `p112c_scan` plus `p112c_plan` as
`P112WorkerPlan`, then publish through `p112c_freeze`. That is the region-registry
layer, not these R/G/H public-render plans. Do not claim that merging the scanners
deletes this cache. A public render-cache hit already skips public planning and
rendering entirely; any benefit here is on misses and cold requests. Existing
public render dependency facts must continue to cover the reachable continuation
segments and ready/callable context.

Phase140's 9.902s warm registry interval is not a measurement of these scanners.
The current profile does not establish their inclusive cost or a speedup ceiling.
Source reduction and cheaper recognition are separate hypotheses.

## Smallest experiment and stop rule

Use a single first-order scanner over the existing statement grammar with a
small **explicit admission datatype**, not callback functions, arbitrary visitor
combinators or a general pass language. Keep the three policy differences local
and visible. One shared frame/body accumulator feeds the existing plan builders;
their emitters stay unchanged. The exact API form is subordinate to deleting the
old scanning mechanisms: do not merely wrap them in a fourth abstraction.

First extract a bounded R/G pair and their caller plan boundaries. Compare full
plans, including refusal, against both original functions. Include zero/one/two/
eight/nine captures; malformed frame tails; failure suffix before/after an unsafe
head; branches with repeated/mismatched frame names; ready self/foreign helper;
reserved-name collision; and non-tail resume. Then include H ordinary and
extended-view cases before deleting its scanner. These tests exercise admission
differences rather than only mirroring the new implementation.

Keep a one-hour kill gate: reject the architectural claim if the replacement
plus compatibility helpers exceeds approximately140 physical lines for this
283-line slice, needs a second general IR, or cannot preserve the exact chosen
route. An acceptable 20% cleanup can still be recorded honestly, but does not
meet a 2× simplification goal.

After the cheap plan comparisons, use the existing three frozen compiler
requests and a continuation-heavy ordinary program to require exact QBE. JS/C
implementations and shared runtime/verifier declarations remain byte-identical;
their ordinary product checks guard accidental assembly changes. Only then
consider native compiler timing on the same source and a larger integration
gate. This audit proposes no full-image rebuild before that evidence.

Expected implementation cost is roughly45–90minutes for a bounded prototype and
small controls if the representation remains as small as expected; the first
plan-equivalence failure could reject it much earlier. This is an engineering
estimate, not work already performed or a runtime gain forecast.

## Alternatives rejected for this cycle

* **Merge scalar and product lowering wholesale:** `p113d_*` and `p113pl_*`
  look similar, but product lanes, virtual bundles, ownership partitioning,
  result destinations, TRMC, and distinct error/fallback paths make a2× deletion
  claim unsupported. They already share scalar snippets and `P113DStmt`.
* **Replace the observer representation:** `NO_Plan`/`NO_Schema` already separate
  semantic borrowing analysis from QBE worker generation. Its C residual emitter
  also supplies admission checks that the QBE lowerer omits. Deleting it as
  “duplicate rendering” can remove layout/arity/binder validation. The existing
  Phase128 audit demonstrated that risk; retain its structural gate.
* **Make one generic IR walker:** Phase7 A03 moved obligations into mode/shape/
  sentinel conventions and missed both size and ordinary cost goals. This
  proposal must delete a specific duplicated recognizer, not reproduce A03 with
  a larger policy record. If its explicit policies become equally complicated,
  stop.
* **Unify all incremental caches:** parser/checker, original-book observer plans,
  static encounter-order images, ordered verifier readiness and rendered units
  have materially different invalidation contracts. Shared exact change
  evidence may remove repeated work, but a single cache abstraction does not
  currently demonstrate source or conceptual simplification.

The strongest supported conclusion is a bounded consolidation opportunity, not
an architectural breakthrough. Preserve the mature worker plans and verified
runtime boundaries; target redundant recognition before adding another layer.
