# Fast development of the Bend compiler

Use the pinned TypeScript compiler to check/build edited Bend code during normal
development. Both it and the resulting executable run the actual Bend compiler
sources; a full self-hosting fixed point is a separate milestone. Recent local
measurements built the complete checked bootstrap in 21 seconds and ran all 19
component groups in another 37 seconds. Times depend on hardware and workload.

The [rapid experiment report](../implementation/phase1/rapid_performance_experiments.md)
records successful changes, rejected hypotheses, raw timings and correctness
boundaries. The [compiler guide](BEND-IN-BEND.md) explains artifacts and full
validation. Commands below run from `selfhost/`, using Node 24 and the pinned
upstream checkout at `.bootstrap/upstream`.

## Check a small component first

For index changes, assemble just the four required compiler modules and compile
them with full upstream checking:

```sh
node tools/performance/rapid/index-component.mjs . build/index-dev
BEND_UPSTREAM="$PWD/.bootstrap/upstream" node --stack-size=4096 \
  tools/stage0-library.mjs build/index-dev/component.bend build/index-dev/api.mjs \
  lookup book_cached book_context book_put index_hash index_set index_find missing
node --stack-size=4096 tools/performance/rapid/persistent-index.test.mjs \
  build/index-dev/api.mjs build/index-dev/control.mjs
```

This checks duplicates, collisions, persistent old versions, missing names,
declaration order and cached bounds. Set `RAPID_INDEX_BENCH=1` on the test command
to measure construction, lookup, replacement and new-name insertion separately.
Use a fresh output directory for each source snapshot.

## Test Bend-generated code without rebuilding the compiler

Compile the component through the existing Bend compiler's JS backend, then
replace only its module workers in a disposable compiler copy:

```sh
BEND_TYPED_API="$PWD/dist/phase1/bootstrap-api.mjs" \
  node --stack-size=4096 cli.mjs build/index-dev/component.bend --library \
  -o build/index-dev/self-emitted.mjs
node tools/performance/rapid/component-capsule.mjs \
  dist/phase1/selfhost-api.mjs build/index-dev/self-emitted.mjs \
  build/index-dev/index.bend build/index-dev/capsule.mjs
node --stack-size=4096 tools/performance/rapid/persistent-index.test.mjs \
  build/index-dev/capsule.mjs dist/phase1/selfhost-api.mjs
```

The capsule tool checks constructor representation, generated dependencies and
worker coverage. Independent modules may be combined; overlapping replacements
are rejected. This is an experiment artifact, not a complete compiler rebuild or
fixed-point proof. Match component semantics against a frozen control before
benchmarking representative programs with checking enabled.

## Measure, then integrate

Use `tools/performance/compare.py` with explicit artifact paths, cache policy,
three initially rotating fresh-process repetitions and a reserved physical CPU.
Keep imports, compilation and generated-program execution distinguishable. Run
microbenchmarks to identify causes, then verify the gain in an entire compilation.
Do not multiply independent microbenchmark speedups into a projected total.

`tools/performance/rapid/prepare.mjs` reproduces the original diagnostic four-cell
experiments; its Map and cursor implementations are hypothesis probes, not the
production compiler. The integrated compressed index and ASCII lexer helpers
remain Bend source under `src/core/index.bend` and `src/front/lexer.bend`.

After a useful change passes focused comparisons, build a complete API with
`tools/typed-driver.mjs --bootstrap`, run the component suite, then freeze a
candidate for full self-emission and corpus validation. Keep that long run on
separate cores. Reserve/release workers between fixture groups so a new experiment
never pauses a test in the middle of its timeout window.
