# Candidate profile: same full-source workload

Prepared metadata only. No target/build execution was performed by this setup.
The original `prepare-profile.py` and `profile-v2.py` remain unchanged. The new
`tools/candidate-profile.py` reuses their frozen metadata/build-plan operations.

The executing compiler is `native-candidate01/program`, SHA256 `c354b39c…`, from
3,161,409-byte candidate compiler source `74cd7de3…`. Its retained object is
`b8e33013…`; its own QBE is98,023,231 bytes, `91b67c06…`. These differ from the
**measured input**, which stays the original3,150,535-byte Phase170 source
`434edd1d…`. The independent output oracle stays97,488,970-byte Q3 `661b6266…`.
Do not accidentally profile the candidate compiling its larger own source.

`full-candidate01/report.json` already binds this image to that same workload
and exact output. The fresh clean whole-build comparison is188.619676s baseline
versus180.677191s candidate (4.21% less); it is a separate boundary from the
diagnostic compiler-only capture. New profiling is intended to locate remaining
work and candidate stage differences, not to remeasure that clean speed ratio.

The32 stage labels/intervals,32ms sampler, unwind table, runtime source/flags and
machine construction recipes are preserved. Every FID is derived anew from the
candidate QBE and bound against its actual ELF. All32 labels exist; execution
order/multiplicity and exact output remain mandatory gates after capture. New
helpers may move work across endpoints, so interpret interval differences using
the corresponding candidate source, not only matching labels. Unknown lexical
owners remain unknown.

Prepared:

- `selfhost/build/phase171/candidate-profile-prep01/ready.json`
- `candidate-profile-prep01/spec.json`
- `candidate-profile-prep01/build-plan.json`
- About22.51MB metadata, predominantly the owner map; no generated compiler or
  runtime binary. Build outputs are directed to the fresh, currently absent
  `candidate-profile-products01` root.

Root-owned guarded build, with both the build-report root and product root
declared to the retention guard:64MiB disk,2GiB RSS, CPU3,120s outer deadline,
128MiB per-file cap,16GiB available-memory floor, default5GiB disk reserve.

```sh
python3 -B experiments/phase171/tools/profile-v2.py build \
  --plan selfhost/build/phase171/candidate-profile-prep01/build-plan.json \
  --out selfhost/build/phase171/candidate-profile-build01
```

After successful build, this metadata-only step validates actual products and
creates the frozen same-input manifest:

```sh
python3 -B experiments/phase171/tools/candidate-profile.py manifests \
  --prep selfhost/build/phase171/candidate-profile-prep01 \
  --build-report selfhost/build/phase171/candidate-profile-build01/report.json \
  --out selfhost/build/phase171/candidate-profile-manifests01
```

Root-owned capture under a separate guard: fresh `candidate-profile-full01`,
160MiB disk,2GiB RSS, CPU3,330s outer deadline and the same remaining limits.
The profiler's internal workload deadline is300s, as for the original capture.

```sh
python3 -B selfhost/tools/profiler/run.py \
  --manifest selfhost/build/phase171/candidate-profile-manifests01/full-manifest.json \
  --out selfhost/build/phase171/candidate-profile-full01 \
  --modes sample --rounds 1 --periods-us 32000
```

Only after complete/passed/exact output and valid sample quality, derive clocks
offline; the observer authenticates the spec, ELF/FID mappings, outputs, sampling
and stage sidecar:

```sh
python3 -B selfhost/tools/profiler/stages_v1.py observe \
  --spec selfhost/build/phase171/candidate-profile-prep01/spec.json \
  --run selfhost/build/phase171/candidate-profile-full01/report.json --row 0 \
  --out selfhost/build/phase171/candidate-profile-stages01.json
```

Keep original and candidate diagnostics separate from clean timings. They sample
the same workload with the same instrumentation policy but are not repeated
balanced clean observations. There are no new allocation/event counts. An absent
required marker or failed output gate is a rejected capture, not permission to
infer a zero-cost stage or silently remove the marker.
