# Targeted Phase118 profile refresh

This tooling executes unchanged authenticated programs. It does not compile new
images, optimize programs, change benchmark sources or alter installed selection.
See the [design](../../../../design/phase119/profile-refresh.md) and
[results](../../../../implementation/phase119/README.md).

`refresh.py freeze` creates `selfhost/build/phase119/manifest01.json` once. It
authenticates the Phase118 selection, runtime, exact safe03/float01 QBE bridge,
individual build receipts and original Phase116 C products. Six workloads are
fixed before sampling: scalar, active ray, lexer, tree, list and map. A frozen
ordinary lexer request binds each native compiler to its own full-QBE oracle.

Run the following serially, with fresh output directories:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase119/NEW-clean-guard --seconds 180 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase119/refresh.py clean \
  --out selfhost/build/phase119/NEW-clean

python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase119/NEW-native-guard --seconds 360 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase119/refresh.py native \
  --out selfhost/build/phase119/NEW-native

python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase119/NEW-compiler-guard --seconds 120 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase119/refresh.py compiler \
  --out selfhost/build/phase119/NEW-compiler
```

The native mode intentionally uses retained `clean01` medians only to scale
sampling iterations to about7s. For an independent future campaign, version the
driver to bind its own clean receipt explicitly; never replace `clean01`.
All three roles use identical original source/arguments and complete-result
checks, four times the original clean repetitions and32 warmups. Profiles vary
the repetition count, use8/13ms periods, and never contribute speed samples.

`summarize.py` replays all102 complete-output checks, recomputes all44 sample
analyses and records exact identities. Its libc copy/fill ranges are explicitly
restricted to the authenticated local libc, and the corresponding disassembly is
saved. Neither those ranges nor physical function leaves identify callers or
allocation counts. Compiler samples pool four captures per image; individual
requests are too short for500 samples each. Program pairs exceed500 pooled samples.

Existing JavaScript captures remain historical Phase116 evidence. No fresh JS
timing claim or full45 compiler/runtime score follows from this focused refresh.
Machine boundaries and compiler generations differ across backends; do not call
the entire gap a QBE optimizer deficit.
