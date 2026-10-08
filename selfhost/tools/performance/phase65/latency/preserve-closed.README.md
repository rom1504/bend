# Closed predecessor preservation

This exact Phase64 tool successor verifies all15,922 files in the closed Phase64
raw inventory against its published manifest, rehashes the single published
archive, and checks all110 Phase65 inherited protected files. It records added,
missing, changed and symbolic-link inputs honestly. Derivation and source patch
are adjacent; no previous file is written or extracted.

Only after root's final closure signal, run once on CPU0:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase65/latency/preserve-closed.py
```

It creates identical fresh receipts at
`selfhost/build/phase65/final-state10/closed-evidence-preservation.json` and
`implementation/phase65/evidence/closed-evidence-preservation.json`.
Either existing output refuses invocation. Preparation checked syntax only;
no closed raw rehash or preservation account has been invoked.
