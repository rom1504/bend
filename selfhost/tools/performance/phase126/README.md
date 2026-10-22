# Phase126 bounded acquisition loop

`prepare.py` derives a fresh immutable declaration overlay from the selected,
native-qualified Phase125 compiler. It does no semantic lowering. Every parent
replacement and repeated module declaration must be named explicitly. New
lowering and private-emitter declarations are permitted; the original N111,
direct and array verifier gates and checked-request entry cannot be changed.
The source manifest records exact modules, snapshots, parent source/API/runtime,
and the protected declaration inventory. A prepared source is not yet checked.

All compiler, executable and timing commands below belong to the root's serial
CPU3 lane. Use a new `trial01` name for every attempt, including failed attempts.
Run from the repository root. Module paths and replacement names are examples;
supply the actual finite inventory for the intended overlay.

```sh
python3 -B selfhost/tools/performance/phase126/prepare.py \
  --out selfhost/build/phase126/trial01-source \
  --module selfhost/tools/performance/phase126/typed/MODULE.bend \
  --overrides REPLACED_DECLARATION

python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase126/trial01-api-guard \
  --seconds 90 --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase111/check-api.py \
  --source selfhost/build/phase126/trial01-source/compiler.bend \
  --out selfhost/build/phase111/p126-trial01-api \
  p88_cache_prepare p86_prepare p86_plan p111_runtime_admission \
  p111_emit_admitted p111_compile_source

python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase126/trial01-emit-guard \
  --seconds 180 --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  env P118_RUNTIME_REPORT=selfhost/build/phase125/runtime-verified01/report.json \
  selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase118/emit-integrated.mjs \
  selfhost/build/phase111/p126-trial01-api/report.json \
  selfhost/build/phase126/trial01-source/manifest.json \
  selfhost/build/phase118/p126-trial01-emit \
  variation-ray-active-256-2240 coverage-numeric-recurrence-1024

python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase126/trial01-screen-guard \
  --seconds 180 --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase126/screen.py \
  --emission selfhost/build/phase118/p126-trial01-emit/report.json \
  --out selfhost/build/phase126/trial01-screen --label trial01 --rounds 3 --scale 4
```

Add finite control exports to API acquisition when needed. Add `raytrace` to the
same emission command for an unrelated existing numeric family. The integrated
emitter retains checked source preparation, runtime admission and independent
original graph verification. Set `P118_RUNTIME_REPORT` explicitly: its default
is an older runtime. The selected Phase125 runtime object is
`runtime-verified01/runtime.o`, SHA256
`561f2ac7c37953acb5ab6b1aa8b450b86c059c07dd1b20ecc480a79176195be7`.

`screen.py` is the Phase125 screen with only Phase126 output names and the
selected Phase125 baseline changed. It retains the Phase123 aligned assembler
builder, original45 sources, complete output/count oracle, fixed repetition
profile, pinned upstream products and rotating measurement order. The baseline
is the candidate role in `phase125/broad-screen06/report.json`. These small
screens do not qualify a native compiler image or establish broad parity.

`tooling/dedup.py` is the separately authorized disk operation: it examines only
frozen Phase125 artifacts and matching Phase118/111 `p125-*` directories,
requires both SHA256 and byte equality, and atomically replaces duplicate paths
with hardlinks. It keeps all original paths and bytes. Never mutate either name
of a hardlinked frozen artifact. `--apply` is explicit; default writes a plan.
The first authorized run is recorded in
`selfhost/build/phase126/tooling-dedup01/report.json`.

No compiler or target was run while preparing these tools. Only Python syntax,
in-memory declaration composition/refusal and disk byte identity were checked.
