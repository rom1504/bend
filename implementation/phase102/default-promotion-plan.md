# Candidate04 default promotion: prepared commands

This is preparation, not a promotion receipt. The authorized target is
`projection-cost-source01/compiler.bend`, SHA256
`63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237`:
39,372 physical lines, 582 above Phase98. Candidate03, its admission, staged
capsule and source profile remain unchanged. Root owns all compiler/program
execution and the final performance decision. Production usage docs remain on
the completed candidate03 state until candidate04 receipts are available.

## Before replacement

Complete genuine native chain04 and all original qualification gates for this
source. Preserve failed/interrupted attempts. Its admission must be complete,
qualified and source-exact. Separately assess the fresh corrected application,
runtime and compiler screens, then write the coordinator acceptance receipt:

```json
{
  "kind": "phase102-native-performance-acceptance",
  "complete": true,
  "accepted": true,
  "inputsUnchanged": true,
  "source": {"file": "EXACT_ADMISSION_SOURCE_PATH", "sha256": "63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237", "bytes": 1788947},
  "evidence": [{"file": "COMPLETED_REPORT_PATH", "sha256": "REPORT_SHA256", "bytes": 0}],
  "decision": "Coordinator conclusion with the actual measured gains, remaining regressions and scope."
}
```

Use real absolute pins from the completed receipts; the JSON above is a schema,
not evidence. The promotion method requires exact source equality, authenticates
all evidence pins, and checks `complete`/absence of `error` on JSON reports. This
records root's decision; it adds no statistical or universal performance proof.

From the repository root, assign the actual acceptance path and use fresh outputs:

```sh
P102_CHAIN=selfhost/build/phase102/native-chain04
P102_RELEASE=selfhost/build/phase99/phase102-release04
P102_ACCEPT=selfhost/build/phase102/promotion04/performance-acceptance.json
P102_PROMOTE=selfhost/tools/performance/phase102/promote-default.py

python3 -B selfhost/tools/performance/phase99/release/prepare.py selection --admission "$P102_CHAIN/admission.json" --out "$P102_RELEASE/selection.json"
python3 -B selfhost/tools/performance/phase99/release/cli-controls.py "$P102_RELEASE/selection.json" "$P102_CHAIN/controls/report.json" "$P102_RELEASE/public-cli"
python3 -B selfhost/tools/native/assets.py seal "$P102_RELEASE/selection.json" selfhost/tools/native/releases/phase102-staged04
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase102-staged04/receipt.json --verify-only

taskset -c 0 python3 -B "$P102_PROMOTE" check \
  --selection "$P102_RELEASE/selection.json" --cli-report "$P102_RELEASE/public-cli/report.json" \
  --capsule selfhost/tools/native/releases/phase102-staged04/receipt.json \
  --performance-acceptance "$P102_ACCEPT" --out "$P102_RELEASE/promotion-check"
```

The public CLI performs the unchanged nine controls, with unique expected case
names. The check method authenticates both stages, the exact source, CLI inputs,
all capsule members and the coordinator acceptance. It refuses a default pointer
whose SHA256 differs from
`0ec0287c1c5e0b877b16a10e451bce4eb1fffa7b3795fcf634d742ea50772fdf`.
It does not mutate the selection or execute a target.

## Root-controlled atomic replacement and actual default smoke

Only root runs `apply`, after checking the completed receipts and acceptance:

```sh
taskset -c 0 python3 -B "$P102_PROMOTE" apply \
  --selection "$P102_RELEASE/selection.json" --cli-report "$P102_RELEASE/public-cli/report.json" \
  --capsule selfhost/tools/native/releases/phase102-staged04/receipt.json \
  --performance-acceptance "$P102_ACCEPT" --out "$P102_RELEASE/promotion"

python3 -B selfhost/native.py selfhost/tools/performance/phase77/fixtures/small.bend -o "$P102_RELEASE/default.c" > "$P102_RELEASE/default.stdout" 2> "$P102_RELEASE/default.stderr"

taskset -c 0 python3 -B "$P102_PROMOTE" verify-smoke \
  --promotion "$P102_RELEASE/promotion/report.json" \
  --stdout "$P102_RELEASE/default.stdout" --stderr "$P102_RELEASE/default.stderr" \
  --output "$P102_RELEASE/default.c" --out "$P102_RELEASE/default-smoke"

python3 -B selfhost/tools/native/assets.py seal selfhost/tools/native/selection.json selfhost/tools/native/releases/phase102-assets04
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase102-assets04/receipt.json --verify-only
```

`apply` repeats every preflight, exclusively saves the old pointer bytes/mode,
rechecks both pointers immediately before replacement, uses `os.replace`, and
authenticates both newly selected stages afterward. Its receipt binds the
performance acceptance. It changes only the stable selection. The following
smoke uses the public entry without `--selection`; its collector verifies the
stable-pointer binding, complete cached-small C/diagnostic, successful bounded
process, output and raw request pins. The stable capsule is separately necessary:
the staged capsule preserves only the staged pointer path. Verification with
zero missing files is not an actual missing-file-restoration test.

## Final docs and incremental evidence

After receipts exist, update `NATIVE_PHASE102.md`, current README links and the
Phase102 report with the actual default, source/profile04, B1/B2 identities,
CLI/default-smoke results, stable capsule and measured acceptance. Preserve the
old Phase98 guide, audited docs, original profiles/capsules and candidate03
receipts. Do not edit consumed `profile.py`, `launch.py`, or qualification methods.

After all writers stop, assign `P102_DEFAULT_REQUEST` to the exact native
`request.file` recorded by `default-smoke/report.json`. Then archive only the
new or changed evidence:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase102/archive-incremental.py seal --frozen \
  --cli-report "$P102_RELEASE/public-cli/report.json" --request-report "$P102_DEFAULT_REQUEST" \
  --include selfhost/tools/native/releases/phase102-staged04 \
  --include selfhost/tools/native/releases/phase102-assets04 \
  --include selfhost/tools/native/profiles/phase102-lowering04 \
  --include selfhost/tools/native/selection.json \
  --include README.md --include selfhost/README.md --include docs/self_hosted/NATIVE_PHASE102.md \
  --include implementation/phase102/README.md --include implementation/phase102/native-release-plan.md \
  --include implementation/phase102/default-promotion-plan.md \
  --out implementation/phase102/evidence04
taskset -c 0 python3 -B selfhost/tools/performance/phase102/archive-incremental.py verify implementation/phase102/evidence04/receipt.json
```

The method authenticates the existing 82,830,600-byte archive, its exact receipt
and manifest, without copying them. It hashes the current inventory against that
manifest and stores only added/changed paths. The original archive retains old
versions; absent live baseline files are listed without deleting history. Both
new Phase102 build trees and `promotion04/storage.json` are included. Only the
explicit CLI/default request directories are added from native request history.

Compression streams directly into parts capped at 80 MiB, with a 160 MiB disk
reserve; there is no temporary full archive or duplicate split copy. Every member
and part is verified, including file modes and hardlinked input files. Five tiny
stream controls pass in `incremental-archive-method01/report.json`; five more
delta controls in `incremental-archive-method02/report.json` verify unchanged
path omission, added/modified inclusion, baseline preservation and full readback.
No production incremental archive or pointer replacement was executed while
preparing this plan. Preserve partial output if a guard/check fails; never report
an incomplete archive or promotion as complete.
