# Guarded scalar reassessment

The existing `rapid/native-primitives.mjs` transform remains a disposable experiment. It specializes only saturated non-tail calls to retained runtime primitives and preserves generic fallback for ordinary callee rebinding, code/arity/environment/bound-argument changes, partial calls and overapplication.

The current reassessment **does not justify production integration**. An exported retained primitive can have its `code` field replaced with a getter. The original public call reads that field three times; the guarded specialization reads it twice. A getter that throws on the third read makes the original call throw while the candidate returns a number. Identity and value comparisons alone do not prove that these ABI fields are ordinary data properties. A future proposal must either preserve that behavior or establish an explicit, compatible immutability contract; neither is implemented here.

`scalar-reassessment.mjs` retains this counterexample and separately measures ordinary-data workloads. It substitutes the exact current runtime bytes into a frozen proven self-emitted H, requiring the old runtime prefix to match byte-for-byte, then applies the existing scalar transform. This is an experimental copy, not a new self-host proof. A fully checked B1 compiles `tests/performance/scalar-loop.bend`; its Nat recursion is structurally decreasing while the measured live arithmetic is U32.

Run from `selfhost/`:

```sh
BEND_NATIVE_RUNTIME="$PWD/src/runtime.mjs" node tools/performance/rapid/native-primitives.test.mjs
node --stack-size=4096 --max-old-space-size=4096 tools/performance/phase3/scalar-reassessment.mjs CONFIG.json NEW_OUTPUT_DIRECTORY
```

Configuration paths resolve relative to the configuration file:

```json
{
  "cpu": 1,
  "rounds": 3,
  "iterations": 1000000,
  "h": "baseline/api/h.mjs",
  "oldRuntime": "baseline/src/runtime.mjs",
  "runtime": "../../src/runtime.mjs",
  "b1": "diagnostic-reuse-rebuild/api.mjs",
  "base": "../../.bootstrap/upstream/bend2/base.bend",
  "kernel": "../../tests/performance/scalar-loop.bend",
  "input": "../../tests/fixtures/tree.bend",
  "expectedStdout": "42\n"
}
```

The tool freezes host helpers and the worker, records API/runtime/tool/source identities, validates the B1 build report and source snapshots, and primes compiler-specific validated Base caches before timing. Optional `cacheSeedDirectory` imports previously prepared cache files with recorded identities; the normal host validation still verifies their compiler/Base/book hashes. Every sample uses a fresh Node process on the chosen CPU, with alternating order across three rounds. The checked scalar-loop checksum must match an independent arithmetic calculation; realistic tree compilations must retain byte-identical output and execute successfully.

The retained 2026-09-22 experiment measured median kernel time **1440.067 → 1024.635 ms (1.41×)** and tree compilation **2888.870 → 2695.607 ms (6.69% reduction)**. All twelve ordinary-data samples passed, alongside 8,400 primitive boundary comparisons. `productionEligible:false` remains the decisive result because the accessor counterexample fails equivalence. Process-wall measurements include startup, input hashing and report IO and are recorded separately.
