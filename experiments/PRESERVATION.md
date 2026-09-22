# Phase 4 preservation audit

Audit cutoff: 2026-09-22, approximately 17:30 UTC. This records preservation state separately from correctness and performance decisions. Root handles commits; uncommitted evidence must be included in the next checkpoint before it is called durable repository history.

## Newly preserved small sources

The [preservation archive](../implementation/phase4/preservation-evidence/manifest.json) contains 123 references to **48 distinct compressed objects (81,836 bytes)**. Identical bytes are deduplicated, while every experiment group retains its original path and identity.

- Stability and rejected weak-head memo: historical consumed-tool copies for counter and comparison runs. Each recovered file was checked against the corresponding consumed SHA recorded in the already tracked report.
- Boolean matcher experiment: preparation copies and comparison copies are separate groups. Both are checked against their own recorded input/snapshot identities, including the then-consumed canonical calls/runtime sources. A later private-call fix cannot silently replace these versions.
- Rejected ordinary uncurrying: the original pre-duplicate-guard transform matches the rejection report's transform SHA. Other preparation copies are archived but explicitly labeled with **archive identity only**, because preparation never produced a completed input report.
- Three initial stability failure logs: zero eligible tokenizer sites, cross-module partial-function branding comparison, and an incorrect assertion that a partially applicable value must throw. The logs remain failures; later successful gates do not relabel them.

The prior stable/weak-head JSON reports already embed complete observations, counters, resource measurements and checked provenance, but their consumed-source snapshot paths previously pointed only into ignored build directories. These small source objects close that replay gap.

## Other important current evidence

- The private full-source `F is not defined` failure is retained in [private-scope-evidence](../implementation/phase4/private-scope-evidence/manifest.json), including original call-transform bytes, image manifest and failed execution result. Its independent fix belongs to P4-016; a failed run supplies no full-source speed result.
- P4-015 has [its own archive](../implementation/phase4/private-con-arms-evidence/manifest.json), original failed test, corrected selected tests, counters, exact pilot outputs and pre-fix consumed canonical helper copies. It is rejected for insufficient repeatable benefit.
- Final checked source/proof/frontend data are preserved by [final-source](../implementation/phase4/final-source.md); native selected/full-source gates and all six same-source pairs by [native-final](../implementation/phase4/native-final.md).
- P4-015 tools/reports, the P4-016 failure archive, the full-source measurement tool and the final TypeScript classifier supplement were committed in `12e1a6d`. The combined-variant tools and this preservation archive are included in the following fix checkpoint.

## Remaining limitations

The exact original standalone source of each early failed stability test/transform was not separately retained before correction. The archive preserves original stderr and identifies the remaining generated test artifacts where present, but **does not fabricate those missing source versions**. The first tokenizer failure happened before a generated test artifact existed. These are harness/prototype-development failures, not missing winning performance samples; their exact early-source replay remains unavailable.

Large generated APIs, executables, cache books and output libraries remain omitted intentionally. Their identities and generation prerequisites are in the experiment reports. Recreating a private experiment requires the matching completed/partial historical proof state, corresponding H bytes, canonical Base/runtime/host and the consumed tool version, not just today's tools. P4-015 additionally requires the recorded pre-fix control bytes. Do not represent an ignored local path or checksum alone as durable artifact storage.

## Verify and reconstruct an isolated source overlay

From the repository root:

```sh
python3 implementation/phase4/preservation-evidence/restore.py
python3 implementation/phase4/preservation-evidence/restore.py \
  boolean/preparation /tmp/phase4-boolean-preparation-overlay
```

The helper verifies all packed/unpacked hashes and restores only the selected group to a **new** directory at its original repository-relative paths. It refuses overwrite. This is a source overlay, not a complete generated compiler image or a one-command benchmark rerun. Start from the repository checkpoint containing the reports, reconstruct the archived helper layout, then follow that experiment's frozen configuration and generation procedure. Rebase historical absolute paths deliberately and retain any change in canonical source identity; do not claim byte-identical path-sensitive replay after silently changing them.

Report evidence changes as new records. Existing consumed report bytes, failed attempts and partial-proof snapshots stay unchanged.
