# P125-003: eliminate complete identity-call transport

Status: selected in source06; broad and native qualification complete.

Identity-only RLE screen0.98583×parent; no isolated broad contribution is claimed.
Final source passes nine pure identity controls plus the combined ordinary and
native gates. See the [report](../../implementation/phase125/README.md).

Pinned runtime operations u32_to_nat and f32_bits return their single full-U64
operand unchanged. Select a full-width result assignment at the existing
primitive lowering hook when exactly one evaluated argument is present. This
removes the private scratch store and call, preserving result snapshot timing.
Keep all other primitives and wrong arities on the original path.

The source audit and nine pure controls are in
selfhost/tools/performance/phase125/identity/. No new IR, ABI, pass or analysis.
Do not generalize to truncating conversions or operations that return an operand
after performing an effect. Static335 op24 sites in parent45 do not establish
dynamic coverage. Independent ordinary outputs and paired timing remain required.
