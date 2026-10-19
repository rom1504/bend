# P112-002: avoid materializing scalar Word patterns

Status: implemented; word-profile N1 passes19 focused native cases and a matched
three-source compilation screen. Native successor and all45 frozen batch-output qualification pass.

Hypothesis: preserve the existing NW_Rows pattern recognizer's low32 mask facts
before generic Word construction. This should remove representation work for
unchanged source computations, especially compiler parsing of the prepared Base.
Generic fallback must remain exact for escaping Word tails or unrecognized rows.

The old lexer compiler request performs1,625,654 U32 special-takes. Each builds32
WCon nodes and31 wrappers:102,416,202 allocations,82.14% of all measured allocation
calls. This is a mechanical allocation attribution, not CPU time. The composed
word/selector/fusion candidate reduces total calls124,677,389→16,515,651 (86.75%).
The selector part also removes most closure/apply calls; do not attribute those
independently to the Word transformation.

Independent low32/F32 bits, ordered rows, freshness, restored values and exact
fallback controls pass; four source fixtures each pass paired native builds.
Source-admission checks retain the structural verifier and runtime bindings.
The three fixed compilation inputs take0.34461 times Phase111 request wall time
and2.38072 times upstream TypeScript/Bun request time. Ready-executable stage sums
are0.35341 and1.14736 respectively. Prepared native Base/cached runtime versus
upstream source Base/full C compilation are disclosed build policies.

The six-program runtime screen does not improve materially from this change.
The win concerns the compiler workload; it is not a universal program-speed gain.
See [profile comparison](../../implementation/phase112/profile-comparison.md),
[composition](../../selfhost/tools/performance/phase112/word-pattern/README.md)
and [campaign report](../../implementation/phase112/README.md).
