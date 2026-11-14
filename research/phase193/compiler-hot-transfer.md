# Actual compiler-helper transfer before another compiler image

The prepared input at
`selfhost/build/phase193/compiler-hot-source01/compiler.bend` is 17,803 bytes,
50 declarations, SHA256
`78ea3e0d626fc770db1810ab07f90eed9f6bc4cc2505f39f6d7de97f5436b8c8`.
`prepare-compiler-hot.py` uses the retained Phase147 lexical closure extractor
against the exact qualified Phase192 compiler source. It copies reachable
declarations byte-for-byte, adds a small explicit workload/main, and reuses
Phase163's full-field digest. No compiler algorithm or helper body is rewritten.
Its metadata verifies that `p111v_put`, `p111v_get`, `p131i_insert`, `index_leaf`,
`index_remove`, `index_hash`, `dn` and `atom` are in the selected closure.

Each round performs six real compiler-index insertions and two overwrites,
including the real `costarring`/`liquid` FNV collision. It then reads ten complete
records: values from both a retained pre-update alias and the updated tree,
ordinary hits, empty/Unicode names, and late-mismatch misses. Width/capacity
fields change with the round index. The existing consumer visits every returned
field and folds all three digest words, including the record count. Creation,
lookup, persistent update, aliases, consumption and reclamation remain charged.
This gives the missing public/ready-tail routes real callers, unlike the earlier
lookup-only Phase166 fixture.

`compiler-hot-oracle.py` specifies ten literal expected result records, without
calling lookup, hashing keys, building trees, or asking either compiler for an
answer. It reuses only Phase166's independent serialization/mixing functions.
The prepared default is 1,000 rounds and exact stdout `2885372021\n`.
`expected-values.json` independently lists every KDef/KTerm field at i=0,1,7;
the runtime scalar oracle traverses the same specified fields. These are finite
result contracts, not a compiler-correctness proof. The original helpers retain
their existing `@unsafe` assumptions.

Prepare another scale offline with `prepare-compiler-hot.py --rounds N --out
FRESH`. The first runtime admission should measure the 1,000-round point and
keep the program below about one second per invocation; that duration is a
planning target, not a measured claim. Do not replace an observed failure or
compare different round counts between roles. Identical source and expected
output apply to the baseline and candidate APIs; a C role is optional and not
prepared here.

Root owns source checking and all emission/build/runtime jobs. First run the
ordinary independent source gate:

```sh
python3 -B selfhost/tests/phase193/job.py compiler-hot-check01 20 16 \
  selfhost/.assets/bin/bun selfhost/tools/build/check-source.mjs \
  --source selfhost/build/phase193/compiler-hot-source01/compiler.bend \
  --out selfhost/build/phase193/compiler-hot-check01
```

`emit-compiler-hot.mjs` is a small transport adapter because maintained
`request.py` deliberately refuses hosted x86 emission. It authenticates a
previously checked API and its preparation-owned Base binding, then submits the
fixture as ordinary user source through `p86_plan` and `p169np_plan`. It calls
the checked typed x86 pipeline and serializes its assembly/object outputs. It
does not add fixture definitions to the compiler API or reinterpret the fixture
as a compiler-source override. The same typed sequence supplies assembly for
inspection and the object for linking.

Baseline example (candidate uses its actual checked API and matching binding):

```sh
python3 -B selfhost/tests/phase193/job.py compiler-hot-base-emit01 60 32 \
  selfhost/.assets/bin/bun selfhost/tests/phase193/emit-compiler-hot.mjs \
  --api selfhost/build/phase192/selected-api01/report.json \
  --binding selfhost/build/phase192/selected-api-source01/base-binding.json \
  --source selfhost/build/phase193/compiler-hot-source01/manifest.json \
  --out selfhost/build/phase193/compiler-hot-base-emit01
python3 -B selfhost/tests/phase193/job.py compiler-hot-base-machine01 25 16 \
  python3 -B selfhost/tools/build/native.py \
  --assets selfhost/build/phase192/assets.json --target x86 --emit object \
  --ir selfhost/build/phase193/compiler-hot-base-emit01/program.o \
  --expected-stdout selfhost/build/phase193/compiler-hot-source01/expected.stdout \
  --seconds 20 --out selfhost/build/phase193/compiler-hot-base-machine01
```

The maintained native builder links the pinned common runtime and checks the
complete independent stdout. It does not independently verify empty stderr
through `--expected-stdout`; require empty `execute.stderr` too before timing.
Use the ordinary explicit current-runtime arguments for fresh-process timing:
`program +RTS --threads 1 --gpu off -RTS --RTS`. Compare both complete outputs
in every timing observation and keep alternating role order. The initial
native-build execution is an output/admission gate, not the paired timing result.
Inspect actual `p111` public wrappers, `p112w` ready calls and dispatcher paths
in each retained emitted object before attributing a runtime difference.

Preparation performed no compiler, emission, linker or target execution.
The independent oracle and lexical extraction ran successfully. Source and API
execution gates remain root-owned and pending at handoff. `node --check` was
unavailable in this shell; this is not reported as adapter syntax validation.

## Frozen clean kernel timing after root admission

Root built `compiler-hot-baseline01` and `compiler-hot-candidate01`, then
`compiler-hot-baseline-machine01` and `compiler-hot-candidate-machine01`.
Both completed native receipts pass the independent stdout gate, and the timing
planner separately verifies empty execution stderr. The admitted execute argv is
copied exactly from those receipts: `program +RTS --threads 1 --gpu off -RTS`.
No extra sentinel or workload argument is added to the frozen timing request.

`compiler-hot-timing-plan.py` prepares the maintained profiler's generic workload
schema without a sampler. Its `compiler-hot-timing-plan01` binds both exact
emitted objects, linked binaries, common runtime, checked API receipts, compiler
source snapshots, source fixture, independent oracle and all execution inputs.
Read-only profiler preflight passed 64 pinned inputs; no timing target was run
by preparation.

```sh
python3 -B selfhost/tests/phase193/job.py compiler-hot-timing01 20 16 \
  python3 -B selfhost/tools/profiler/run.py \
  --manifest selfhost/build/phase193/compiler-hot-timing-plan01/manifest.json \
  --out selfhost/build/phase193/compiler-hot-timing01 \
  --modes clean --rounds 20
python3 -B selfhost/tools/profiler/compare.py \
  --report selfhost/build/phase193/compiler-hot-timing01/report.json \
  --reference baseline \
  --out selfhost/build/phase193/compiler-hot-timing01/comparison.json
python3 -B selfhost/tools/profiler/render.py \
  --comparison selfhost/build/phase193/compiler-hot-timing01/comparison.json \
  --out selfhost/build/phase193/compiler-hot-timing01/summary.md
```

Twenty balanced AB/BA rounds give forty fresh processes, each checked against
the complete independent stdout and empty stderr. The one build-admission
observation was approximately 49ms baseline/45ms candidate; it is not a paired
timing claim. At that scale the expected child total is about two seconds under
a 20s/16MiB guard. Each child has a 2s timeout, so unexpected slowdown can exhaust
the whole guard; retain any incomplete evidence rather than selecting a subset.

This is **kernel runtime**, including creation/update/read/full-field digest and
process startup. It is neither compiler-request cost nor a CPU profile. No
sampling mode, allocation events or ownership attribution is enabled. Individual
45–50ms intervals remain sensitive to process startup, scheduling and OS-cache
effects; more repetitions balance position but do not remove those effects or
establish full-compiler transfer. Report raw wall/CPU samples and dispersion,
not just a percentage, and qualify any small observed difference accordingly.
