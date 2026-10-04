# Concrete opportunities for worker inlining and cleanup

This is a static follow-up to the [outlier inventory](outlier-inventory.md),
using the same selected23 saved modules. No generated module was imported or
executed; no benchmark, compiler change or raw-evidence write was made.
The purpose is to give a bounded worker-IR inliner concrete falsifiable targets,
including cases where inlining alone cannot remove the transport allocation.

## Scope and counts

The inspected roots are RLE `main.out`, Map churn `bench`, and records `bench` in
`selfhost/build/phase45/full-preparation-worker23/modules/`. Complete assignment
ASTs were parsed with Node24.18.0's embedded Acorn. Private `$R` function names
encode instance indices; each index was joined to that root's ordered `$guards`
list to recover the original source name. Different roots give the same helper
different indices, and a source name can have several contextual instances.

| Root | Private `$R` declarations | Acyclic-marked declarations | Straight-line acyclic declarations |
| --- | ---: | ---: | ---: |
| RLE `main.out` | 13 | 6 | 3 |
| Map churn `bench` | 52 | 33 | 21 |
| Records `bench` | 52 | 33 | 21 |

“Straight-line” here excludes `if`, `switch`, `for` and `while` statements from
the function body. It does **not** establish leaf status, totality, lack of calls,
bounded IR instruction cost or semantic inlineability. Native and host calls can
remain inside such a function. These are candidate counts, not optimization
coverage or dynamic call counts.

The proposed first pass is narrower: at most12 `Assign*; Return` instructions,
no private calls or cases in the callee, supported tuple/tagged constructors and
projections, slots/literals, and a small total-U32 primitive set; at most32 added
instructions per caller including argument materialization. Native/global calls
and nonliteral Nat operations refuse. **Map.lo/hi and Map.del.fin are the clearest
initial witnesses.** `Char.cmp` and `Map.diff.step` refuse; String construction in
`Map.bit.go.rec/chr` and `String.cmp.rec` must not be assumed to fit the restricted
constructor whitelist. The broader structural counts above overestimate this
first pass's eligible population.

All spans below are half-open **UTF-16 source offsets** from the original saved
module, matching Acorn's `start`/`end`. They are not byte offsets. Most generated
roots occupy one long line: RLE line826, Map line875, records line872.

## Small shared helpers worth exposing

| Source helper | Map index and function span | Records index and function span | Exact body structure | What a local pass could expose |
| --- | --- | --- | --- | --- |
| `Map.bit.go.rec` | 19; `[152589,152871)` | 15; `[142670,142952)` | Four assignments: read both tuple fields, prepend a character to the String, construct one pair, return it. | Eliminate the helper boundary and propagate fields into a known consumer. The returned pair still crosses recursive returns unless another pass handles that boundary. |
| `Map.bit.go.chr` | 22; `[153626,153908)` | 18; `[143707,143989)` | Four assignments: read both tuple fields, rebuild String prefix, construct one pair, return it. | Same transport pattern under a different caller arm. Its input comes from branchful `Map.bit.chr`, so the first linear slice may not see the producer's fields. |
| `Map.lo` | 38; `[178413,178687)` | 31; `[152357,152631)` and 36; `[170454,170728)` | Four assignments: read a result pair, construct `MNode`, construct a pair containing that node and the carried result. No calls in the helper. | A clean leaf-inlining witness. The tree node usually belongs to the persistent result; do not classify it as dead simply because the transport pair is removable elsewhere. |
| `Map.hi` | 39; `[178687,178961)` | 32; `[152631,152905)` and 37; `[170728,171002)` | Same four-assignment shape with the opposite child order. | Independent branch/order control for the same general transform; tests must distinguish the children. |
| `Map.del.fin` | 35; `[177814,177986)` | Not in this records graph. | Two tuple projections, returning only the first field; no calls or constructors. | Inline the consumer and remove the unused second projection when private-field facts justify it. This alone does not remove the pair returned by branchful `Map.pop`. |

For example, normalizing only register names, `Map.bit.go.rec` does this:

```js
const text = pair[0];
const answer = pair[1];
const rebuilt = (typeof ch === "string" ? ch : String.fromCodePoint(ch)) + text;
return [rebuilt, answer];
```

This is a useful small inline body. It is **not** permission to erase
`String.fromCodePoint`, move it across another operation, or discard the returned
pair while a caller still expects that representation. Original dependencies and
host guards must remain even if the final code no longer names the helper.

The existing [selected CPU profile](../phase45/diagnostics.md) gives this family
a stronger anchor than static size alone: records attributes 9.311% self CPU to
the private `Map.bit.go.rec` helper, while Map has no named self sample for it.
Inlining and sampling can hide or shift that attribution. It is not a prediction
that removing this function removes 9.311% of execution time.

