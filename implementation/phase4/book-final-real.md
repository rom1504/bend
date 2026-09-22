# Actual-book canonicalization experiment

The guarded indexed helper improves canonicalization of the real parsed compiler book, while retaining exact results. This measures one compiler component, not total compilation or fixed-point time.

The immutable compiler source (SHA-256 `936266643e95973709bac4b567289c5792decadbb3297f90018ed5052582d772`) was parsed and loaded through the frozen B1 host with its normal validated Base seed. Source parsing took 15.771 s and graph loading 24.372 s; both are excluded from helper timings. Existing Base cache validation/read took 86 ms. No whole-book checker or code generator was repeated. The source identity comes from the completed baseline, and the candidate helper comes from the fully checked overlay4 API `a312d55c26846c6720e962f0baf4349468326ba40ae952f6467578d73be4dc25`.

The loaded compiler book contains 3,212 definition events and Base contains 479. The control exposes the original frozen B1 `driver_final` function by adding a single `run_lib` export to an exact copy of its API; its algorithm is unchanged. Candidate legacy and fast results both match that original function. Three alternating repetitions use the same immutable input book, Node v24.18.0, CPU 3, 4 MiB stack and 4 GiB heap. Result consumption/hash checking is outside each clock, equally for both variants. Inputs are checked for mutation and all artifact hashes are unchanged.

| Image / dataset | Legacy median | Guarded median | Component speedup |
| --- | ---: | ---: | ---: |
| checked-B1/Base | 64.81 ms | 45.53 ms | 1.42× |
| checked-B1/compiler | 2151.03 ms | 114.75 ms | 18.74× |
| H-component/Base | 170.91 ms | 122.06 ms | 1.40× |

The H component receives Base after a single positional ABI conversion outside the clocks. Its output is decoded and checked outside the clocks. Actual Base benefits from the 256-entry cutoff, even though a synthetic 256-entry H case with different name lengths regressed. This supports the candidate on these real datasets without establishing that 256 is optimal for every book.

The compiler result SHA-256 is `309d3eb7b6e569adc1994ec60dce2c87b53288c20a8fd33a6e2459fed836e24a`; the Base result is `5d38c53f0d0aa417fb3b5ed96c335cc7a6ce7c422fb54c6604e9224f11dc129a`. These hash serialized ordered definition arrays, including all fields and nested terms; they do not hash emitted code. The [complete report](evidence/book-final-real2.json) records phases, every sample, input identities and the separate unguarded H comparison.

The first harness attempt assumed the baseline API exported `driver_final`, and failed before any timing sample. Its partial report, error and exact consumed tool source are preserved as `book-final-real.*` and `book-final-real-failed-tool.mjs` in the evidence directory. The corrected attempt adds only the explicit control export described above.

Replay `selfhost/tools/performance/phase4/book-final-real.mjs CONFIG NEW_REPORT` under the same `taskset` and Node resource flags. The [configuration](evidence/book-final-real-config.json) identifies the frozen baseline, checked overlay report, canonical Base and both actual H components.
