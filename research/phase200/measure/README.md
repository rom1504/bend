# Phase200 same-object runtime measurement

No jobs start automatically. Freeze a small plan from a completed runtime-object receipt:

```sh
python3 -B research/phase200/measure/make-plan.py \
  --name candidate-focus01 --runtime PATH/whole-runtime.o --receipt PATH/report.json \
  --cases mandelbrot,lexer,test-map-set-ops
```

The generated `plans/candidate-focus01-argv.json` is an executable argv array. Only after the coordinator grants CPU3:

```sh
python3 -B -c 'import json,subprocess,sys;sys.exit(subprocess.run(json.load(open(sys.argv[1]))).returncode)' research/phase200/measure/plans/candidate-focus01-argv.json
```

Omitting `--cases` freezes six diverse cases. `--cases all` freezes all45. Timing uses unchanged Phase199 calibration/oracles: three position-balanced roles, three rounds, 140 ms target and strict 100 ms floor. Same original workload, arguments, warmups and fixed-catalog weights. Every selected case and dispersion flag stays included; zero-work remains correctness-only. Runtime ratios compare freshly measured role medians, not historical timings.

Incumbent is the retained Phase199 integrated live-plus-scan executable, C is the retained mature C executable. Only candidate ELFs are linked. The default source is the original Phase199 native45 `program.o` manifest. Candidate whole runtime must include the scan leaf and preserve ABI11102; missing symbols fail linking, incorrect behavior fails full stdout/stderr/count checks. The candidate runtime must occur by exact hash in its completed receipt. Preparation checks lineage, object, source and original link-command provenance; no outputs transfer between products.

For a Bend/source change, `--native-manifest PATH/programs.manifest.json --native-role candidate` accepts an already produced native x86 object manifest with complete actual build receipts. Changed compiler source is explicit in the summary. This does not acquire a compiler or trust unauthenticated object dumps. Checked hosted-only object manifests are not yet supported by this adapter.

Focused three cases use a 6 MiB guard, six cases 10 MiB; both retain exact products, link argv and complete raw observations. Whole45 uses a 32 MiB budget and requires storage admission first: the current ~25 MiB margin above the 5 GiB reserve is insufficient. `/dev/shm` is not used because the existing guard requires all outputs on the admitted filesystem. The retention owner coordinates cleanup; this tool deletes no old evidence.

`screen.py` delegates runtime and strict summaries to the existing Phase199/193/192/186 methods. Outputs live under fresh `selfhost/build/phase200/NAME`, with a standard shared CPU3 lock, disk reserve and closed retention receipt. Do not edit frozen methods or plans during a run. `summary.json`/`.md` contain source/runtime pins, complete oracle authentication and dispersion diagnostics.
