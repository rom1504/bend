# Paired native annotation/erasure prototype

Status: **source prototype delivered for root integration; not built or measured
by the investigation agent**. This is partial deforestation, not completed
annotation removal and not a production recommendation.

Patch: [fused-native.patch](../../experiments/phase84/prototypes/fused-native.patch).
It changes `selfhost/src/back/native/request.bend` and the two native transport
boundaries in `selfhost/tools/typed-driver.mjs`; production files were not edited
by this agent. The isolated copies are under `/tmp/bend-phase84-fused`.

## What it implements

`nr_fuse_selected(book, selected, stops)` returns a private `NR_FusedSelected`:

- `defs`: the same annotated definitions expected from `annotate_selected`.
- `bodies`: `NR_FusedBody` records carrying runtime erasure produced alongside
  annotation, rather than by a subsequent full recursive erasure walk.
- `fused` / `ordinary`: counts of paired versus unchanged definitions. These
  are definition counts, not claims that every node uses the fused path.

The paired producer directly handles literals, lambdas, application spines,
ordinary applications, constructors, matches and lets. It preserves the old
application-spine traversal so intermediate types are inferred once. Constructor
annotation and runtime erasure share telescope interpretation and field
quantities; closed stable telescope suffixes retain the fast path. Matches
share the instantiated telescope between annotation goals and runtime field
count/mask construction.

Quantity-zero arguments use ordinary annotation plus a discarded placeholder,
so the paired producer does not unnecessarily construct runtime trees that the
old eraser would immediately skip. Equality goals likewise retain exact source
annotation and directly produce `Rfl`. Explicit annotations, rewrites and other
forms use the existing `ka_node` plus erasure as a local fallback. Native stops,
foreign/absent definitions and the original `dx > 0` exclusion remain unchanged.

`nr_prepare_fused(book, selected)` runs **after the same layout check**. It builds
the exact merged annotated source and binder bound, transports produced bodies
into the existing request cache, and walks the runtime closure. `nr_visit` now
consults that cache through `nc_definition`; an absent body takes the original
`nc_definition_plain` fallback. Its final closure still contains precisely the
existing erased-body/arity product. The ordinary `nr_prepare` path clears caller
facts through `ns_source` before walking, as before.

The producer does not issue scalar/effect/observer permission. Those checks still
consume the exact annotated source, and original observer bodies remain intact.
JS and injected API callers stay on the old path. The dedicated product type is
private trusted transport; public KDef tags do not grant new checked permission.

## Bridge edits included in the patch

1. Export `nr_fuse_selected` and `nr_prepare_fused` beside existing request APIs.
2. On the owned native path, obtain `layoutDefs` from `fusedNative.defs`.
3. Run the existing `jl_checked_error`/layout boundary without moving it.
4. Prefer `nr_prepare_fused(contextBook, fusedNative)` after that check.

No module registration change is required: the implementation is appended to
the already-registered `request.bend`. The patch adds278 Bend physical lines
and5 net driver lines. Keeping it would require evidence justifying that extra
consumer/producer complexity; small gains are a reason to reject it.

## Important limitations to measure

This retains the annotated graph because scalar permission, sharing and layout
consumers need it. There are still two persistent body representations, as in
the baseline, plus short-lived paired return values. There is no new stored
third AST, but the temporary pair objects and partial body index cost time.

The first version pairs every selected definition. Old `nr_walk` erases only
the runtime closure. If initial selection includes many type-only definitions,
this prototype may produce unnecessary erased bodies and lose despite cheaper
per-node processing. Compare selected ordinary definition/body-node totals with
the actual runtime closure before expanding this approach. A future demand
producer must also preserve the layout traversal's conservative refusals.

The prototype performs runtime-body work while producing annotations, before
the layout rejection boundary. It must therefore remain total on checked but
layout-rejected inputs and preserve their first public diagnostic. This is a
required control, not an assumed consequence of successful programs.

