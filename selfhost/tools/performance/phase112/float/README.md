# Floating primitive backend expansion

This optional emitter recognizes a verified `p111_rt_op` call with exact
`state`, a named operand buffer, literal primitive ID, literal arity, and U64 destination.
It expands IDs 26–35 (binary32 add/subtract/multiply/divide and six comparisons)
and ID 23 (unsigned U32 to binary32). All other calls use the unchanged accessor
renderer and its original Phase111 fallback.

The N111 model, original structured verifier, runtime ABI, ownership operations,
and source lowering are unchanged. This is a backend intrinsic expansion, not a
new functional-IR proof or an unboxed floating ABI. The public renderer must
still verify the original graph before emission. In particular, the verifier
proves the original runtime signature, primitive ID/arity, state identity,
operand-buffer capacity, definite assignment, and terminal control flow. The
buffer may be a different allocation or a fusion-renamed local. The original
verifier also admits the state pointer itself with capacity 2,088; these
selected pure operations read the same words in either implementation and
perform no buffer/state writes or ownership actions.

Each expansion loads the original full64 scratch words before assigning the
destination, explicitly truncates to low32, bitcasts to QBE `s`, computes the
single operation, bitcasts back, and zero-extends the result. Full-width loads
avoid an endian assumption about which half of an eight-byte slot is low.
Comparison results are also explicitly zero-extended to the original raw Bool
word. The existing temporary counter reserves nine fresh names; mutable-local
or result/input aliases cannot overwrite an operand before it has been read.

The QBE 1.3 IL contract is in
`selfhost/build/phase108/toolchain/qbe-1.3/doc/il.txt`: single arithmetic,
`ceqs/cnes/clts/cles/cgts/cges`, bit-preserving `cast`, `uwtof`, and `extuw`.
No fast-math, reassociation, fusion, approximation, or precision widening is
requested. NaNs remain unordered except inequality, signed zero is preserved,
and each original arithmetic operation still rounds to binary32.

The qualified runtime's `f32_unbox` discards the upper32 bits, and `f32_rewrap`
returns zero-extended bits (`runtime-source04/runtime.c:618–626`). The exact
primitive cases are in `phase111/runtime/primitives.inc.c:122–172`. Its sqrt and
transcendental cases promote to double libm and narrow afterward; they remain
runtime calls. `f32_to_u32` also remains a call because its specified range and
NaN guard must be preserved. `f32_bits` is a full-word identity, so its fallback
must not be replaced with low32 masking.

## Composition

Append `emit.bend` and optionally `controls.bend`, then explicitly override
`entry-accessors.bend` after the selected both-accessor entry. This adapter uses
`p112a_stmt(3,...)` for its fallback and therefore requires those accessor
modules. Selected static-image, continuation, loop, and direct-worker renderers
remain composable through their existing `p111q_stmt` calls. All new helper
names use `p112fp_`, separate from the fusion experiment.

Export `p112fp_control_report` (21 structural outcomes), `p112fp_expand`,
`p111_verify_program`, and `p111q_chunks`. Root can run:

```sh
node selfhost/tools/performance/phase112/float/controls.mjs \
  BASELINE_API.mjs CANDIDATE_API.mjs FRESH_OUT
```

The transport emits two pure raw-IR programs using the respective checked Bend
APIs. Both observe 104 full64 results as sixteen hex digits per case; 100 calls
are eligible for expansion and four must stay runtime calls. `cases.json` and
`expected.stdout` were frozen independently before target execution. Cases
cover normal arithmetic, overflow, subnormals, tie-to-even, ±0, infinities,
upper-word truncation, NaN comparison behavior, alternate and fusion-renamed
operand buffers, and unsupported fallbacks.
Arithmetic NaN outputs are checked by class with a zero upper word; generated
NaN payloads are not assumed stable. An explicitly supplied NaN payload is
observed exactly through `f32_bits`.

The observation program uses 104 small case segments plus its zero-argument
entry. Each case receives one owned accumulated String through the original
register-bank dispatcher and prepends its observation; the final case returns
the completed String. This bounds per-segment checked-emitter recursion while
preserving the same case order, ownership transfers, and expected output.

`admit.py --source ACTUAL --runtime RUNTIME --static --liveness --out FRESH`
authenticates exact new source, the original machine model/verifier, accessor
fallback, runtime/header, and static public boundary when selected. Omit the
last two mode flags when absent. Six reflected-source mutations must refuse.
The compiled runtime object and native observations require separate receipts.

This exposes arithmetic and preceding scratch stores to QBE optimization. It
does not remove continuation transport or unbox products across calls. The
raytrace source has many arithmetic/conversion sites but also hot functions
with more than eight arguments, outside the current private-worker cap; a
large overall parity claim would therefore be premature. Compare the same
frozen ray oracle and workload before and after this single optional adapter.
