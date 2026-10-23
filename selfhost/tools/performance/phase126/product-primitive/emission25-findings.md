# Observer25: the new ABI existed, but the integrated closure was not reached

Static inspection of the actual root-emitted QBE found one additional private
function in each requested case:

| Case | Phase125 private functions | Observer25 | Added |
|---|---:|---:|---|
|record aggregation256|37|38|`$product.Map.bit.go`|
|evening|53|54|`$product.Map.bit.go`|
|map churn128|44|45|`$product.Map.bit.go`|

The new product adapter is12 QBE lines and calls the existing borrowed reader,
then writes two return words. Unlike the unchanged15-line public adapter, it
does not call the two-field constructor. However, **the existing routing path
still calls the public adapter**, so those facts establish only a better
available ABI, not eliminated executed allocation.

`Map.bit.at` remained a generic43-line segment containing one take2 and one
scheduler jump, with its original sink/failure branch. `Map.bit` remained a
generic21-line segment containing one opcode70 call and one scheduler jump.
The borrowed reader remained117 lines. These are static sites, not dynamic
invocation counts or timings. The source and decoded exact snippets are pinned
under `evidence25/` with a reproducible static-only inspection script.

The reason is a concrete integration error: the active entry reaches
`p118e_emit_workers -> p118b_compose`, while the first prototype attached closure
to the separately checked diagnostic `p118b_emit_verified` path. The checked
adapter and finite controls succeeded, but they did not prove the active entry
used closure. Root was informed before its timing started; no speed conclusion
should be attached to25.

`integrated.bend` and `manifest03.json` correct that wiring without replacing an
entry permission or verifier gate. Both original internal permission
continuations retain their exact observer discovery and cold-metadata handling;
they forward the same request into the closure helper only when a new product
adapter exists. Source26 is the next candidate requiring fresh checks. This is
not a claim that26 was measured or that all of its new functions will be faster.
