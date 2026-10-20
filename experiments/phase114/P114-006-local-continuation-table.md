# P114-006 — closed local continuation tables

Hypothesis: keeping only a single continuation local misses two-child recursive
computations. A bounded closed table of original continuation identities can
preserve arbitrary admitted post-recursive work and descend again without a
round trip through global registers and the dispatcher.

The design is the Phase114 architecture plan's explicit continuation variants.
The first implementation reuses the existing local-region statement model,
closes at most8 continuation identities, and authenticates matching capture
counts (0–8). Every case has separate hygienic locals and fixed scratch. Same-owner
edges snapshot arguments before parallel assignment. A local depth preserves the
caller's frame prefix. On result, pop/read FID, pop that case's captures, restore
pop0/captures/result, then execute the original resume order. Ready private calls
remain an acyclic bounded native graph. Unsupported regions retain fallback.

Source checking and independent review pass. Actual admission includes tree
warp/scan and expression generation/eval; eval has6 continuation cases and scan2.
Two independent ordinary programs pass complete outputs, including owned first
results across a second child and a caller retaining an owned String. Three
paired rounds give:

| Kernel | Source31 | Earlier combined | Table01 |
|---|---:|---:|---:|
| tree-bitonic |567ms|466ms|358ms|
| expression128 |487ms|389ms|163ms|
| list-pipeline128 |711ms|305ms|305ms|

All36 output/count observations pass. Against the earlier combined candidate,
these three points improve31.47% geometrically; versus31 they are2.226× faster.
They remain5.054× upstream geometrically. Expression is3.075× upstream, so
neither that program nor the corpus has reached parity. The unchanged list
control and independent ownership outputs constrain the broader rewrite.

Source SHA256 `827533980d1a42b92f531f880d6c1968992a5069105f93d803c532fe77b66e54`.
Evidence beneath `selfhost/build`: `phase114/table-admission01`,
`phase114/table-inspect01`, `phase113/p114-table-qualification01-jobs`,
`phase112/p114-table-screen01-measure`. The complete inspect/control/acquire/
measure guard takes64.465s. No full image or45-wide claim follows from this gate.

Next cheap ablations: expose this table's pop/get operations through the already
qualified shared templates; test table-first selection as a possible path to
retiring the two narrower region planners. Keep both separate from this frozen
result. Broader constructor destinations/fusion remain unimplemented.
