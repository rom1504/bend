# Phase76 native compilation experiments

The compiler changes are Bend source. These tools freeze experiments, expose
existing functions for diagnostics, check artifacts and run bounded targets.
They do not replace compiler algorithms in production. The pinned upstream is
059266225b77c8ca256ac6b25ee5c21449bab151; Phase75 remains the comparison baseline.

Use a fresh directory under `selfhost/build/phase76` for every target run.
One CPU3 process tree; 2 GiB aggregate RSS, 4 GiB available-memory floor, Node
1 GiB heap/4 MiB stack. No agents. Never modify consumed methods or sealed output.
The checked B1 workflow takes about 32 seconds; native acquisition and the
three-source clean loop are the fast gates. Genuine B2/driver checks and broader
native/self-hosting gates run only after a promising candidate passes the screen.

## Reproduction

From the repository root:

```sh
python3 selfhost/tools/performance/phase32/bounded-run.py \
  --seconds 180 --rss-mib 2048 --available-mib 4096 \
  selfhost/build/phase76/NEW-build-guard taskset -c 3 \
  /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/development/workflow.mjs run \
  selfhost/tools/performance/phase76/development.json \
  selfhost/build/phase76/NEW-compiler
```

`prepare-bootstrap.py plan ATTEMPT OUT --admission ADMISSION` freezes genuine B2
formation and eight driver observations. Its generated `run.sh` uses bounded
processes. The admission must identify the actual frozen driver and export set.
`prepare-compilation-v2.py --help` binds that checked attempt, B2 image pins and
independently executed candidate/reference C acquisitions. `pair-compilation-v2.py`
combines two such plans into 45 fresh requests: old/new B1/B2 plus TypeScript,
three sources and three rotated/reversed rounds. Run `compilation/run.py` on the
new plan with `--group prepare`, then `--group clean`. Profiles are separate jobs.

B1 is the upstream-bootstrapped checked equality-derived compiler; B2 is its
genuine self-emitted JS compiler image. Both compile Bend to C. Request clocks
exclude API imports, explicit Bend Base preparation, Clang and program execution;
TypeScript checks Base inside its request. Backend products are disabled.
Every request checks the complete C output against its own executed oracle.
Do not substitute a warm/cache-assisted ratio or call B2 a C executable.

`word-controls-v3.mjs API CAPTURED_BODY FRESH_OUT` checks all 0–32 bit-prefix
depths with inherited/distinct defaults, word reconstruction and an independent
interpreter; it also checks alpha-binding identity and private-input refusal.
The earlier controls preserve the discovered capture bug on candidate05.
`selection-word10.json` selects U32/F32 literals, partial words, default tails,
NaN/inf coverage identity and sharing from unchanged upstream tests.

`compare-native.py` and `coverage/compare.py` rotate saved old/candidate/upstream
executables with equal input cycles and work counts. They verify digests before
accepting timing samples. The initial numeric slowdown did not reproduce in the
next short screen; retain both, and use the larger paired gate for decisions.
The saved-C alignment probe is diagnostic only; no layout attribute is adopted.

`diagnose.py`/`diagnose02.py` freeze observational B2 derivatives and require exact
original C output. Their timings include observer overhead and are never clean
speed claims. The second captures the expanded ordinary character pattern that
motivated this change. No production rule recognizes its source function name.

The qualification preparer writes explicit self-check, fixed-point and deferred
release commands. A prepared command is not a passing result. Installation comes
after correctness, runtime, measured speed, source identity and lineage review.
The implementation report records selected and rejected experiments and links the
content-addressed evidence, including failed builds and controls.


The selected-source controller is `qualify12.py`, followed by
`qualify12-integration.py`. The latter stopped at a missing C-identity metadata
sidecar, before those targets ran. `qualify12-final.py` resumes the remaining gates
in a fresh `compiler12-C-identity12b` directory after recording that sidecar.
Controllers refuse reused output paths and preserve logs.
They do not install. `decide-release.py` verifies the completed evidence;
`install-selected.py` requires its recorded selection and verifies seven-file
release preservation after the deferred install/smoke commands. The integration plan has explicit deferred release commands;
run those only after reviewing completed qualification. `summarize.py` requires
all 45 requests and exact twelve-program identities before emitting measurements.
The paired-plan v2 gives every role its own cache-free project copy; v1 failed on
an already populated old cache and is retained as a failed method.

`seal.py` deduplicates all phase raw evidence and methods after target writers
close. `restore-evidence.py EVIDENCE NEW_DIRECTORY` verifies the parts, restores
content and modes. Historical phase inputs/upstream/toolchains are external.
Do not write additional target output into this phase after sealing.