Generic field traversal substitutes original source arguments, like annotation;
the old independent eraser substitutes the annotated fields. On valid checked
telescopes these should determine identical quantities/layouts, but dependent
constructor controls must establish exact products. Do not silently accept
near-equivalence or C equality while intermediate permissions differ.

## Fast differential controls

Build a checked B1 first. Extend diagnostic stage selection to
`nr_fuse_selected` and `nr_prepare_fused`; old annotation/preparation names alone
would omit the new cost. No compiler or benchmark was run by this agent.

For the same checked, specialized `contextBook`, selected definitions and stops:

1. Compare `nr_fuse_selected(...).defs` structurally with
   `annotate_selected(...)`, including spans, field annotation quantities and
   lambda syntax metadata. Raw object pointer identity is not required.
2. Compare complete `nr_prepare_fused(...)` against
   `nr_prepare_annotated(contextBook, annotate_selected(...))`: source,
   closure order/names, bodies/arity, foreign paths/scope, bound, static context
   and constructor index. An ordinary body-cache miss must still fall back.
3. Compare layout errors and exact generated C, then clean whole requests with
   all product construction included. The fused/ordinary counts should be saved
   outside the timing-critical request where possible.

Controls should cover:

- A scalar literal and scalar applications with metadata/spans.
- A multiargument Ref/Var spine, including partial application and erased args.
- Explicit/implicit affine lambda quantities, especially explicit2 versus type1.
- A constructor with mixed erased/live fields and a dependent field telescope.
- Native versus user constructor identity and match live-field masks.
- Nested matches and excluded alternatives, including a single-constructor ADT.
- Sequential and parallel lets; alias variables carrying source payloads.
- Equality proofs, rewrites and explicit Ann fallback.
- Arrays whose layouts are valid or deliberately open, plus custom/unsafe effects.
- Foreign, stopped/native, raw cache injection and higher-order/bang cases.

Start with Numeric, Map and Functions65 paired product identity and a short
native control subset. Measure B1 before paying for a genuine B2 build. If the
temporary pairs/index or extra type-only bodies erase the benefit, preserve and
reject this prototype; do not describe it as the larger operation-IR redesign.

The concrete diagnostic is
[`fusion-controls.mjs`](../../selfhost/tools/performance/phase84/fusion-controls.mjs):

```sh
node selfhost/tools/performance/phase84/fusion-controls.mjs PLAN CASE FRESH_OUTPUT_DIRECTORY
```

Use the plan's pinned Node and the usual resource limits. The plan must contain
the frozen `candidate` role with a successful preparation report and expected C.
The harness wraps the actual owned API exports; it does not inject a substitute
API or emulate compiler semantics. It compares every annotated definition field
and every field of the complete final `NR_Request`, including private indexes,
using an iterative structural comparison that permits different graph sharing.
It also requires exact frozen C, unchanged prepared files and frozen inputs.
Produced-definition counts and runtime names are recorded in `report.json`;
complete C is preserved as `actual.c`. Comparison failure preserves the report
and a structural path to the first difference. This repeats work deliberately,
so its duration must never be treated as a clean performance sample. One passing
successful request does not establish rejected-input controls or broad coverage.

The agent checked harness syntax and audited all new local Bend bindings for
untyped constructor RHS expressions. All local RHS expressions are typed function
calls; nested constructors receive function-return or argument type context.
No target compiler was run by the agent. Root owns checked builds, differential
execution and candidate promotion.

## Delivery identities

Original `request.bend` SHA256:
`348f3e47b5cd907e16e55db59d090804f26120b2b294ce56d94dd5a64ffc314b`.
Original driver SHA256:
`8af64866d16dc063056261bbd6f2ab1a1689a37d466ba87e4a6004b72cdb6a88`.
Initial patch SHA256:
`c86ff6eeab32e28757b49ad7df2d193b92d84065bc77fc0c21fd21ef90ba1746`.
Root may revise the candidate while integrating; updated candidate identities and
actual validation results belong in the phase report, separately from this
unmeasured delivery note.
