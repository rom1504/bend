# Phase171: measure the remaining full cold-build cost

Prepared from the installed Phase170 receipts; no compiler, machine build or
profiling target was executed by this audit. The target is **100 seconds for the
full maintained source**, versus the observed 189.329 seconds. This requires
89.329 seconds, or 47.18%, less whole-build time. The smaller Phase169 source
closure is not the workload.

## What is already measured

| Observation | Exact boundary | Seconds |
| --- | --- | ---: |
| Phase170 N1→N2 | Full source → executable, after preflight |189.328937|
| Same build, compiler + QBE relay | Both children, bounded streaming, CPU3 |183.372671|
| Assembler | Separate child after QBE |4.614591|
| Linker | Separate child after assembler |0.240939|
| Phase170 N2 Q3 | Full source → complete QBE, regular-file stdout |164.616132 wall|
| Same Q3 | Whole compiler child CPU |164.510070 CPU|
| Previous generation acquisition | Full source → N1 executable |189.190999|

Sources: `selfhost/build/phase170/native-chain-final/{n1,n2,q3}/report.json`.
N1 and N2 have byte-identical loadable segments, QBE, assembly and object;
complete ELF bytes differ in `.strtab`. These are individual observations, not
paired medians. Q3's peak process RSS is 811,504KiB (792.5MiB); assembler peak is
825,060KiB (805.7MiB). The whole final bootstrap guard observed 820.9MiB peak tree
RSS. A 2GiB capture limit has measured headroom.

The Q3 compiler produced 97,488,970 bytes, SHA256
`661b62664acdac83d12bc3192b5f9113a2bb946dd331433e64ca0452f6f83850`,
from 3,150,535 source bytes, SHA256
`434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`.
The installed N2 is
`0dba3d4d19cd974e759058afbe86608fc7e1770d0c5ebf8f9d06c2697b658f4f`.
Prepared Base, carrier/stamp, one heap mutator, CPU3, GPU off, runtime and machine
toolchain remain fixed. “Cold” means a fresh compiler process/request here;
it does not mean evicted filesystem caches or rebuilding Base from source.

### Machine floor: measured versus inferred

The only separately timed terminal machine cost is **4.855530s assembly+link**.
This is an observed cost for unchanged products/toolchain, not a universal lower
bound. `native.py` retains compiler/QBE child exits but no separate child CPU
times. **The QBE machine-construction floor is not yet directly measured.**

The cross-run difference 189.328937−164.616132 = **24.712805s** is a useful
budgeting residual, not measured QBE time. It mixes QBE, relay/backpressure,
assembly/link, bookkeeping and run variation. The pipeline shares CPU3 while Q3
writes a regular file. Do not add compiler/QBE elapsed clocks or subtract this
residual as an exclusive stage. Even treating the entire residual as removable
would leave about165s: machine construction alone cannot plausibly deliver100s.
If that residual were unchanged, the compiler-only budget would be about75.3s,
requiring roughly2.19× faster compiler execution. That is a conditional target,
not a forecast.

One optional retained-IR replay can directly measure current QBE/as/link without
recompiling Bend (guard it separately; no default campaign):

```sh
python3 -B selfhost/tools/build/native.py \
  --assets selfhost/manifests/assets-native.json \
  --ir selfhost/build/phase170/native-chain-final/n2/program.ssa \
  --seconds 90 --out selfhost/build/phase171/machine-only01
```

Use CPU3, 2GiB RSS, 128MiB disk, 128MiB file cap and an outer120s deadline. Keep
the5GiB reserve. Inspect this new report's machine clocks; compare the entire
assembly/object with the retained Phase170 products. Do not infer whole-ELF
equality if output-path metadata changes. This replay is unnecessary before the
first compiler profile; the existing budget already points to compiler work.

## What needs refreshing

The Phase169 accepted native profile predates the final single-verifier and
quality-restoration route. It sampled5,484 physical leaves at32ms,99.35% main-
thread/process-CPU coverage and zero loss. It had no current semantic stage or
allocation-owner attribution. Its40.41% lifetime/product leaf share and9.50%
named equality share are historical hypotheses, not current removable time.
The proposed duplicate full-verifier elimination in that note was subsequently
implemented. The projection replay's final1.46% ceiling also supersedes its
earlier speculative5–12% estimate.

Phase161/153 contain the last detailed old-pipeline stage measurements, including
26.78s private-candidate production,23.67s initial optimizer,16.19s registry
preparation and40.21s render/output/cleanup. Their architecture and instrumentation
differ. Do not transplant those seconds into the installed early-interface path.
Likewise, the historical2.132B allocation residual is not a count for final
Phase170. Neither current full-request allocation counts, lifetime by semantic
stage, nor allocator-origin ownership have been measured.

