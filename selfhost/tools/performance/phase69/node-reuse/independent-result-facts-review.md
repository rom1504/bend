# Independent review of P69-010 saved-C facts

Source/data review only. No compiler or target execution by this reviewer.
Reviewed `prepare-result-facts.py` and
`selfhost/build/phase69/result-facts-prep01/plan.json` before considering any
general compiler change. No concrete correctness blocker was found for this
finite checked lexer discriminator.

The pinned lexer defines Mode as `Gap{}`, `InId{h: U32}` and `InNm{v: U32}`;
Cls has four nullary user constructors. Mode's dynamic constructor emission
packs its proved U32 payload under `NATIVE_PACK_CTORS`, while its static path
also emits the packed value. These values do not acquire RFC wrappers.
The five edited worker entries select the correct Mode/Cls argument slots,
retain full Term tags/payloads, and guard the assumptions with both
`NATIVE_TYPED_SCALARS` and `NATIVE_PACK_CTORS`.

Both guards are necessary. A dead foreign definition can disable constructor
packing globally even when live-only checked scalar permission is enabled.
Type shape alone is also insufficient: Base Bool has nullary source
constructors but emits immediate 0/1 instead of `TAG_PAK`. Neither exception
applies to the explicitly pinned user Mode/Cls types in this diagnostic.

The 33 result edits follow successful private calls and narrow only checked
U32/Char semantic result slots. They do not confuse a private C worker's
success return value with its `nq_result` output. For `step` and `step.at`
product workers, only field 1 is narrowed; field 0 retains the tagged Mode.

Independently verified every plan input/output pin, the historical fixture's
membership in the retained checked emission inputs, and reverse application
of all edits recovering the exact parent C. The ordinary arm has zero edits.
These checks establish provenance and the scope of the intervention, not a
general proof for arbitrary annotated raw code.

The root-owned timing result is recorded separately in
`experiments/phase69/P69-010-native-result-layout-facts-result.md`. Both arms
remain diagnostics; this review does not authorize treating their handwritten
source-name selections as a production optimization.

The compact audit metadata is included in
`../methods/final-review-data.json` under `savedCFactsPlan` and
`savedCFactsArms`.
