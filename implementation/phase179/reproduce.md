# Reproduce the checked self-build comparison

Run from the repository root. The experiment uses historical bendc commit
`9c54842eb5756803af599583ca49870d1e09186a`, Base2.0.32 commit
`573002f01ec6c52416d44489543f69a9625facf8`, and our Phase177 N1 with its own source.
The [Phase158 acquisition](../phase158/README.md) describes the historical inputs.
All exact paths, hashes, commands, environments and outputs are retained in
`evidence.tar.gz`, authenticated by `evidence-index.json`. Extract evidence only
into a separate empty directory. Large IR/assembly/object/binary artifacts remain
local; recipes and hashes are retained rather than committing another image.

Every command below goes through `selfhost/tests/phase179/job.py NAME SECONDS
DISK_MIB COMMAND...`. It supplies one CPU3 lane, a 2GiB aggregate RSS ceiling,
16GiB available-memory floor, 5GiB free-disk reserve, deadline, fresh artifact
root and retention closure. Never run measured compiler jobs concurrently.
Use fresh names/paths when reproducing; recorded outputs must not be overwritten.

## Historical bendc route

First acquire a copied seed and split runtime in a new isolated directory:

```sh
python3 -B selfhost/tests/phase179/job.py bendc-assets01 50 20 \
  python3 -B selfhost/tests/phase179/bendc.py prepare \
  --out selfhost/build/phase179/bendc-assets01 --seconds 40
```

Then run the actual checked `-o` CLI (the adapter does not reconstruct compilation
semantics). Its CC wrapper preserves the temporary C, times pinned Clang and
requires the existing split-runtime cache:

```sh
python3 -B selfhost/tests/phase179/job.py bendc-build01 110 80 \
  python3 -B selfhost/tests/phase179/bendc.py build \
  --prepared selfhost/build/phase179/bendc-assets01/report.json \
  --out selfhost/build/phase179/bendc-build01 --seconds 100
```

The source path is historical `bendc.bend`, loading its five imports. The actual
CLI checks Base and user source; no `--no-check`. It invokes Clang `-O2 -w` with
`-DBEND_RT_SPLIT`. `BEND_NO_FREE=1`, one worker and GPU off preserve the historical
measurement policy. The CC wrapper copies 2.8MB C before Clang; that and wrapper
startup are included in the full-build measurement. Original seed/runtime inputs
are never modified. The new compiler lives inside the run root.

## Our route and ordering

```sh
python3 -B selfhost/tests/phase179/job.py ours-build01 245 180 \
  python3 -B selfhost/tools/build/native.py \
  --assets selfhost/manifests/assets-native.json \
  --image selfhost/build/phase177/full-native-n1/program \
  --image-receipt selfhost/build/phase177/full-native-n1/image-binding.json \
  --host native --stage N1 --target qbe --mode cache \
  --source selfhost/build/phase177/full-source01/compiler.bend \
  --expected selfhost/build/phase177/full-native-n1/program.ssa \
  --output-stage N2 --out selfhost/build/phase179/ours-build01 --seconds 230
```

Our input is the executable's actual Phase177 source, not the older frozen
Phase170 benchmark or Phase178 cleanup. `--mode cache` reuses only authenticated
prepared Base here; all user-source checking/lowering and machine work is fresh.
The independent QBE oracle was emitted by Phase175 N2. QBE streams through a
bounded relay; no program IR or machine object is reused.

Repeat ours as `ours-build02`, then bendc as `bendc-build02`. The measured order is
bendc/ours/ours/bendc. Report two observations and their medians, not a confidence
interval. Runtime objects are reusable on both routes; filesystem caches are not
evicted. Different source programs, language revisions, backend abstractions and
generated-code quality remain explicit limitations.

## Separate serial diagnostic and rebuilt execution

Run the same our-image/source request using `selfhost/tools/build/request.py`
instead of `native.py`, omit `--output-stage`, set `--out` to `ours-emission01`
and keep the exact QBE oracle. Budget230s/150MiB, child215s. This measures actual
compiler execution without a concurrently running QBE child.

Then run `native.py --assets selfhost/manifests/assets-native.json --target qbe
--ir selfhost/build/phase179/ours-emission01/program.ssa --expected
selfhost/build/phase177/full-native-n1/program.ssa --out
selfhost/build/phase179/ours-machine01 --seconds 80`, under a90s/180MiB guard.
No source/image arguments on this machine-only replay. Do not substitute the sum
of these diagnostic runs for the independently timed complete streaming builds.

After timing, `bendc.py verify --prepared .../bendc-assets01/report.json --binary
.../bendc-build01/bendc --out .../bendc-rebuilt-check01 --seconds 30` re-emits the
entire checked seed. Run under a40s/20MiB guard.

For ours, invoke `native.py` with image `ours-build01/program`, receipt
`ours-build01/report.json`, stage N2, the same assets/cache policy, source
`selfhost/tests/consolidation/native-focused/nt-reverse.bend`, QBE oracle
`selfhost/build/phase177/native64-n1/00-nt-reverse/emission/program.ssa` and
`--expected-stdout selfhost/build/phase179/oracles01/nt-reverse.stdout`.
The stdout oracle comes from the prior independently qualified native64 fixture;
`oracles01/origin.json` records it. Budget35s/30MiB, child25s, fresh
`ours-rebuilt-check01`. These are bounded product checks, outside timed builds.

Finally run `selfhost/tests/phase179/summarize.py`, then
`selfhost/tests/phase179/seal-evidence.py`. The latter verifies archived receipts
and guard/retention closure; it never deletes artifacts. No installed promotion,
new broad conformance campaign, or cross-system runtime-quality claim follows.
