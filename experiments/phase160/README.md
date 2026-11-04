# Reproduce Phase160

Start from `e2b707d` plus this phase on `selfhost/bootstrap`, with the pinned
Phase152/153/156/157/158/159 assets. The result is a research-only complete
compiler-request comparison. Production selection stays unchanged.

The [report](../../implementation/phase160/README.md),
[metrics](../../implementation/phase160/metrics.json) and
[profile summary](../../implementation/phase160/profiles.json) name the exact
run directories. Each guard `process.json` contains its complete command and
resource budgets; each target report binds executable, source/Base, runtime,
method and independent output identities. Replays use fresh output names.

## The decisive comparison

The frozen C executable is
`selfhost/build/phase160/request-c02/program` (SHA256
`d202c5c3e3973d4f08c10315a04058d43e8efff2b7b4e8ded814918f671da95f`).
The QBE executable is
`selfhost/build/phase156/request-prepare01/native/program` (SHA256
`3d6c7ec0acf162bc5872358c9ccdbad42af3d9ada45a4dc59ceb1b3bf36ad7f9`).
Both run the same original branch with live Base, full checking and verification.

From the repository root, first run the small complete-output control:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase160/replay-map-guard \
  --run-root selfhost/build/phase160/replay-map \
  --disk-mib 8 --seconds 130 --rss-mib 2048 --available-mib 16384 --cpu 3 -- \
  python3 -B experiments/phase160/tools/boxed-requests.py \
    --out selfhost/build/phase160/replay-map --case map --roles c,qbe --seconds 60
```

Then use the same runner with `--case compiler-checker` (40MiB artifact budget)
or `--case full-compiler`. Full C and QBE run separately so a fresh118MB output
fits the disk budget. Only the C role needs the explicit larger memory budget:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase160/replay-full-c-guard \
  --run-root selfhost/build/phase160/replay-full-c \
  --disk-mib 128 --seconds 320 --rss-mib 6144 --available-mib 16384 --cpu 3 -- \
  python3 -B experiments/phase160/tools/boxed-requests.py \
    --out selfhost/build/phase160/replay-full-c \
    --case full-compiler --roles c --seconds 300
```

For QBE, select `--roles qbe`,2GiB RSS and fresh guard/run names. The one-policy
experiment substitutes `tools/gc-budget-request.py` and adds `--gc-factor 1`,
retaining the C role and6GiB limit. It explicitly records the environment
override; shell-exporting BEND variables will not work with the normal runner,
which clears them. The output oracle and all other policies stay fixed.

The runner starts a fresh process and writes a fresh file. After exit and
complete byte comparison, it records a deduplication intent and shares those
bytes with the immutable independent oracle. This happens outside timing and
never overwrites an oracle. Named output, startup and teardown are measured;
machine construction, post-return hashing/comparison and deduplication are not.

## Acquisition and independent gates

`tools/prepare-request.py` records every whitespace-only compatibility edit to
Phase156's exact checked request closure. `tools/compare-parser.mjs` independently
loads both original and normalized books with the pinned upstream parser and
compares all structural rows except source spans. Retain the original checked
API receipt; parser equality alone is not type checking.

`tools/capped-seed.py` builds the original current bendc seed C with the exact
Phase159 one-line runtime condition. `tools/probe.py` executes explicit source,
seed, Base and checked/unchecked modes. The current self-source and its imported
modules are in Phase158's `current` directory, with matching Base2.0.34. Exact
self-C checks precede using this private seed.

`tools/unboxed-off-probe.py` differs by the recorded BEND_UNBOX=0 acquisition
policy. `tools/build-boxed-request.py` builds that emitted C with pinned Clang-O2,
the private capped runtime and exactly nine effect-registration arity adapters.
Its predecessor `build-request.py` and default-unboxing `requests.py` preserve
the failed Map attempt. Do not substitute it into successful measurements.

The original commands, source dependencies, flags and output hashes for every
acquisition are retained in their guard/target reports. Emission after independent
source checking uses `--no-check` only to acquire the experimental executable;
all measured compiler requests still run their own checking/verifier pipeline.

## Profiles, source closure and restoration

`tools/prepare-profile.py` creates the exact-input manifest only after its named
complete request succeeds. The maintained profiler runs through
`experiments/phase159/tools/common-profile.py`, with the existing worker-complete
sampler. `full-profile01` at8ms is rejected for36 overruns. `full-profile02` at
100ms passes coverage/loss gates; both pass complete output checks. Profiling
uses `/dev/stdout` backed by a regular file, not the clean named-file sink.
Keep diagnostic times separate. `tools/dedup-profile.py` shares only new,
already-compared output. `tools/profile-summary.py` does not pool rejected data.

`tools/prepare-closure.py` produces the exact target-main source closure and
kept/dropped declaration/owner census. `closure-check01` is a successful
whole-book source check. Native behavior/output and smaller-input self-build
remain unmeasured. `prepare-parser.py` and `tests/phase160/parser.bend` are an
unrun fallback, not a second result.

`tools/metrics.py` regenerates the result table from the original frozen runs.
`tools/close-runs.py` classifies each finished guard; it keeps current evidence
hot for a shared exact archive. `tools/seal.py` stores each distinct byte sequence
once, with path/mode aliases in `INDEX.json`, then reopens and verifies every
payload. The committed evidence capsule includes source transformations,
generated C/images, all new outputs, raw samples, failures and retention receipts.
Prior source/images are in its pinned prerequisite capsules; host toolchains
are separately pinned external prerequisites.

Restore into absent paths only: verify archive and payload hashes, read the
alias map, write each corresponding payload and apply its saved mode. Never
overwrite existing frozen files. Historical reports bind absolute paths under
`/home/ai/bend2/build/publish/bend`; restoring elsewhere requires explicitly
rebinding fresh replay inputs, not pretending original receipts changed.

The prior disk reclamation is limited to three exact already archived Phase153
raw products. Its verification/pruning receipts are included; no phase-directory
or qualified-binary deletion was performed. Current roots remain hot and all
guards are closed; compressed evidence is committed independently of local roots.
