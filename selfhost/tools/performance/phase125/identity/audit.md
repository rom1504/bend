# Eliminate exact primitive identities before scratch transport

`model.bend` overrides only `p112_intrinsic_fallback`. The existing lowerer routes both ordinary N111 and direct/product operations through this function (`p111_intrinsic -> p112_intrinsic`; product operations use `p113ai_intrinsic`). It is therefore earlier and simpler than adding separate scalar/float/direct emitter hooks.

Two complete runtime cases are exact identities for every 64-bit operand:

- `u32_to_nat`, authenticated primitive ID24: `p111_primitive_arity(count,1); return ((u64)args[0]);` (`runtime-extend01/runtime.c:4108`).
- `f32_bits`, ID59: `p111_primitive_arity(count,1); return args[0];` (`runtime-extend01/runtime.c:4248`).

The candidate recognizes exact primitive names and an exact singleton evaluated-value list, then produces `N111Set{"value",N111U64{},input}` and returns the existing `value` local. This preserves result capture timing and full-width bits, including F32 NaN payload/signed-zero bits. It neither forwards a possibly later-overwritten local by reference nor narrows a U64 value. The old scratch write plus runtime call disappear; the ordinary graph and direct-function verifiers still check the resulting assignment and all surrounding code.

Wrong arities and all other operations use an exact copy of the previous fallback, including its unknown-ID error and counted runtime call. Thus invalid counts are not made acceptable. The singleton branch itself discharges the removed runtime arity test; the unchanged frontend and native verifiers retain source/type/value legality. Operand evaluation and its effects precede this hook and remain in their original order. The deleted scratch write is solely the private argument transport for the deleted call; the returned snapshot remains at the same lowering point. There is no new helper ABI, pass, cache, fact table, or IR node.

`u32_from_nat` is **not** a full-width identity: it truncates to32 bits. `array_set` returns its first operand but performs a mutation; it is excluded. `p111_rt_special_ctor`'s Chr case is another pure unary identity, but it is a different constructor catalogue and not included in this ablation. U32/F32 special constructors call `term_word` and must not be mistaken for unconditional identities. No arithmetic operation with exceptional/boundary behavior is added.

`static-sites.json` records parent `ready-source02`, its SHA256, and exact QBE files/line/owner identities from `p124-broad-emit02`. The report's selected source agrees with that parent. Across45 files, there are335 ID24 call sites and zero ID59 call sites; every file contains at least one ID24 site. These are static emitted occurrences, including alternate and potentially unused paths, **not** execution coverage or runtime savings. RLE has six emitted sites and its source converts three run counts per invocation; no dynamic opcode counter was collected. Benchmark transfer and compiler overhead still require root-owned measurements.

`p125ic_controls()` has nine pure rows covering low/high words, maximum U32, F32 payload/signed zero, nonidentity conversion refusal, and both wrong-arity fallbacks. Fabricated non-source high words and wrong arities are analysis-only inputs, never native target probes. Existing ordinary source/alias controls and complete benchmark outputs remain the executable gates. No target or compiler was executed by this audit author.