The maintained profiler can supply physical samples, active dispatch, exact
FID-derived boundary clocks and separate event counters. **Stages-v1 explicitly
forbids event counters in the same capture.** Global event counts/owner events
are a separate diagnostic run; current stage sidecars do not snapshot allocation
counters. Allocation calls/requested words are not retained bytes, and reclamation
context is not allocation origin. Inline operations may bypass runtime hooks.

## Prepared highest-information refresh

Prefer **one staged full sample after one small marker/output pilot**, using the
retained final N2 object. There is no Bend recompilation. The existing generic
runtime instrumenter, ordinal sampler and stage observer are reused unchanged.

Metadata preparation has already completed:

- Method: `experiments/phase171/tools/prepare-profile.py`.
- Root: `selfhost/build/phase171/profile-prep01/` (22.37MB prepared).
- Frozen build plan: `stage-runtime/plan.json`.
- Exact current owner/FID map: `owners.json`; selected ELF binding:
  `selected-elf.json`; source-derived marker hypotheses: `spec.json`.
- Three root-owned build jobs: sampler shared object, small runtime object,
  relink the retained final N2 program object. No generated code changes.

The first guarded invocation refused during preflight because its declared run
root already contained metadata. No build job started. The original plan and
preparation remain unchanged. The successor `profile-plan-v2.json` relocates
only the three job output paths and the runtime-object link input into fresh
`profile-products01/`; `profile-v2.py` creates that directory inside the guarded
run. Its manifest operation reads actual product paths from the normal maintained
build receipt. This is an output-placement repair, not a new compiler treatment.

All32 marker identities exist as actual dispatcher entries in the current image.
The29 ordered markers partition the successful ordinary request; three optional
markers record selective versus ordinary composition and runtime admission.
Repeated candidate enumeration and cursor-drain entries use `first`; their counts
remain visible. The small pilot must validate actual order/multiplicity before
the full capture. No prior image's FID is reused.

Key boundaries correspond to real data production:

| Interval | Work charged, including intervening ownership/continuations |
| --- | --- |
| `p86_plan` → `p86_plan_loaded` | Parse/load |
| loaded → checked | Checking/publication |
| checked → `p169np_plan` | Reporting, eligibility, annotation/layout and request preparation, with finer markers |
| `p168_request_mode` → catalogued | Source permission and constructor catalogue |
| catalogued → prepared | Static-body preparation |
| prepared → scanned → seed_verified | Observer classification, then independent seed checking |
| selected → first `p113pl_candidates` | Remaining-name selection/signature preparation |
| first candidates → `p168_candidates` | Complete private-candidate construction |
| candidates → `p168_closed` | SCC/dependency admission and bundle preparation |
| closed → `p169q_inlined` | Selected/ordinary composition and scalar eligibility preparation |
| inlined → `p168_finish_functions` | Scalar replacements, checking, retries and patches |
| finish_functions → `p169s_lowered` | Demand-driven generic families/adapters and bookkeeping |
| lowered → `p169a_original` | Actual generic/static/adapter verification |
| view → `p169a_checked` | View construction, certificate derivation and unchanged borrowed/direct verification |
| checked → `p169c_output` | Namespace/live checks and conditional cold metadata |
| output → `p169s_registered` | IDs, fusion index, tables and seeded region discovery |
| registered → print → first drain | Forwarders/cursor preparation, then prefix writing |
| first drain → exit hook | Cursor rendering, writing and cleanup before that hook |

These are entry-to-entry intervals, not inclusive call-stack durations. Some
labels intentionally combine operations; the view interval cannot be called
“verifier alone.” Startup/read work before the first marker and work after the
exit hook remain separate residuals. Physical leaf percentages and stage clocks
overlap; never add them. The current owner parser marks705 lexical groups unknown
(32,785/45,896 FIDs conditionally owned). Exact FID/address binding is stronger
than lexical ancestry; do not relabel unknown groups or private/inlined calls.

Root-owned commands, sequentially:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase171/profile-build01-guard \
  --run-root selfhost/build/phase171/profile-products01 \
  --run-root selfhost/build/phase171/profile-build01 \
  --seconds 45 --disk-mib 64 --rss-mib 2048 --available-mib 16384 \
  --file-mib 64 --cpu 3 -- \
  python3 -B experiments/phase171/tools/profile-v2.py build \
    --plan selfhost/build/phase171/profile-plan-v2.json \
    --out selfhost/build/phase171/profile-build01

