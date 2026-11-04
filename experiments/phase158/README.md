# Phase158 — reproduce the published self-compilation operation

[Result](../../implementation/phase158/README.md) ·
[Publication/source audit](published-method.md) ·
[Independent audit](independent-plan.md) ·
[Design](../../design/phase158/README.md).

The historical publication pin is bendc
`9c54842eb5756803af599583ca49870d1e09186a`; Base/effects are official Bend2.0.32,
commit `573002f01ec6c52416d44489543f69a9625facf8`. Exact inputs, generated seed,
local executable, raw outputs and receipts are in
`implementation/phase158/evidence/phase158.tar.gz`, with a fully verified member
manifest in `capsule.json`. Members are repository-relative. Restore only into
a fresh checkout or staging directory; do not overwrite active artifacts.
The capsule also preserves acquired-but-unused current56/2.0.34 source inputs;
no result is attributed to those versions.

External prerequisites are the pinned Clang toolchain and Bun, identified in
`seed01-guard/process.json` and `upstream-check02-guard/process.json`. They are
not bundled. The local x86 seed executable is included as measured evidence;
rebuilding it with another toolchain changes executable identity. The exact
seed command is in `seed01/report.json`. The public historical Makefile uses
Clang `-O2 -w`, the monolithic runtime header, `-lm -lpthread`.

The executed sampler clears inherited `BEND_*`, `LD_PRELOAD` and `LD_AUDIT`,
then sets `BEND_NO_FREE=1`. It pins inputs before execution and authenticates them
afterward. Output equality is checked outside each timed child. Every call's
command, wall time, CPU time, peak RSS and full output are retained.

From the repository root, with restored inputs and a **fresh** output directory:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase158/replay01-guard \
  --run-root selfhost/build/phase158/replay01 \
  --disk-mib 64 --seconds 230 --rss-mib 2048 --available-mib 16384 --cpu 3 -- \
  python3 -B experiments/phase158/tools/self-compile.py \
  --out selfhost/build/phase158/replay01 \
  --modes no-check check-only checked --rounds 9 --check-rounds 5 \
  --check-oracle selfhost/build/phase158/check-oracle.json \
  --seconds 25 --budget 220 --workers 1
```

The observed `timing01` receipt records the original invocation, not this replay
name. If relocated, rebind absolute paths in restored pin receipts only after
verifying their bytes against the capsule; never silently accept a changed
oracle. Close a finished replay with the maintained `close.py` workflow.

The separate eight-worker cohort uses `--cpu 0-7`, `--workers 8`, five rounds
of `check-only checked`, 24MiB disk budget, 120s guard and 110s sampler budget.
Do not merge it with the serial cohort or claim it was interleaved against the
serial runs. No simultaneous target jobs were launched.

The checker oracle is established by the exact upstream2.0.32 TypeScript
checker via pinned Bun, independently from bendc. Its expected exit1 and report
of24 foreign/unsafe dependencies are explicit. This is not an all-proofs-pass
result. A failed initial entry-path lookup is preserved alongside the corrected
run. Both complete source files and effect dependencies are authenticated.

`tools/command.py` and `tools/self-compile.py` are experiment orchestration,
using the maintained process recorder, not an alternative compiler. Original
method versions remain in `selfhost/build/phase158/methods/`; later method
changes do not rewrite earlier acquisition or pilot evidence. `tools/seal.py`
packages and reopens all evidence without running compilers.
