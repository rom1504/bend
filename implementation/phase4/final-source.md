# Final combined source: proof and frontend validation

The combined guarded-book and constructor-telescope source completes the checked JavaScript self-hosting fixed point. The full upstream frontend sweep also preserves all **2,756 prior observations**, including exact diagnostics: **zero behavior changes, zero new differences and zero resolved differences**. The same 560 differences from the live pinned TypeScript compiler remain.

This is correctness evidence for the final source. It does not establish full language conformance or a controlled frontend speed comparison.

## Frozen identities

| Artifact | SHA-256 |
| --- | --- |
| Assembled source | `34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122` |
| Checked B1 API | `0653f21e7e227bf7bf7e3ad777630da64d520534753900636a571ed57a43f810` |
| Stage2 and stage3 H | `b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8` |
| Runtime | `26f5eee2f54b194b64f768df6ff505c67bf7a5df2159aa06caf53ecba54e910b` |
| Canonical pinned Base | `b8c2734d45ec6b4ce70fee70ff06ef35e08fce885af8852d8eb77dbff020e946` |

The [checked build](final-source-evidence/checked-build.json.gz) ran loading, type checking, ownership and unresolved-hole checks through untouched upstream revision `6018e28ecc67cf1fffc0c20c64b11023474c2df8`. Every requested API root existed. Independent verification rehashed all 59 frozen module copies and their current production counterparts, assembled source, API, runtime, Base and frozen proof helpers. All match their recorded identities.

## Checked self-reproduction

The proof ran on CPU 2 from 16:23:30 to 17:01:13 UTC with Node v24.18.0, a 4 MiB V8 stack, 12 GiB heap, 8 MiB OS stack and a one-hour deadline per stage. Both stages use the same physical assembled source and canonical pinned Base, unchanged runtime and frozen driver.

| Checked stage | Compiler input | Complete stage wall | Result |
| --- | --- | ---: | --- |
| Stage2 | Checked B1 API | 670.766 s | 1,143,517-byte JavaScript library |
| Stage3 | Stage2 H API | 1,591.343 s | Identical 1,143,517-byte library |

Both processes exited zero without signals; each stage verified its consumed inputs. Independent inspection compared the actual stage files byte-for-byte, not only their reported hashes. The [completed proof report](final-source-evidence/fixedpoint.json) and [verification record](final-source-evidence/verification.json) retain those checks. The actual checked B1, equal H stages, assembled source and runtime are now preserved in the separately versioned [final-source capsule](final-source-capsule/README.md), with exact hashes and a verify/extract tool. Extraction reuses historical checked bytes; it does not claim a new bootstrap or relocate proof paths.

These are completed proof-stage observations, not a repeated causal performance comparison with the old source. The separate [final TypeScript measurements](typescript-final.md) and [native comparison](native-final.md) describe their own resources and controls. The native compiler's full-source JavaScript emissions match these exact H bytes; no native-code fixed point is claimed.

## Full frontend sweep

The final checked B1 and live pinned TypeScript compiler each executed parse and check probes for all **1,378 upstream fixtures**, or **2,756 observations per compiler**. The harness used CPU 1, one persistent worker, recycling after 64 requests, a 4 MiB stack, 4 GiB heap/RSS limit and a 300-second per-probe timeout. Each compiler used 44 worker starts with zero worker failures or timeouts. Fixture, adapter and consumed artifact identities remained unchanged.

| Comparison with the complete Phase 3 observations | Count |
| --- | ---: |
| Candidate behavior or exact diagnostic changes | 0 |
| TypeScript reference changes | 0 |
| Current candidate/reference differences | 560 |
| Newly introduced differences | 0 |
| Resolved differences | 0 |

The existing mismatches include acceptance/phase differences and diagnostic text differences. They are retained in full. Harness verdicts remain 1,920 pass, 459 observed and 377 fail for B1; the reference has 2,294 pass, 459 observed and 3 fail. Completing the observation inventory must not be mistaken for passing every oracle or achieving full conformance.

The archive includes [both complete reports](final-source-evidence/archive-manifest.json), [the exact comparison](final-source-evidence/frontend/comparison.json.gz), and their historical comparison inputs. The independent verifier reconstructs observation keys and compares status, phase, checked flag, exit code, signal and exact diagnostic/output text. It also rechecks actual fixture and artifact hashes.

No frontend timing ratio is claimed. These serial workflow observations were not interleaved repeated benchmarks, and an unrelated audit briefly shared CPU 1 from **16:53:08.193 to 16:53:11.397 UTC (3.204 s)**. The raw execution report retains the original wall observations without adjustment. This overlap does not alter the completed correctness observations.

To repeat the lightweight evidence check from the repository root, run `python3 implementation/phase4/final-source-evidence/verify.py` while the frozen build artifacts are present. The [archive manifest](final-source-evidence/archive-manifest.json) records original and compressed hashes; bulky reports use deterministic gzip compression.
