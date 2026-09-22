# Controlled whole-source B1 equality comparison

The exact B1 String.eq derivative passes the preregistered whole-source comparison: **46.04% less mean process time** and **46.13% less mean request time**, with both opposite-order pairs exceeding the 5% threshold. All four fresh processes fully check the same compiler source and emit the actual expected H bytes. The independent audit passes with no errors.

[P4-026](../../experiments/phase4/P4-026-b1-full-source-comparison.md) remains the unchanged plan recorded before execution. This comparison tests checked B1 `0653f21e…` against its guarded derivative `e95e1198…` on final compiler source `34c6ef63…`. It excludes the earlier [single whole-source correctness observation](b1-native-equality-full.md) from all paired statistics.

## All observations

| Order | Variant | Process seconds | Request seconds | Maximum child RSS (KiB) |
|---|---|---:|---:|---:|
| 1 | Original checked B1 | 628.273 | 626.995 | 2,753,124 |
| 2 | String.eq derivative | 339.318 | 338.047 | 2,647,104 |
| 3 | String.eq derivative | 340.665 | 339.421 | 2,516,800 |
| 4 | Original checked B1 | 631.779 | 630.516 | 2,492,756 |

The control/candidate pair reduces process time **45.9919%** and request time **46.0846%**. The candidate/control pair reduces process time **46.0784%** and request time **46.1678%**. No observations were omitted, substituted, retried or deadline-killed.

The two-sample process means (also the two-point medians) are **630.026 seconds → 339.992 seconds**; request means are **628.756 → 338.734 seconds**. Maximum child RSS averages **2,622,940 → 2,581,952 KiB**, 1.56% lower. Memory did not improve in both pairs: the second candidate uses slightly more than the second control. These are observed process peaks, not total machine memory or a universal memory improvement.

## Controls and independent audit

All fresh processes run on physical CPU2 with Node 24.18.0, a 4 MiB stack and 12 GiB heap limit, using the same frozen worker, host, source, runtime and canonical pinned Base. The variant-specific Base caches were previously validated by `check_book`; both decoded payloads are structurally identical with SHA-256 `3e540547f0abcda6a28582a27b4b3fa5bfebfe4dbd80f77fd4ed8129499797a1`. Cache bytes and all consumed inputs pass before/after identity checks. No cache priming occurs inside the observations.

Every row returns `status:ok`, `phase:compile`, `checked:true`, identical result fields and actual emitted bytes equal to the completed fixed point H `b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8`. The candidate is reconstructed from the exact original B1 under whole-image and helper-body guards; it is a derivative of that checked artifact, **not a new bootstrap**.

The campaign starts at 19:36:13.627 UTC and finishes at **20:08:44.023 UTC** on 2026-09-22, before the unchanged 20:09 deadline. Each child is limited to 900 seconds, capped by that absolute deadline. Process wall includes worker startup, verification and output publication; request wall measures the host compilation request. No other intentional compiler workload overlaps the observations. OS caches are not flushed; ordinary operating-system, documentation and archival activity remain possible. Two samples per variant do not establish a confidence interval, portability across machines, or equal improvements on other workloads.

The independent auditor verifies raw results, actual output bytes, opposite-order row identities, commands/configs, frozen file hashes, Base payload equality and paired arithmetic. Its [archive](b1-native-equality-full-comparison-evidence/README.md) contains **259 file identities and 1,526,385 compressed bytes** in deduplicated gzip objects, including actual API/source/H/runtime/cache/tool bytes and all four observations. Every compressed object was reopened and compared with its original bytes. The Node executable is an identified external prerequisite. [Audit](b1-native-equality-full-comparison-evidence/audit.json) and [unaltered comparator report](b1-native-equality-full-comparison-evidence/comparison.json) preserve full precision and historical absolute paths. The archive does not rewrite proof paths or fabricate a relocatable bootstrap.

The auditor's eight focused tests cover missing/malformed reports, active writers, duplicate and wrong-image observations, false success, invalid metrics and honest deadline retention; [their recorded output](evidence/b1-full-comparison-audit-tests.tap) is separate from compiler execution.

## Decision and limits

The controlled exact-artifact whole-source performance hypothesis passes. This strengthens the earlier [909 helper controls, selected compilation pilot and complete frontend preservation](b1-native-equality.md); it does not remove the known 377 strict frontend failures or prove full conformance. The original checked B1, normal development API, public H, distributed default compiler and upstream compiler remain unchanged. Generated H bytes are identical, so this is faster compiler execution, not faster execution of emitted user programs. Adoption for future source revisions requires a fresh guarded/checking workflow; this experiment does not authorize a generic unverified rewrite.
