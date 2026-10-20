# Product-compatible runtime counters

`prepare-products.py` invokes the original Phase112 source instrumentation with
heap/RC hooks, then appends the exact qualified `p113_rt_array_pair` helper and
header. It authenticates the production source and build receipts and checks
that removing all recorded diagnostics recovers the complete qualified
production translation unit byte for byte. It does not transform program
sources, QBE, runtime algorithms, counter names, output labels or parser rules.

Prepare source only:

```sh
python3 -B selfhost/tools/performance/phase113/profile/prepare-products.py \
  --out selfhost/build/phase113/profile-products-source01
```

Defaults bind `runtime-products01` and `runtime-products-build01/report.json`.
Fresh source/build locations may be supplied explicitly with
`--production-source` and `--production-build`. Preparation does not compile
or execute anything.

Use `bench/prepare-counter-plan.py` for each exact current-six binding:

```sh
python3 -B selfhost/tools/performance/phase113/bench/prepare-counter-plan.py \
  --binding CANDIDATE_BINDING.json --out FRESH_COUNTER_PLAN.json
```

Root runs each plan serially through the unchanged counter runner:

```sh
python3 -B selfhost/tools/performance/phase112/profile/run.py \
  --plan FRESH_COUNTER_PLAN.json \
  --runtime-source selfhost/build/phase113/profile-products-source01 \
  --out selfhost/build/phase112/p113-ROLE-counters01 --budget-seconds 60
```

Use the same additive instrumented runtime for the four requested roles:
facts-N2, scalar08, enhanced09 and products11. Existing bindings are respectively
`phase113/bench/baseline-binding01.json`,
`selfhost/build/phase112/p113-scalar-binding08.json`,
`selfhost/build/phase112/p113-enhanced-binding09.json`, and the completed
products11 binding when available. The old runner requires six cases and
output directories below `selfhost/build/phase112`; its independent counter
control runs before product observations. It checks complete expected results,
one successful repetition and zero warmups for every product. A workload is
therefore evaluated twice, once for initial output and once in the loop.

Prepared plans are `bench/baseline-counter-plan01.json`,
`bench/scalar08-counter-plan01.json` and `bench/enhanced09-counter-plan01.json`.
Prepare the fourth only after products11 has a complete six-product binding.

The new helper reaches the same `native_array_get`, `native_array_swap` and
`blk_copy` definitions. Their calls into the existing instrumented heap and RC
functions retain the same counters. The helper itself gets no fabricated
`rt_op`, public-call or operation histogram entry: a drop in those counters
means a generic entry was bypassed, not that the logical array work vanished.
Global frame/heap/RC counts can be compared; nested helper counts overlap.
FID histograms retain the current runtime dispatcher context and may attribute
a direct callee's work to its caller or entry segment.

The unchanged metadata field `sourceSha256` identifies the runtime04 prefix.
The extended manifest separately pins `productionSource`, the qualified
production object, the additive source/header, and every complete instrumented
output. `exactProductionInverseVerified` authenticates the complete production
translation unit. Do not describe the metadata prefix hash as the hash of the
whole additive runtime.

The production helper's earlier qualification is not a substitute for running
the instrumented independent counter control and product output checks. No
instrumented timing is a performance result. This preparation adds neither
parallel/GPU qualification nor a new operation counter.