python3 -B experiments/phase171/tools/profile-v2.py manifests \
  --prep selfhost/build/phase171/profile-prep01 \
  --plan selfhost/build/phase171/profile-plan-v2.json \
  --build-report selfhost/build/phase171/profile-build01/report.json \
  --out selfhost/build/phase171/profile-manifests02
```

The second command is metadata-only and authenticates the linked descriptor/FIDs.
It prepares `profile-manifests02/{pilot,full}-manifest.json`, using the exact
Phase170 Map and Q3 outputs respectively. Run the pilot under a60s/32MiB/2GiB
CPU3 guard, with the following inner command:

```sh
python3 -B selfhost/tools/profiler/run.py \
  --manifest selfhost/build/phase171/profile-manifests02/pilot-manifest.json \
  --out selfhost/build/phase171/profile-pilot01 \
  --modes sample --rounds 1 --periods-us 32000

python3 -B selfhost/tools/profiler/stages_v1.py observe \
  --spec selfhost/build/phase171/profile-prep01/spec.json \
  --run selfhost/build/phase171/profile-pilot01/report.json --row 0 \
  --out selfhost/build/phase171/profile-pilot-stages01.json
```

The pilot is too short for quantitative sample attribution. Its purpose is exact
output, entry order/counts, actual ELF/FID binding and valid clocks. Preserve a
failed pilot; correct a boundary hypothesis in a fresh version instead of
weakening order or counting a refusal as a pass. After that gate, run **one** full
sample under330s/160MiB disk/2GiB RSS/128MiB file cap,16GiB available floor,CPU3:

```sh
python3 -B selfhost/tools/profiler/run.py \
  --manifest selfhost/build/phase171/profile-manifests02/full-manifest.json \
  --out selfhost/build/phase171/profile-full01 \
  --modes sample --rounds 1 --periods-us 32000

python3 -B selfhost/tools/profiler/stages_v1.py observe \
  --spec selfhost/build/phase171/profile-prep01/spec.json \
  --run selfhost/build/phase171/profile-full01/report.json --row 0 \
  --out selfhost/build/phase171/profile-full-stages01.json
```

Require exact97,488,970-byte stdout, empty stderr, exit0, unchanged inputs, valid
stage order/counts,≥95% sampled-thread CPU coverage, zero loss/overruns, intact
handler/lifecycle and plausible delivery. Expect roughly5,000 samples, but use
actual counts. Per-stage distributions below500 samples stay descriptive even
when their diagnostic clocks are valid. The stage collector disables event
counters; no allocation totals are implied. Sampling and context dispatch alter
execution: compare with retained Q3 CPU/wall only as an overhead check, not a
clean optimization result or exclusive source-level time.

The existing physical-only sampler is also reusable and verified against its
retained snapshot. Fallback recipe:
`experiments/phase171/full-profile.recipe.json`; frozen manifest:
`selfhost/build/phase171/full-profile-manifest01.json`. It needs no relink and
the same one-sample guard, but provides no semantic stage/owner contexts. Prefer
the staged capture if its small gate succeeds; do not run both full profiles
merely because both plans exist.

## Fast loop after the refresh

Two already qualified current compilation requests are cheap:

| Request | Native wall | Complete expected QBE | Peak RSS |
| --- | ---: | ---: | ---: |
| Lexer,7,257 source bytes |0.671493s|305,451 bytes|38.2MiB|
| Map/set,5,401 source bytes |1.961500s|1,245,568 bytes|42.5MiB|

Receipts: `phase170/qbe64-final/22-lexer/emission/report.json` and
`27-test-map-set-ops/emission/report.json`. They exercise the complete ordinary
pipeline, but do not reproduce full-source scales or all eligibility decisions.
Use them for exact-output and diagnostic counter pilots, not to forecast the
100s goal. For a compiler-owner hypothesis, the retained39KB nonempty verifier
source fromPhase167 is a stronger third case, after acquiring its exact current
output once. Do not automatically reuse an old-version QBE oracle.

Choose the next experiment from the refreshed *disjoint* stage budget, then count
only the implicated operations on one small request using the retained-object
runtime event hooks. A full allocation run is justified only if this reveals a
specific removable lifetime/representation cycle. Do not run counters and stage
sampling together, multiply a tiny kernel speedup by the full source, reintroduce
the already removed duplicate verifier, or repeat the falsified equality/index-
zipper proposals. The first deliverable is a current stage budget that can explain
where an89-second saving could come from.
