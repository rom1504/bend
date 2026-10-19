# Independent region controls

`region-controls.mjs API.mjs FRESH_OUTPUT` is a coordinator-only transport over
the actual checked Bend region API. It does not optimize graphs in JavaScript.
The fixture sources are synthetic N111 graphs, not actual-source coverage claims.
No target was executed while preparing these controls.

Export `p112r_index`, `p112r_program_counts`, `p112r_segment_chunks`,
`p112r_private_call`, `p112r_buffer`, `p112r_round`, `p112f_index`, `p112w_symbol`, `p111_verify_program`,
`p111q_ids`, `p111q_segment` and `p111q_chunks`. The registry entries must retain
the first admitted transformed `segment`, exact `plan`, `rank` and `sites`.

Five paired baseline/candidate QBE fixtures have independently specified complete
stdout oracles:

| Fixture | Expected stdout | Purpose |
| --- | --- | --- |
| nested-nontail-chain | `142` | Two non-tail calls across strictly increasing admission ranks |
| tail-loop-calls-leaf | `10001` | A private self loop with a direct leaf call on each iteration |
| pending-outer | `1142` | The outer continuation remains pending while the inner frame is removed |
| capture-alias-result-first | `"α😀"` | A shared dynamic String survives releasing the returned owner first |
| capture-alias-alias-first | `"α😀"` | The same physical alias survives the opposite release order |

Each emitted file has its `.stdout` oracle, including a final newline. Native
execution must link both variants against the same authenticated runtime04 and
require successful exit plus exact stdout/stderr observations. The fixtures do
not expose a live-heap census; ownership coverage combines full readback, both
release orders and the retained runtime's reference counting checks.

The controls additionally require exact private-call signature refusal, an exact
finite scratch-buffer whitelist, original-verifier refusal of forged private
calls, generic fallback for non-tail self/mutual recursion, first-entry stability
under an unrelated source addition and increasing dependency ranks. Independent
single-round construction also compares every old entry in each later round,
then requires exact equality with the six-round registry. A loop's
private body must contain a local backedge and no frame/register/return transport
calls.

Source admission must separately bind the region implementation and final
emission hook to the same compiler/runtime receipts. The emitter must consume
the stored first-admission segment and plan. Replanning with final readiness can
introduce dependencies that were absent from the frozen rank and is not covered
by these controls. The original verifier remains mandatory before any generated
private-call or scratch-buffer extension is considered. Scalar, static and
fail-stop overlays keep their own source/runtime premises.

The current source-only method `admit-regions02.py` uses the closed
`conjunction-regions02.json` recipe. It binds the original model/verifier,
qualified fusion03 and all seven region modules, including the final hook,
against the composed compiler and exact runtime04 source/object. Eleven changed
source controls must refuse; they include changed region rank/arity bounds,
mutable pass readiness and reconstruction of a frozen private plan. Existing
conjunction03 receipts cannot be reused for this hook. The region profile's
private bound is eight arguments, even though unused wide32 declarations remain
in the source composition.

Region02 pins `regions/modules02.json`
(`e913ec8077b6982f4f5b165213c04c0240534740d9ecaa504438c44d7b87b42a`).
Its only implementation change is the checker-required local `N111Segment`
annotation in `p112r_fused`; bounds, interfaces and frozen-plan behavior are
unchanged. Admission01 and its recipe remain preserved. Region02 target
qualification is pending coordinator execution.

Independent source review of `regions/modules01.json`
(`d18a5bfda29f4ef2adcb1cd35b3f61a56fb868e9d35e8a53ab72f8f8883368ed`)
found no concrete defect. `old` readiness and symbol metadata remain immutable
through a complete pass; later rounds skip existing entries; private emission
reads the stored transformed segment and plan directly. All terminal operands
are copied before canonical scratch stores. Fresh buffer admission depends on
exact fusion generation, original namespace hygiene and preserved original
offset/type validation. Public final-readiness fusion cannot add edges to the
frozen private dependency graph. This is a source audit with explicit premises,
not an executed qualification or a formal proof of the lowering.

```sh
python3 selfhost/tools/performance/phase112/workers/admit-regions02.py \
  --runtime-source selfhost/build/phase111/runtime-source04/runtime.c \
  --runtime-object selfhost/build/phase111/runtime-source04/runtime.o \
  --compiler COMPOSED/compiler.bend --out FRESH_ADMISSION
```
