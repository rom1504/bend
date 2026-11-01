# Typed concat event extension

`concat_v1` retains the measured extension's seven additive counters: attempts,
visited spine nodes, empty successes, splice successes, static-term refusals,
shared-reference refusals and static-target refusals. Existing 16 channels and
the `bend-native-dispatch-events-v1` format remain unchanged.

Prepare a fresh diagnostic runtime offline:

```sh
python3 -B selfhost/tools/profiler/runtime.py \
  --manifest /path/to/exact-runtime-manifest.json \
  --out selfhost/build/my-profile/runtime --concat-v1
```

The normal manifest must pin the runtime, exactly its quoted headers and any
retained program object. A unique compatible `p125_rt_concat_typed` body and each
expected hook are required. Reversing the complete hook list recovers the input;
unknown runtime shapes and repeated instrumentation are refused. The generated
`expected-control.json` preserves the independent ABI fixture's old counts and
adds seven zero columns. This does **not** qualify the new positive branches.

Use `build-runtime.py`, then `check-runtime.py --expected` with that generated
expectation, under one outer resource guard. Run a separately frozen workload
with `freeze.py`/`run.py` to establish complete ordinary stdout/stderr. The generic
counter attribution tool already accepts the extended counter names.

Analyze saved events without executing a target:

```sh
python3 -B selfhost/tools/profiler/concat_v1.py \
  --events /path/to/events.json --out /path/to/fresh-summary.json
```

The summary checks complete nonoverflowed counts, exact channel order, unique
FIDs, storage dimensions and per-FID outcome conservation. Zero attempts yield
no ratio. It makes no timing or program-output claim: node visits are not
allocation counts, and invocation-wide events are not timed-kernel durations.
Positive hooks retain their source-audited status pending a dedicated native
fixture. `stages_v1` remains a separate unchanged protocol.
