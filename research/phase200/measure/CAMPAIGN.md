# New native compiler: acquisition then complete broad comparison

The coordinator owns dispatch. The inputs are configurable; allocator currently plans:

- Source: `selfhost/build/phase200/p200-candidate-source01/compiler.bend`.
- Independent check: `selfhost/build/phase200/p200-candidate-check01/report.json`.
- Native N1: `selfhost/build/phase200/p200-candidate-native-image01/{program,report.json}`.

After N1 succeeds, freeze its exact source, checked receipt, image and assets:

```sh
python3 -B research/phase200/measure/prepare-native.py \
  --source selfhost/build/phase200/p200-candidate-source01/compiler.bend \
  --source-check selfhost/build/phase200/p200-candidate-check01/report.json \
  --image selfhost/build/phase200/p200-candidate-native-image01/program \
  --image-receipt selfhost/build/phase200/p200-candidate-native-image01/report.json
```

Run `plans/candidate-native45-01-argv.json` under the granted lane. This is the unchanged Phase190 all45 native driver, with exact Phase199 `integrated-assets.json`: original runtime plus scan leaf. It actually emits every object, default-links and checks every independent output. Historical physical acquisition: 106.8 s; cap150 s, internal140 s,32 MiB.

Once that guard closes successfully:

```sh
python3 -B research/phase200/measure/prepare-broad.py \
  --native-manifest selfhost/build/phase200/candidate-native45-01/programs.manifest.json
```

Run `plans/candidate-broad01-argv.json` only under the granted lane. This freshly links candidate objects against the exact existing live-plus-scan runtime and reuses Phase199 incumbent/C ELFs unchanged. Every selected point/source/oracle and native producer binding is checked; all135 role preflights and405 measured observations are authenticated. All45 execute;44 remain ratio eligible. Fixed catalog workload/weights, arguments, warmups, three balanced rounds,140 ms target,100 ms floor, and all dispersion flags remain unchanged. Cap180 s, internal timing165 s,32 MiB.

The exact existing sampler is imported without changes. A narrow save wrapper checkpoints the growing report initially, after every complete case, on errors and at final closure. Every individual raw stdout/stderr file is still retained immediately, and every pilot/sample remains in the final report. This removes repeated serialization of the full growing report before/after each sample. Phase199 took179.7 s overall but101.3 s inside actual pilot/timed subprocesses; those program intervals, not total harness time, determine ratios. No new result is inferred from this overhead estimate. Metadata-only tests cover ordinary/failure checkpoint retention and untouched unrelated writes.

Preparation and timing share one guard. `summary.json`/`.md` bind the actual compiler source/runtime, all measured ELFs and receipts and retain partial/full coverage explicitly. Source-generation/acquisition elapsed time is reported separately from program timing. The previous campaign's results are never substituted for a freshly observed role.

Two downstream stages need roughly60 MiB simultaneously beyond the retained image; storage owner reclaimed space and confirmed145 MiB margin before image acquisition. Every actual guard still independently checks its5 GiB reserve. No `/dev/shm` bypass and no automatic deletion of earlier evidence.
