# P114-003 — reuse mature unary constructor packing

Hypothesis: the QBE route loses a representation optimization already present
in the mature C emitter. Ordinary scalar leaves are heap allocated, then often
receive an additional reference-count wrapper when stored in a parent. Upstream
uses an immediate PAK word for the same fitting scalar leaf.

Reuse the exact mature full-U64 guard: payload <=2^40−1. Preserve its CID and
payload in a packed word; otherwise retain the original constructor helper and
sealing. Restrict admission to checked ordinary user constructors with one
field. Base, builtin and effect identities retain their original lowering.
Apply this at shared constructor lowering, not only private function emission.
The runtime object and verifier stay unchanged. Existing take/tag/keep/sink,
parent sealing and ADT readback already support this representation.

Source API and exact source/runtime admission pass. All four ordinary programs
pass complete outputs; the additional large-Nat boundary case needed
a source fixture correction because its initial decimal literals exceed the
current parser's admitted literal syntax. The original failed fixture remains;
v2 constructs the same values with ordinary Nat arithmetic and retains the
independent expected stdout. Three paired rounds give tree554→490ms and
expression488→459ms; list700→699ms is effectively unchanged. All27 benchmark
output/count observations pass. Geometric mean candidate/baseline0.94005;
still10.723× upstream on this selected three-case denominator. Structural
admission, finite semantics and performance are separate.

Falsifier: wrong CID/field readback, sharing/release mismatch, changed fallback
for owning or large fields, or no useful runtime gain on expression/tree. List
pipeline is a two-field scope control. Use the unchanged original45 workload
definitions and three-round paired screen before composing other changes.

Source SHA256 `cf78182c4ca1e18a52118ea6b4db1b284b9f3c204467a466e4db317f60134dc1`.
Evidence: `selfhost/build/phase114/packing-admission01`,
`selfhost/build/phase113/p114-packing-controls01-jobs`,
`selfhost/build/phase113/p114-packing-screen01-jobs` and
`selfhost/build/phase112/p114-packing-screen01-measure/report.json`.
