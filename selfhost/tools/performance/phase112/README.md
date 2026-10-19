# Direct QBE optimization fast loop

This directory contains additive **Bend** compiler transformations and their
independent controls. Python/JavaScript tools compose authenticated files,
supervise native tools and measure results. They do not perform compiler lowering.
See the [design](../../../../design/phase112/qbe-parity.md) and
[report](../../../../implementation/phase112/README.md) for current qualification.

The `word` profile is the strongest completed compiler candidate at the02:28UTC
checkpoint. `regions`, `multi`, `multi-wide` and `gap` are explicitly separate
experiments. Do not infer qualification from a profile being available.

## Choose the smallest useful loop

| Question | First check | Follow-up |
|---|---|---|
| Does a Bend edit type-check? | `phase111/check-api.py` on composed source | Export only the needed diagnostic entries |
| Is a transformation legal? | Its independent controls and negative/mutation cases | Paired native fixtures with exact stdout |
| Did the generated shape improve? | Compare exact QBE and diagnostic helper counters | Six-program matched runtime screen |
| Did the compiler get faster? | Three frozen compiler requests in `transport/` | Native acquisition/self-emission after a material small-loop win |
| Does the win generalize? | `benchmark45/` frozen follow-up | Full45 semantic gate and N2 checks |

Most focused controls take seconds; the six-program runtime screen takes roughly
one to two minutes at the current slowest ratios. Full compiler acquisition and
self-emission take minutes and should be integration gates, not edit feedback.
Guard budgets are ceilings, not promises about performance. Never run benchmark
targets concurrently: the coordinator owns CPU3.

## Prepare and check

Commands assume the authenticated Phase111 baseline and pinned bootstrap assets
already exist locally. They are generated artifacts, not bundled compiler
binaries. The Phase111 guide explains their acquisition. Every output directory
must be fresh; use a new suffix on retries and retain failures.

```sh
python3 selfhost/tools/performance/phase112/prepare-candidate.py \
  --profile word --out selfhost/build/phase112/user-word01

python3 selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase112/user-api-guard01 \
  --seconds 60 --rss-mib 2048 --available-mib 16384 -- \
  python3 selfhost/tools/performance/phase111/check-api.py \
  --source selfhost/build/phase112/user-word01/compiler.bend \
  --out selfhost/build/phase111/p112-user-api01 p111_compile_source
```

`recipes.json` records the module order and explicit declaration overrides.
`prepare.py` snapshots/authenticates each module before composition and refuses
changes during preparation. It does not silently rewrite old acquired images.

Use the checked API with `phase111/coverage/run.py` for focused source execution,
or `phase111/emit.mjs` and `phase111/build.py` for one exact QBE product. An API is
hosted development machinery, not a native compiler-speed measurement.

## Separate the clocks

- [Compiler transport](transport/README.md): complete native source→QBE requests,
  upstream TypeScript/Bun source→C, then separate executable construction.
- [Six development programs](benchmark/README.md): batched execution of already
  built programs, fixed sources/counts and three alternating rounds.
- [Original45 follow-up](benchmark45/README.md):44 measurable input points across
  23 historical families, plus an explicit zero-work control. These are not45
  independent source families. Held-out means held out from this phase's first
  six-point screen, not never previously seen.
- [Runtime diagnostics](profile/README.md): instrumented helper/event counts,
  never CPU-time percentages or performance timings.

All comparison tools retain exact source, compiler image, runtime, QBE/toolchain,
output and benchmark hashes. Native prepared Base and cached runtime differ from
upstream's source Base and whole-C build policy; keep that distinction visible.
The mature production B1/B2 labels must not be substituted for experimental
direct-route N1/N2.

## Guardrails and consolidation

Full jobs use at most4GiB process-tree RSS and a16GiB available-memory floor;
smaller jobs use2GiB. The existing guard enforces CPU3, deadlines and a128MiB
per-file limit. Do not delete or overwrite historical products. Disk recovery
this phase authenticates identical bytes before hardlinking them; fresh outputs
are mandatory thereafter.

`time-accounting.py` measures unions of guard occupancy, not agent billing.
`source-complexity.py` counts exact assembled source and separates control files.
`compare-elf.py` authenticates build receipts and compares memory layout as well
as section bytes. `seal-evidence.py` prepares a bounded evidence capsule; large
sources/images remain authenticated local products rather than enormous commits.
