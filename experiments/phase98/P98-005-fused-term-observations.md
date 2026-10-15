# P98-005: preserve roots across scalar term observations

Status: fused tags selected; held scalar projections excluded. Final B1/B2 timing and qualification passed; see the [final report](../../implementation/phase98/README.md).

The held equality result suggests keeping a complete term live while observing
its tag or scalar fields. The current consuming projection can keep/drop every
field of a shared KTerm even when the caller only needs a Bool or U32.

The fused-tag contract is exact equality to the original
`p88_string_eq(tg(term), key)` for every actual term constructor and arbitrary
String key. It preserves generic terms whose logical tag is `Lam` or `Lit`,
distinct physical lambda/literal constructors, payloads and metadata. It changes
1,366 existing left-tag comparisons; right-tag comparisons stay unchanged to
retain evaluation order. The selected v4 derivative adds23 lines overall and
removes8,661 source bytes. Earlier v3 passes the same law but fails the intended
borrowing mechanism; preserve that failure.

Full upstream-emitted v4 C has a borrowed term reader and borrowed recursive
string walker. The next gate is the real six-source compiler screen, followed
by broader and B2 qualification if material. A checked law alone does not show
that the backend selected this code or that runtime ownership is correct.

The separate scalar experiment leaves the exact ix/qt readers unchanged except
their private names and adds held-root wrappers using one shared finishing
function. Its ten complete-value cases retain originals, children, duplicates,
wide U32 fields, spans and literal payloads. Universal projection laws and actual
native ownership/code-shape checks precede a full compiler build. Compose with
tag fusion only after independent evidence; do not multiply micro speedups.
