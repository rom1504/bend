# Candidate profile plans

`profile-current.py` now accepts the exact role name in an authenticated native program manifest. Sampler selection follows the role's `target`: C uses the pthread sampler; QBE and assembly use the retained main-thread sampler. Thirteen offline guard, role-selection and receipt controls pass. No compiler, target or profiler was run while preparing these plans.

The sixth assembly product uses a batch emission receipt, separate from its machine receipt. The adapter finds the emission receipt through pinned product inputs and verifies the exact source and emitted product row. It keeps both receipts and the source/binary pins separate. Ownership remains conditional lexical attribution; it does not claim a combined source-emitting machine receipt.

The prior adapter bytes are retained under `selfhost/build/phase186/profile-adapter-baseline01`. Historical reports still name the previous hash at the mutable adapter path; their reports have not been rewritten. The preservation receipt identifies the exact retained copy.

Preview metadata, exact method/input pins and counting rationale are in [candidate-profiler-plans.json](candidate-profiler-plans.json). Each preview directory already exists and must not be reused as an execution root. The following commands are for the coordinator's single CPU3 lane, each under a fresh 90-second guard with an 80-second whole inner deadline. Close each guard with its actual outcome afterward.

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase186/profile-sixth-ray01-guard \
  --run-root selfhost/build/phase186/profile-sixth-ray01 \
  --seconds 90 --disk-mib 128 --rss-mib 2048 --available-mib 16384 \
  --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tests/phase186/profile-current.py \
    --manifest selfhost/build/phase186/sixth-x86-build01/programs.manifest.json \
    --role p186-sixth-x86 --case variation-ray-active-256-2240 3000 \
    --out selfhost/build/phase186/profile-sixth-ray01 --seconds 80 --guarded --cpu 3
```

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase186/profile-stack-map01-guard \
  --run-root selfhost/build/phase186/profile-stack-map01 \
  --seconds 90 --disk-mib 128 --rss-mib 2048 --available-mib 16384 \
  --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tests/phase186/profile-current.py \
    --manifest selfhost/build/phase186/stack-only-qbe-build01/programs.manifest.json \
    --role p186-stack-qbe --case coverage-map-churn-128 11000 \
    --out selfhost/build/phase186/profile-stack-map01 --seconds 80 --guarded --cpu 3
```

For the retained first QBE candidate, use its exact manifest `first-qbe-build01/programs.manifest.json`, role `p186-first-qbe`, and a new output/guard name. Its map preview is already prepared. Do not rename roles to imply a compiler identity absent from the manifest.

Counts project 6.94 seconds of active-ray and 6.78 seconds of map work per capture using retained clean screen medians. One clean capture plus 8ms and 13ms sampled captures should therefore provide more than 500 samples per period while fitting comfortably within the guard. Actual quality gates, loss, CPU coverage, and temporal stability remain authoritative. The clean capture is a diagnostic budget, not a new speed-ratio comparison. These plans contain no runtime instrumentation or relinking.
