These files record the JavaScript emitter optimizations and their validation.
The production emitter already includes both changes.

- `lexical.patch` records the change from baseline emitter SHA-256
  `c20e63d4f9016c488acbef1de97f893fb3eb0f7a2536f0e45d505d62401c88dd`
  to lexical emitter `0683269eb4311f572032cea603ef3d38bbcdc84b50c88bc3e83e3a214d3c01b4`.
- `lexical-benchmark.json` records identical parsed output and the ABBA parser
  timings, with input and generated-library hashes. Paths identify the original
  run; use the benchmark scripts in the parent directory to reproduce it.
- `deep-closures.patch` records the subsequent generic closure-factory change,
  producing emitter `49c0dc52341bf81c34c72945499003421e88c4af52f31d84357d0b1c899f3a56`.
- `deep-closures-report.json` records the checked 500-row upstream regression,
  14 backend cases, 13 byte-equivalent ordinary programs, and foreign-call tests.

The patches are historical comparisons, not patches to apply to current source.

`allocation-performance.json` records the subsequent runtime allocation and
leading-lambda cache benchmarks, with semantic validation. `runtime-fast.patch`
and `leading-lambda-cache.patch` preserve the source changes; both are already
in production. Warmed ABBA input/output hashes make the performance comparison
reproducible using `BEND_BENCHMARK_WARMUPS=2`.
