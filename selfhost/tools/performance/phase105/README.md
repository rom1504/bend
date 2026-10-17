# Current native compiler comparison

See [the protocol](../../../../docs/self_hosted/NATIVE_COMPILER_COMPARISON.md)
and [frozen experiment plan](../../../../experiments/phase105/P105-001-current-compilation.md).
This is supervised measurement tooling, not a compiler or public CLI dependency.

From the repository root, use fresh output directories:

```sh
python3 -B selfhost/tools/performance/phase105/compare.py --corpus screen --rounds 4 --out selfhost/build/phase105/screen01
python3 -B selfhost/tools/performance/phase105/compare.py --corpus broad45 --rounds 2 --out selfhost/build/phase105/broad01
python3 -B selfhost/tools/performance/phase105/compare.py --corpus self --rounds 2 --modes prepared --out selfhost/build/phase105/self-prepared01
python3 -B selfhost/tools/performance/phase105/compare.py --corpus self --rounds 1 --modes live --out selfhost/build/phase105/self-live01
```

`--check-only` authenticates source/images/assets/oracles without running targets.
The default modes are `prepared,live`; upstream loads source Base in both.
`processMs` is the precise child clock, including output and exit. `guardWallMs`
retains supervisor polling; `requestMs` has different boundaries across native
and TypeScript and must not be used for an algorithm-speed ratio.

The runner retains raw logs, commands, complete output paths, hashes, all samples,
random seed/order, memory and summaries. Newly generated equal C outputs are
hard-linked after full-byte validation; failed outputs remain untouched. Existing
images/oracles are read-only. Broad upstream acquisition is excluded from timing
aggregates. Compiler source, native selection and runtime are unchanged.

Reports authenticate current candidate04 selection rather than old Phase92
images. This does not benchmark the distinct Phase103 public CLI. A later
selection requires deliberately updating the source/oracle bindings.

After the broad campaign, validate six diverse emitted products with matched
Clang O2 builds and complete-output checks:

```sh
python3 -B selfhost/tools/performance/phase105/products.py --comparison selfhost/build/phase105/broad01/report.json --out selfhost/build/phase105/products01
```

Identical native B1/B2 C needs only one build per case. Upstream gets its own
build. These single executions check correctness; their times are not a fresh
generated-program performance benchmark. Clang durations are separate, single
build observations. `seal.py` preserves completed runs, including full output
bytes, in a verified content-addressed archive without duplicating identical C.
