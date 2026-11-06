# Phase172 reproduction

Use `selfhost/bootstrap` at the Phase172 report commit. The compiler algorithms
are the experimental Bend modules in `selfhost/tests/phase172`; the only runtime
experiment is an explicit private copy of the pinned C runtime. No installed
selection is modified. Exact receipts and artifact identities are in
[metrics.json](metrics.json) and [evidence/](evidence/).

Every command that acquires an API, invokes a compiler/linker, or executes a
program must run in the maintained `build-retention/guard.py`: one CPU3 lane,
5GiB reserve, fresh declared `--run-root`, bounded whole-job disk/time and2048MiB
RSS (the checked hosted API acquisition used3072MiB). Close each guard through
`build-retention/close.py`. Never nest guards. All fresh paths below belong under
`selfhost/build/phase172`; do not overwrite retained results. Metadata-only source
preparation is not a compiler execution.

## Deferred rows and sealed construction

The actual frozen inputs are `frontend-inputs05` and `runtime-inputs02`. Their
manifests bind the live experimental files copied before acquisition. Previous
revisions preserve five source-check failures; they are not passing implementations.

Use `selfhost/tests/phase171/prepare-api.py` (metadata-only) to assemble the
unchanged Phase170 canonical parent plus these explicit additions:

| API | Prelude | Modules | Exact replacement | Extra exports |
|---|---|---|---|---|
| Deferred baseline |deferred-pattern-laws.bend|deferred-pattern.bend, deferred-pattern-controls.bend|none|p172dp_sub_case, p172dp_match_case, f_load_graph_trace|
| Deferred candidate |same|same plus deferred-pattern-override.bend|ff_match|same|
| Sealed candidate |inline-runtime-sealed-laws.bend|inline-runtime.bend, inline-runtime-controls.bend, inline-runtime-sealed.bend, inline-runtime-sealed-override.bend, inline-runtime-sealed-controls.bend|p111q_stmt|p172is_controls, p172is_guard_observation, p172is_fast_observation, p172ir_oracle_module|

Pass one `--prelude`, repeated `--module`, `--replace`, and `--export` arguments,
and a fresh `--out`. Original protected declarations cannot be replaced. The
cold-only override is deliberately absent from the sealed candidate.

Inside a90s/64MiB disk/3072MiB RSS guard, acquire each assembled API with:

```sh
selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source SOURCE/compiler.bend --exports SOURCE/exports.json --out API \
  --upstream selfhost/.bootstrap/upstream-phase66 --engine selfhost/.assets/bin/bun
```

Finite and complete loader checks (60s/32MiB guard):

```sh
selfhost/.assets/bin/bun selfhost/tests/phase172/deferred-pattern-controls.mjs \
  --baseline BASELINE_API/report.json --candidate CANDIDATE_API/report.json \
  --source selfhost/build/phase167/verifier-source03/compiler.bend \
  --base selfhost/.bootstrap/upstream-phase66/bend2/base.bend --out FRESH_CONTROLS
```

Sealed-template checks (30s/16MiB guard):

```sh
selfhost/.assets/bin/bun selfhost/tests/phase172/inline-runtime-controls.mjs \
  --receipt SEALED_API/report.json --out FRESH_CONTROLS
```

The existing checked `selfhost/tests/phase171/request.mjs` invokes all compiler
algorithms in Bend. Use `--mode baseline`, the acquired `--receipt`, assembled
`--assembly .../manifest.json`, fixed `--source`, and fresh `--out`. For deferred
rows add `--reference selfhost/build/phase171/public-verifier-baseline01/report.json`
to require exact complete QBE. For the sealed variant QBE intentionally differs;
build it with maintained `native.py --ir .../program.ssa`, then use
`experiments/phase171/tools/native-pair.py` against the exact original machine
receipt, four balanced rounds. The fixed verifier stdout is `768\n`; lookup is
`3279346725\n`, with its original complete-value oracle in Phase166/171.

## Static-publication experiment

The mechanical adapter authenticates the original runtime and its exact inverse
patch. It snapshots unchanged headers. Preparation runs no compiler:

```sh
python3 -B experiments/phase172/tools/static-seal-runtime.py prepare --out FRESH_SOURCE
```

Inside a90s/16MiB guard:

```sh
python3 -B experiments/phase172/tools/static-seal-runtime.py build \
  --plan FRESH_SOURCE/plan.json --out FRESH_RUNTIME
```

The disabled object must equal installed`2d078323…`. Both objects use GCC10,
`-O2 -std=gnu11 -ffp-contract=off -DP144_SINGLE_MUTATOR_RFC=1`; only the experiment
flag differs. The macro is off by default and rejects unsupported device/parallel
configurations.

Relink authenticated existing objects, inside a30s/8MiB guard (64MiB for the full
compiler), with `link-pair --build FRESH_RUNTIME/report.json --program-object OBJECT
--program-ir QBE --out FRESH_PAIR`. The two small workload provenance receipts are:

- `selfhost/build/phase171/descendant-verifier-baseline-machine01/report.json`
- `selfhost/build/phase171/descendant-lookup-machine-baseline11/report.json`

`selfhost/tests/phase172/static-seal-pair.py --pair FRESH_PAIR/report.json
--provenance ORIGINAL_BUILD/report.json --expected EXPECTED --rounds 4 --out FRESH`
authenticates the identical program object/IR, executes both explicit binaries,
and requires the independent full stdout. No pointer/heap-state equality is
promised when unnecessary wrappers disappear.

The relink-only ordinary correctness runner is
`experiments/phase172/tools/static-seal-qualification.py`. Its recorded runtime
build and qualified Phase170 catalog are fixed authenticated inputs. Default six
cases passed; `--all-positive --plan-only` authenticated all61 but did **not**
execute them. A positive all61 campaign was not needed after neutral full transfer.
Neither option treats the three frontend refusals as runtime passes.

The separate counter source uses `static-seal-counts.py --out FRESH_SOURCE`;
`selfhost/tests/phase172/static-seal-observe.py --plan FRESH_SOURCE/plan.json
--out FRESH_COUNTS` compiles and executes the diagnostic baseline under a60s/16MiB
guard. It checks complete native outputs and exactly one partitioned counter
line on stderr. These timings are never clean performance evidence.

## Full fixed-source comparison

Relink the unchanged Phase171 N1 compiler object:

- Object/IR: `selfhost/build/phase171/native-candidate01/program.{o,ssa}`.
- Original build/source provenance: `native-candidate01/report.json`.
- Binding adapter: `selfhost/tests/phase172/static-seal-binding.py --pair PAIR/report.json
  --origin selfhost/build/phase171/native-candidate01/report.json --out BINDINGS`.

The disabled binary must match original`c354b39c…`. Relinking creates no new
bootstrap generation. Run each role separately under a260s/256MiB disk/2048MiB RSS
guard; the measured target receives a240s deadline:

```sh
python3 -B selfhost/tools/build/native.py \
  --assets selfhost/manifests/assets-native.json \
  --image PAIR/ROLE --image-receipt BINDINGS/ROLE.json \
  --host native --stage N1 --target qbe --mode cache \
  --source selfhost/build/phase170/source-final/compiler.bend \
  --expected selfhost/build/phase170/native-chain-final/q3/program.ssa \
  --out FRESH --seconds 240
```

Do not pass the candidate runtime as the **target** runtime: this comparison
changes the executable doing compilation, not its emitted program. Roles are
`baseline` and `static-seal`. Original run order was baseline then candidate,
one observation each. Both reproduce97,488,970 expected QBE bytes. The0.59%
difference is classified neutral, not a validated speedup or100s result.
