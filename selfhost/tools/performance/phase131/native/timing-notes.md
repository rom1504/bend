# Phase131 experimental native request comparisons

`timing-plan.py` executes no targets. It binds the checked Phase131 admission to
the actual qualified-Phase130 acquisition, aligned N1 build and completed
focused19 gate. Both native roles use the same authenticated compact Base.
The original three sources, independent outputs, toolchain, build flags, child
timers and rotated three-round order come from the frozen Phase130 block.

The runner is **unchanged** `phase130/timing-run.py`. These manifests explicitly
set `nativeQualified=false`, `unqualified=true`, `researchOnly=true`. The baseline
role retains its actual qualified status; the candidate role is experimental.
Native self-reproduction and ordinary45 qualification are separate receipts.

Prepared first block:

```sh
python3 -B selfhost/tools/performance/phase131/native/timing-plan.py \
  --comparison parent-n1 \
  --admission selfhost/build/phase131/combined-fast-admission01.json \
  --n1-emission selfhost/build/phase130/p131-fast-acquire01/report.json \
  --n1-build selfhost/build/phase111/p131-fast-native01-n1/report.json \
  --n1-focused selfhost/build/phase111/p131-fast-native01-n1-focused/report.json \
  --out selfhost/build/phase131/fast-parent-timing01.json \
  --tag p131-fast-parent-timing01
```

The manifest and sibling `-jobs.json` were produced successfully. Metadata-only
runner preflight passed at
`selfhost/build/phase112/p131-fast-parent-timing01-check/report.json`, with
`targetJobs=0`. Existing outputs are immutable: use new names for another block.

The coordinator can execute the27-observation block on its serial CPU3 lane:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase131/fast-parent-timing01-guard \
  --seconds 300 --rss-mib 2048 --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase130/timing-run.py \
  --manifest selfhost/build/phase131/fast-parent-timing01.json \
  --out selfhost/build/phase112/p131-fast-parent-timing01 \
  --rounds 3 --modes cache
```

For a later N1/N2 block, use the same planner with `--comparison n1-n2`, the
same admission/N1 receipts, and additional `--n2-emission`, `--n2-build` and
`--n2-focused` receipts. The emission must identify N1 as producer, the exact
same compiler source, and complete raw QBE equality to the original N0 product.
Use a new manifest and `--tag`. This block remains experimental here even if a
separate final binder subsequently qualifies it; do not silently rewrite labels
or pool it with the earlier parent/candidate block.

Report request latency separately from machine-build latency. The sum excludes
Python input authentication/reporting and generated-program execution. Native
prepared Base and cached runtime differ from upstream source Base and complete
C/Clang runtime compilation. Each program execution checks the independent full
output once; it is **not** a compiled-program runtime benchmark. Legacy role keys
`phase111` and `phase112` mean left/right comparison roles, documented explicitly
in each manifest, rather than historical compiler generations.
