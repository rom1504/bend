# Phase199 rapid broad45 screen

This screen compares mature C, the qualified Phase198 progress compiler with the live runtime, and the new native N1 compiler with that same live runtime. It executes all 45 original native45 workloads; 44 are ratio eligible. It does not replace the installed compiler or assert N2/N3 reproduction.

Frozen candidate: `selfhost/build/phase198/p199-core02/compiler.bend`, SHA256 `3b1c136a2822f3f0824edca400f40b62490be9757af233a4e9694c527961fcf4`. Root owns QBE→N1 acquisition at `selfhost/build/phase198/p199-core-native-image01`. Its checked native acquisition receipt authenticates the actual source. The original core01 source was refused; it is not admitted by this recipe.

Run the JSON argv arrays sequentially, stopping at any failure:

1. `native45-argv.json`: existing native-programs acquisition; all 45 direct objects, original-runtime links and independent output oracles. Historical duration 106 s; cap 180 s / 48 MiB.
2. `prepare-argv.json`: authenticate source, object and actual native lineage; reproduce every default link byte for byte; relink the same objects with the frozen live runtime. Reuse authenticated progress/C executables. Recheck all three complete outputs on every case (135 observations). Estimated 15–25 s; cap 90 s / 48 MiB.
3. `runtime-argv.json`: three role-position-balanced rounds, adaptive per-role 140 ms calibration, unchanged minimum accepted interval of 100 ms. Estimated 160–190 s; cap 240 s / 48 MiB, internal deadline 225 s.
4. `summary-argv.json`: offline strict reauthentication of all input identities, preflight streams, calibration streams and 405 timed observations; write JSON and Markdown findings. No target execution.

To execute an argv file under the root coordinator's lane authorization:

```sh
python3 -B -c 'import json,subprocess,sys; sys.exit(subprocess.run(json.load(open(sys.argv[1]))).returncode)' research/phase199/broad/native45-argv.json
```

Each execution argv uses the existing Phase198 guard with a fresh `p199-` run name, CPU3, a 5 GiB free-disk reserve and retention closure. The preparation discards only its newly generated duplicate default-link executable after proving identical full ELF bytes to the retained production executable. It retains the verified hash and size; no existing evidence is deleted. Approximately 70 MiB additional outputs cover these three stages, excluding N1 acquisition (~130 MiB historical).

Relative to the historical four-role/four-round/250 ms campaign, this deliberately reduces roles, rounds and calibration target. It preserves exact workloads, arguments, warmups, full-output/count oracles, complete role rotation, original catalog repetition weights, all input-change checks, and the 100 ms acceptance floor. No low-resolution sample or dispersed case is removed to improve a result. Original-runtime program links remain a correctness/byte-identity gate, but original-runtime performance is not measured here. No historical timing is substituted for the freshly timed baseline.

`runtime.py` derives from the Phase195 calibration runner, changing only its documented target range/default. `summarize.py` reuses Phase186/192/193 authentication and aggregate formulas. The Phase198 development/heldout labels remain descriptive; these are not newly unseen cases. Exact object identity plus exact allocated ELF layout (including address, offset, size, flags and payload, excluding GNU build ID) is reported for unchanged cases, but all cases are still timed.

Preparation and analysis require fresh outputs. Metadata-only checks were performed before dispatch; actual measurements and their acceptance are established only by the produced guarded receipts and strict summary.
