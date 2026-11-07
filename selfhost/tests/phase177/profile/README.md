# Phase177 frontend profile preparation

Source-only preparation; these scripts have not been run by the preparing agent.
Root owns execution and decides whether to spend the lane. The initial medium
request has a prior 13.670s frontend / 16.377s whole-process observation; this is
budget context, not a prediction or a fresh isolated timing. The exact baseline
and supplementary stdout oracle come from
`selfhost/build/phase177/screen-batch01/subst/result/report.json`.

The plan reuses `front-base-native01/program.o` unchanged, its retained QBE and
source receipt, and `assets-runtime.json`'s serial-RFC runtime recipe. Existing
`runtime.py` and `stages-build-v1.py` insert their reversible diagnostic hooks.
Existing `profile-v2.py` relocates only the three output paths and linked runtime
input. The three build jobs compile the small sampler, compile diagnostic
runtime, and relink; they do not compile Bend or rerun QBE/assembly.

The existing Phase161 sampler receipt supplies its exact source and libc-only
CFI table. Its ELF pin is checked. The Phase171 runtime-caller table belongs to a
different executable and cannot be reused for this frontend ELF. This first
capture therefore retains limited caller recovery and explicit unknown owners;
it does not claim improved attribution coverage. Counters stay disabled.

From repository root, metadata only:

```sh
python3 -B selfhost/tests/phase177/profile/prepare.py prepare \
  --out selfhost/build/phase177/profile-prep01 \
  --products selfhost/build/phase177/profile-products01
```

Root execution, one existing guard and two fresh declared artifact roots:

```sh
python3 -B selfhost/tests/phase177/job.py \
  --extra-root selfhost/build/phase177/profile-products01 \
  profile-build01 60 64 \
  python3 -B selfhost/tests/phase177/profile/prepare.py build \
  --plan selfhost/build/phase177/profile-prep01/build-plan.json \
  --out selfhost/build/phase177/profile-build01
```

Freeze actual products and existing small/medium oracles, metadata only:

```sh
python3 -B selfhost/tests/phase177/profile/prepare.py manifests \
  --prep selfhost/build/phase177/profile-prep01 \
  --build-report selfhost/build/phase177/profile-build01/report.json \
  --out selfhost/build/phase177/profile-manifests01
```

One medium request is both the first stage-order gate and a bounded descriptive
profile. At 2ms, roughly 6,000 frontend samples would be expected if diagnostic
CPU duration stays close to the old observation; actual delivered/lost sample
counts and observer checks decide usability. This timer expectation is not a
wall-clock measurement. Use only one sample period for the first capture:

```sh
python3 -B selfhost/tests/phase177/job.py profile-medium01 75 32 \
  python3 -B selfhost/tests/phase177/profile/adapter.py capture \
  --manifest selfhost/build/phase177/profile-manifests01/medium-manifest.json \
  --modes sample --periods-us 2000 --rounds 1 \
  --out selfhost/build/phase177/profile-medium01
```

Observe with the same narrow output adapter, offline:

```sh
python3 -B selfhost/tests/phase177/profile/adapter.py observe \
  --spec selfhost/build/phase177/profile-prep01/spec.json \
  --run selfhost/build/phase177/profile-medium01/report.json --row 0 \
  --out selfhost/build/phase177/profile-medium01/stages.json
```

The adapter delegates unchanged `run.main` and `stages_v1.main`. It extends only
the output matcher for the literal complete stderr grammar
`phase175 base_ms=N frontend_ms=N observation_ms=N\n`, with unsigned decimal
integers. It pins its own source and the prior stderr observation. Raw stdout
and stderr remain untouched. Stdout must match the frozen prior bytes exactly;
this digest is supplementary, not independent complete semantic equivalence.
The generic observer correctly reports `requestExact: false` because stderr's
three timing values vary. Every other status, input, loss, pairing, stage and
ELF check remains in the existing tools.

Twelve newly derived direct-entry markers separate Base, parse/load, checker,
dependency report, ownership, entry checks, context, reach/annotation, layout,
erasure/request, wrapping, and digest/output. Missing, repeated or reordered
markers fail; do not repair a failed capture or infer the skipped interval.
The final interval ends at the runtime exit hook, not complete process teardown.
Sub-500-sample intervals and failed quality gates remain descriptive. Preserve
unknown in all denominators, distinguish physical leaf/active owner/caller, and
never turn an owner's sample count into an inclusive/removable-cost ceiling.

A full-source capture should be considered only after this gate succeeds. It
needs a separately pinned full-source oracle/command; these manifests deliberately
contain only the two existing Phase177 baseline screen commands. No new
whole-frontend clean timing, optimizer win, or installed/runtime change is made.
