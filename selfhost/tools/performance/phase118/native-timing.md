# Native N1/N2 request and machine-build comparison

This plan executes no work by itself. The source-only preparer
`native-transport-plan.py` reuses the exact Phase112 transport runner and the
Phase114 three-source definitions. It creates a fresh manifest only after the
Phase118 qualification job sequence, raw hosted/native QBE comparison,
N1/N2 focused19 gates and N2 full45 gate have all completed successfully.
It authenticates their actual image/runtime pins rather than accepting filenames
as evidence of lineage. No existing plan, source or historical manifest changes.

The selected candidate is the safe03 native chain:

- N1: `selfhost/build/phase111/p118-native-safe03-n1/program`.
- N2: `selfhost/build/phase111/p118-native-safe03-self/build/program`.
- Runtime: `selfhost/build/phase118/runtime-extend01/runtime.o`.
- Qualification plan: `selfhost/build/phase118/native-safe03-plan.json`.

After its qualification guard finishes, root prepares the manifests and commands:

```sh
python3 -B selfhost/tools/performance/phase118/native-transport-plan.py \
  --plan selfhost/build/phase118/native-safe03-plan.json \
  --out selfhost/build/phase118/native-safe03-transport-manifest.json \
  --tag p118-native-safe03-transport --repeat-phase114
```

This is read/authenticate/write only; it launches no targets. It produces the
manifest plus `native-safe03-transport-manifest-jobs.json`. Run those two serial
timing jobs under the usual CPU3 guard:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase118/native-safe03-transport-guard \
  --seconds 420 --rss-mib 2048 --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase113/run-jobs.py \
    --plan selfhost/build/phase118/native-safe03-transport-manifest-jobs.json \
    --out selfhost/build/phase113/p118-native-safe03-transport-jobs
```

Each screen has a 180-second ceiling; the combined guard ceiling is deliberately
larger than the anticipated roughly three-minute campaign. The Phase118 completed result is linked from implementation/phase118/native-results.md.
A new invocation still needs fresh paths and produces a separate measurement. The runner keeps the original per-child 30-second limits.
All result paths must be fresh. The only expected outputs are complete checked
emissions, freshly built executables and their independent complete stdout.

The first screen compares Phase118 N1/N2 with pinned upstream. The second
repeats the exact Phase114 N1/N2/upstream screen contemporaneously. It retains
Phase114's own runtime for its machine builds. A mixed Phase114/118 manifest
would link both native products against the runner's single global runtime;
separate screens avoid that accidental policy change. Omit
`--repeat-phase114` only when explicitly accepting a historical comparison; do
not label historical Phase114 timings a contemporaneous measurement.

Outputs:

- `selfhost/build/phase112/p118-native-safe03-transport/report.json`.
- `selfhost/build/phase112/p118-native-safe03-transport-phase114/report.json`.

Both retain the original three unchanged one-shot source cases: lexer,
coverage-closures-256 and coverage-map-churn-128. Their complete expected stdout
is respectively `1822208108`, `33019` and `3714872484`, each plus LF. Each screen
has three rotated rounds, three roles and 27 correctness observations. Native
arguments remain one thread, GPU off, cache mode and the required `phase111`
protocol token; upstream remains commit
`059266225b77c8ca256ac6b25ee5c21449bab151` under pinned Bun 1.4.3.

Read the existing summary medians for `requestSeconds`,
`machineBuildSeconds` and `readyExecutableStageSumSeconds`, and their native /
upstream geometric ratios. Compare Phase118/Phase114 per-generation medians only
after examining upstream drift between the two screens. Retain all individual
samples and ranges. A one-shot correctness execution is not program-speed data.

Native requests include process startup, reads, authenticated prepared-Base
loading, source checking, integrated planning/verification/rendering and output
writes. Upstream loads/checks source Base and emits C. Native machine build sums
fresh QBE/as/link with cached runtime; upstream uses full C/Clang O2 construction.
Those preparation/format/runtime-build asymmetries remain explicit. API/image
acquisition, cache construction and semantic qualification are excluded, not
hidden inside either request clock. This is a configured workflow comparison,
not a same-IR backend throughput comparison.

## Hosted cost harness is ready

The checked parent entry API already exists at
`selfhost/build/phase111/p118-parent-entry-api01/report.json`. It matches exact
selected Phase117 source and exports all four required functions. Its API SHA256
is `85a37716957b80cc1c58dfbea681bc03ad926b0b0904bf4575aaf3964b92ad28`.
No new parent API acquisition is required.

For the earlier timed float01 candidate, the completed hosted-cost invocation is:

```sh
P118_PARENT_API_REPORT=selfhost/build/phase111/p118-parent-entry-api01/report.json \
P118_RUNTIME_REPORT=selfhost/build/phase118/runtime-extend01/report.json \
selfhost/.bootstrap/bun-1.4.3/bun selfhost/tools/performance/phase118/cost.mjs \
  selfhost/build/phase111/p118-float-api01/report.json \
  selfhost/build/phase118/float-source01/manifest.json \
  selfhost/build/phase118/float-hosted-cost01 \
  coverage-map-churn-128 coverage-list-pipeline-128 lexer tree-bitonic \
  coverage-closures-256 editdist variation-local-fold-128-0 \
  coverage-numeric-recurrence-1024
```

Wrap this in the same resource guard rather than running alongside native
qualification or timing. Add `P118_EXPECT_EMISSION_REPORT` only if its selected
source pin is exactly float-source01 and it contains every requested case. A
previous candidate's artifact cannot serve as the new source's exact-byte oracle.
Without that variable the harness checks source/API provenance and deterministic
successful emission, while target correctness remains the independent native
and runtime campaigns. Hosted prepared-request costs and native fresh-process
request costs are separate metrics and should remain separate in reporting.