## Richer constructor/projection chains

| Chain | Map span / calls | Records span / calls | Required next step beyond merely copying the body |
| --- | --- | --- | --- |
| `Char.cmp` produces `((char,char),cmp)` | Index9 `[140860,141274)`; calls at144369 in `$worker11`,146201 in `$native11`. | Index5 `[130991,131405)`; calls at134490 in `$worker7`,136312 in `$native7`. | Two result tuple shells enter the comparison component via a tail transfer. Expose the producer, then forward fields across that transfer or flatten the private component parameters. |
| `String.cmp.rec` reconstructs `((String,String),cmp)` | Index10 `[141274,141711)`; two static private call sites. | Index6 `[131405,131839)`; two static private call sites. | Eight assignments include four projections and two result shells. The reconstructed result crosses recursive return boundaries, so local straight-line cleanup may leave the shells intact. |
| `Map.diff.step` produces `(difference,equal)` | Index16 `[149286,149700)`; calls at150975/151857. | Index12 `[139367,139781)`; calls at141056/141938. | Six assignments, one result pair and a call to `Map.diff.chr`. The pair goes into another component case through a tail transfer. A leaf-only first slice can refuse this helper. |
| `Map.bit` produces a native divmod pair then calls `Map.bit.at` | Index25 `[156453,156706)`; consumer index24 `[156189,156453)`. | Index21 `[146534,146787)`; consumer index20 `[146270,146534)`. | Consumer inlining exposes the two projections, but `$natDivmod` remains the producer. Removing its pair needs an explicit native result/layout rule, not an arbitrary assumption about any call result. |

The `Char.cmp` body also has `checkedChar` operations and a residual native
`U32.cmp` call. Its JavaScript contains **three** array literals: two transported
result tuples and the native call's argument vector. Counting all three as
removable tuple shells would conflate different contracts. The IR pass must keep
each nontrivial operation once and at the original demand point.

The two call sites in these examples are usually the same source edge emitted
into both native and continuation-machine implementations. They do not imply
that both execute on the timed input. An IR transform before emission can improve
both paths; a diagnostic source derivative must not silently patch only one.

## RLE: real opportunity, outside the simplest linear slice

RLE `rle.step`, index7, occupies `[108955,109402)`. It has two Boolean arms,
seven assignment sites, five tuple literal sites across those arms and one
private List constructor site. False constructs the previous run plus a new
state; true increments the count and returns updated state. Its one private call
site at110668 lies in `$native10`, immediately before the state becomes an
argument of the next `rle` tail iteration.

Thus the natural optimization is **branch-aware private state flattening**:
carry the current item, run count and output list as separate values through the
tail component. That requires preserving both branch results and transferring
parallel arguments correctly. A strictly linear callee inliner should refuse
`rle.step`; absence of a gain on RLE would not refute its narrower implementation.

There are also only three straight-line acyclic helpers here: `digest`, `lrevp`
and the nullary input-building root. `digest` forwards into a recursive helper;
`lrevp` seeds a recursive helper with `Nil`; the root constructs the input list.
None is a convincing claim of broad allocation elimination from local cleanup.
The encoded list is consumed by both length and expansion, so general fusion
cannot assume it has only one use.

## Suggested first screen and interpretation

Use Map churn and records for the first realistic comparison, plus a renamed
synthetic leaf that returns a tuple and a caller that immediately projects it.
The latter must prove that the intended IR rewrite activates and actually removes
the shell; the realistic sources test whether enough opportunities survive
existing V8 optimization to matter. Keep RLE as a scope/control point rather than
requiring it to speed up under a deliberately linear first slice.

Record separately: eligible helpers, inlined call sites, removed private
projections/constructors, program bytes, clean medians, and sampled allocation.
A high inline count with unchanged allocation is plausible given the return/tail
boundaries above. It motivates one small parameter/result-forwarding extension,
not an unbounded inliner. A code-size increase without repeatable clean speed
benefit is a valid rejection.

Fresh static output should retain the helper's original dependency membership,
ordered native/error operations, and both native and machine semantics. Verify
parallel captures, reused local IDs, branching consumers, argument permutation,
unknown/escaping aggregates and exact mutation fallback. Existing boundary
controllers should accompany the focused values; a checksum alone cannot prove
public object identity or call-order preservation.

Module hashes: RLE
`0337d8cc760ee3eec80436988104ead81f72440f36b57f165a1b87d69f6ea123`,
Map churn `652574426a7a8c234dbda91841ec3505dd655da08b5c357451d67ed3aa7ac998`,
records `5ba71c4ff05b1c9af4f3af39cac5fbc36a0b276511a0c46a5d0c51e6795c6c94`.
All claims above concern these saved bytes. No numerical speedup is predicted.
