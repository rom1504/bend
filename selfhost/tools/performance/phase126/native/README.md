# Phase126 native qualification adapter

Preparation only. No native/compiler target, installation, or promotion is
performed by these scripts. `plan.py` changes Phase125 output paths and tag
validation to Phase126, explicitly retaining the frozen Phase125 aligned
comparison/coverage/build adapters and their contract kind. Its eight jobs,
source-contract replay, original checker/verifier, independent outputs, Base,
cache, and assembler policy are unchanged.

Freeze the final source and checked API first. The API must export
`p88_cache_prepare`, `p86_prepare`, `p86_plan`, `p111_runtime_admission`,
`p111_emit_admitted`, and `p111_compile_source`.

```sh
python3 -B selfhost/tools/performance/phase126/native/rebind-abi.py \
  --source-manifest FINAL_SOURCE_MANIFEST --api-report FINAL_API_REPORT \
  --runtime-report selfhost/build/phase125/runtime-verified01/report.json \
  --out selfhost/build/phase126/final-native-abi01.json

python3 -B selfhost/tools/performance/phase126/native/plan.py prepare \
  --source FINAL_COMPILER_BEND --api FINAL_API_MJS \
  --runtime selfhost/build/phase125/runtime-verified01/runtime.o \
  --abi-receipt selfhost/build/phase126/final-native-abi01.json \
  --tag p126-native01 --rss-mib 6144 \
  --out selfhost/build/phase126/native01-plan.json
```

Only root executes the resulting `rootGuardCommand` array. It authenticates the
plan, emits hosted QBE, builds N1, checks focused19, has N1 check/compile the same
source and builds N2, compares raw hosted/native QBE, then checks N2 focused19
and original full45. Every build uses the Phase123 aligned assembler policy.
There is no N2 self-emission, ELF fixed-point, or installed-image claim.

The new ABI receipt retains the old receipt as an immutable authority. It
authenticates the selected source/runtime lineage; replays the exact source
composition/native-entry contract; compares all 12 original authority
declarations byte-for-byte; keeps the same nine additional runtime imports;
and compares the original verifier declarations. It binds the new checked
source and API rather than replacing the old receipt's source pin.

The optional `sqrt` call requires the exact reviewed F32→F64→double `sqrt`→F32
projection and its dispatch declarations. The separately pinned low-word
transport overlay may replace only the two dispatch declarations; the sqrt
body and result classification remain exact. The unchanged runtime already
implements this double projection and the aligned builder links libm. New
literal QBE symbols other than this admitted `$sqrt`, and changes to runtime
symbol spellings, are refused. These spelling checks supplement the source
and declaration gates; they are not a general compiler proof or link-based
ABI inference. Arbitrary raw reflected IR is outside this receipt's scope.

Data-only validation on checked `typed-source05` passes in
`tooling-native-rebind-smoke02.json` and `tooling-native-plan-smoke01.json`.
The first receipt attempt refused the intentional low-word dispatch overlay
(`Changed sqrt projection: p114so_group_call`); it produced no receipt. The
repair admits only that exact pinned overlay. All old receipts remain intact.
These smoke artifacts do not select typed-source05 or qualify its native image.

The default qualification bound is 4020 seconds (67 minutes), with 6 GiB RSS,
16 GiB available memory, 128 MiB per file, and CPU3. Phase125 took 1353.10
seconds and peaked at 5.159 GiB. Reserve approximately 450–550 MiB new disk
space; see [validation recipes](../validation-recipes.md) for the measured
footprint and exact dedup constraints. Do not silently relax a failing limit.
