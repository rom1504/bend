# P82-001: canonical runtime parts

Status: compiler04 selected for integration; installation pending qualification.

Hypothesis: repeating the Bend runtime scanner for unchanged canonical bytes
costs 43–66 ms per B2 request and substantial temporary allocation. A small
artifact produced by that scanner can remove this work without changing C.

Method and boundaries: [design](../../design/phase82/fixed-work-and-native-products.md).
Compare frozen Phase78 and checked candidates with reports enabled, exact C,
three IO sources and two non-IO held-outs. Keep raw and altered runtime behavior.
Record artifact provenance and structural controls; qualify genuine B2 before
promotion. Subsequent findings belong in [report](../../implementation/phase82/README.md).

Template-only compiler02 saves1.87% on the B1 IO screen and17.7% on small.
Combined with exact-source-bound reuse, compiler04 saves5.10% B1/6.15% B2 on
the paired IO screen; held-out B2 small/functions65 improve20.7%/15.1%.
Both stages pass125 renderer controls; five driver transport controls pass.
All final75 clean intervals retain exact C and public reports. This is a
compilation improvement, not a generated-program execution improvement.
