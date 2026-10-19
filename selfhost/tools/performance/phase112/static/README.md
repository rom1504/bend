# Typed immutable images

This candidate restores closed-constructor images to the direct QBE path. The
frontend, original `P111Program` verifier, segment model, selected segment
emitter, and runtime implementation are retained. This is an additive candidate;
no performance or whole-compiler qualification is implied by source readiness.

The producer ports the mature `ns_prepare` semantic admission from the selected
Phase102 compiler. It reuses exact constructor arity checks, scalar literal
compaction, Bool/Char conversion, special/array/IO exclusions, foreign fallback,
nullary packing, restricted `$ctor.` unary packing, interning, and the 65,536
word cap. Image entries are typed `P112SWord` values, never generated C strings.
No `nw_prepare` or NF/NQ worker planning is introduced.

`P112StaticProgram{program,nodes}` contains the unchanged machine program and
ordered immutable nodes. Each node begins at the next exact word offset and
contains only raw U32s, legal packed words, or references to an earlier node.
The validator rejects unknown identities, wrong arities, gaps, cycles, forward
references, non-node offsets, invalid packed payloads, special constructors,
and budget overflow. The original segment verifier runs separately before any
rendering. These APIs are internal compiler stages; a caller-supplied facade is
not a checked-source ownership certificate.

Preparation rejects existing `NStatic`/`NWPattern` input atoms and builds fresh
request-local facts. Final `NStatic` atoms are shallow: constructor identity,
offset or payload, and representation tag only. This removes the closed child
graph from subsequent liveness traversals. Lowering validates each atom against
the fresh context and emits exact `N111Const{lo,hi}` halves. No new pointer
operation or arbitrary-memory permission is introduced.

The emitter resolves constructor IDs using the existing ordered catalogue,
emits `P111QLong` image words, and structurally replaces descriptor slots 8 and
19 (static word count and image pointer). `p111q_segment_chunks` remains the
selected segment renderer, including loop/direct-worker overrides. Empty
images use the original `p111q_chunks(program)` exactly. There is no QBE or C
text parsing.

Runtime ABI11101 already supports these images. The qualified runtime04 pins
`STAT_OFF=51413504`; startup copies the words below `HEAP_OFF`, keep/sink treat
them as immortal, and `spare_free` cannot free their locations. The unchanged
constructor helper can also place a static child inside a dynamic parent.

## Composition and checks

Using Phase112 `prepare.py`, append modules in this order:

1. `model.bend`, `plan.bend`, `verify.bend`, `original.bend`.
2. `emit.bend`, `lower.bend`, optionally `controls.bend`.
3. Apply `entry.bend` as an explicit override.
4. If the backward-liveness module is present, additionally apply
   `liveness-entry.bend`. Do not include that adapter without its original
   `P112Liveness` module.

The baseline fallback bodies in `original.bend` are exact renamed Phase111
declarations; `original.json` records their origin. The optional liveness
adapter also retains the exact old body under a new name. It removes the
otherwise-correct single continuation around a static let value.

Useful API exports are `p112s_lower_request`, `p112s_verify`, `p112s_chunks`,
`p112s_size`, `p112s_image_error`, and `p112s_control_report`. The last returns
20 independent named structural/producer outcomes. The budget controls seed
an internal producer counter to exercise exact fill and overflow fallback;
they do not claim to execute a 65,536-word image. `semantics.bend` has eight
frozen complete-output observations in `semantics.stdout`, covering empty and
Unicode Strings, retained aliases, nullary/unary/multi-field values, unused
owners, and a static boxed child in a dynamic parent.

Run source-only authentication before target checks:

```sh
python3 selfhost/tools/performance/phase112/static/admit.py \
  --source ACTUAL_COMPOSED_COMPILER \
  --runtime selfhost/build/phase111/runtime-source04/runtime.c \
  --liveness --out FRESH_PHASE112_RECEIPT_DIRECTORY
```

Omit `--liveness` if that adapter is absent. The receipt checks all exact static
declarations, the original verifier, checked frontend gates, runtime source,
header, and six source-integrity refusals. It does not replace target semantic
checks, runtime object provenance, or separate receipts for scalar/accessor/
worker optimizations. The older accessor admission tool intentionally expects
the original `p111_emit_admitted`; static composition changes that one boundary
and needs this receipt as well as an explicit composition review.

Qualification should compare complete baseline/candidate observations, inspect
image length and reduced constructor/continuation IR, and measure static-plan,
lowering, verification, emission, and generated-program runtime separately.
The frozen Unicode workload has 768 codepoints and needs 1,536 SCon field words
before deduplication. Static preparation happens after the checked frontend and
cannot improve time already spent there. The separately qualified backward
liveness change removes the earlier timeout, so static speed effects must be
measured against that same candidate.
