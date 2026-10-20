# Phase114 frozen subset acquisition

`prepare-hosted-v2.py` is an offline derivative of Phase113 `hosted45-v2.py`.
It authenticates `manifest01.json`, `names01.txt`, the original45 sources and
upstream profile, checked API exports and runtime. It accepts only explicit
subsets of the eight frozen cases. It runs no compiler or target.

```
python3 -B selfhost/tools/performance/phase114/bench/prepare-hosted-v2.py \
  --api selfhost/build/phase111/p114-take-api01/api.mjs \
  --runtime selfhost/build/phase113/runtime-products-build01/runtime.o \
  --names coverage-list-pipeline-128 tree-bitonic coverage-expression-128 \
  --tag p114-take-screen01 --out selfhost/build/phase114/take-screen01-jobs.json
```

The prepared jobs use unchanged Phase113 staged transport and Phase111 builds.
The separate reports map contains exactly the original Phase112 binder's
`name: {emission, build}` entries. The plan records exact unmodified `bind` and
three-round `measure` commands, including explicit subset names, frozen profile
and Phase113 candidate31 baseline binding. Root runs them under its serial guard
only after acquisition completes. `--reuse-reports` authenticates an already
built subset against the same API/runtime/transport before adding missing cases.

Timed batch sources print a variable elapsed-time line; Phase112 `observe.py`
does not accept that protocol. The unchanged benchmark `measure` command checks
those complete outputs and success counts. Optional `--observe-one-shot` also
builds the separately frozen source88 companions and uses unchanged Phase112
`observe.py` with exact status/stdout/stderr. These companion builds are optional
extra semantic coverage, not the timed products bound for measurement.

The eight-case subset is a development screen. Do not relabel it full45 parity
or change repetitions based on candidate timings. Three-round measurements retain
the established minimum-interval and complete-output requirements.

Version2 puts the measurement output under `selfhost/build/phase112`, as the
unchanged measurement tool requires. Version1 and its unexecuted prepared plan
remain historical; do not execute their measurement command.
