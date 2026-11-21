# Phase205 reproducible two-image screen

This harness runs nothing implicitly. First freeze the supplied Phase201 `cold/replay.py --save-image` gzip artifacts and their `results.json` receipts:

```sh
python3 -B research/phase205/measure/plan.py \
  --name text-smoke01 \
  --baseline BASELINE/program.gz --baseline-receipt BASELINE/results.json \
  --candidate CANDIDATE/program.gz --candidate-receipt CANDIDATE/results.json \
  --cases smoke
```

`smoke` means `coverage-unicode-text-16,coverage-unicode-text-64,lexer`. Source paths come from the receipts; `--baseline-source` and `--candidate-source` may supply byte-identical relocated sources. Exactly one saved-image run is required per receipt. The gzip itself, source, receipt, decompressed ELF digest, compiler Base/carrier/stamp, linker, product runtime, C products and independent oracle files are frozen. An unverified image/path cannot silently replace a role.

The plan command emits `plans/text-smoke01.json` and its executable argv array. Only the lane owner should dispatch:

```sh
python3 -B -c 'import json,subprocess,sys;sys.exit(subprocess.run(json.load(open(sys.argv[1]))).returncode)' research/phase205/measure/plans/text-smoke01-argv.json
```

After the smoke gate succeeds, repeat planning with a fresh name and `--cases all` for the complete45 (44 ratio eligible). Explicit comma-separated subsets are also supported. Add `--expect-unchanged ID,ID` to make byte-exact object equality a required gate on named controls. The default reports all identities without assuming which cases the new rule should affect.

Both compiler images are decompressed into bounded sealed memfds and authenticated against `runs[0].elfSha256`. No decompressed compiler copy is written to disk. Each real frozen source is actually compiled by both images. Every object is checked by the maintained x86 object-header reader and retained. Both links use the same live-plus-scan runtime used by Phase200 and the same object argument `/proc/self/fd/90`, preventing object filename differences from contaminating ELF comparisons. Compiler generation receipts and source hashes remain explicit; this experimental image interface does not claim installed/N2 qualification.

Every C/baseline/candidate product is freshly checked against the full independent expected output, count and stderr contract before timing. C binaries are authenticated against the frozen Phase200 summary/manifest, without requiring unrelated old compiler binaries to remain present. Source variants in native45 provide transfer observations. Optional `--controls research/phase205/controls/manifest.json` compiles and runs each authored control through both images and checks exact independent full stdout/empty stderr. These extra controls are correctness-only and never enter runtime aggregates; successful execution is not inferred from an authored expectation.

Timing reuses the unchanged Phase199 sampler and Phase200 complete-case report checkpoint wrapper. All three roles are timed, even when object/ELF/loaded-layout bytes match; no timing is fabricated or transferred. Three rounds rotate every role through every position. Default calibration target140 ms gives headroom above the unchanged100 ms admission floor; `--target-ms 100` is supported explicitly but leaves less noise margin. Workload, arguments, warmups and original fixed-catalog repetition weights stay frozen. The strict Phase186/192/193 analyzer reopens every raw observation and retains dispersion flags and all cases. Reported ratios include each case, aggregate geometric means, equal-family diagnostics and fixed-work seconds.

Outputs: `preparation.json` (both real productions, preflights, identities and controls), `manifest.json`, `timing/report.json`, complete raw stdout/stderr/process receipts, and strict `summary.json`/`.md`. Compilation/link costs are reported separately from normalized program intervals. Smoke defaults to90 s /24 MiB; all45 defaults to600 s /96 MiB. Override `--seconds`/`--disk-mib` only before freezing. The standard guard enforces CPU3, shared lane lock,2 GiB RSS,5 GiB free-disk reserve and retention closure. Disk headroom must cover both native product sets and raw observations.

No target jobs were run while developing this harness. `test-metadata.py` exercises only gzip/hash/source bindings and memory sealing using synthetic bytes; it does not run those bytes or a compiler.
