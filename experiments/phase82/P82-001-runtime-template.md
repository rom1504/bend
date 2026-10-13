# P82-001: canonical runtime parts

Status: implementation planned; no gain or promotion claim.

Hypothesis: repeating the Bend runtime scanner for unchanged canonical bytes
costs 43–66 ms per B2 request and substantial temporary allocation. A small
artifact produced by that scanner can remove this work without changing C.

Method and boundaries: [design](../../design/phase82/fixed-work-and-native-products.md).
Compare frozen Phase78 and checked candidates with reports enabled, exact C,
three IO sources and two non-IO held-outs. Keep raw and altered runtime behavior.
Record artifact provenance and structural controls; qualify genuine B2 before
promotion. Subsequent findings belong in [report](../../implementation/phase82/README.md).
