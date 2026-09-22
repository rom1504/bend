# Phase 4 preservation index

Updated through **P4-026**, 2026-09-22, approximately 20:11 UTC. Preservation is
separate from correctness, performance and promotion. New files become durable
history with the root's checkpoint; an ignored build path or checksum alone is
not stored evidence.

## Recover the exact artifacts

| Need | Durable entry | What restoration means |
| --- | --- | --- |
| Checked source, B1, H and runtime | [Final source capsule](../implementation/phase4/final-source-capsule/README.md) | Exact assembled source, **63-export** checked B1, equal stage2/stage3 H and paired runtime. This is not the separate normal 54-export development API. |
| Default and named-profile private images | [Private image capsule](../implementation/phase4/private-final-images/README.md) | Exact `scope-fixed` and `profile-combined` images, original manifests, host/helper and runner bytes. Keep the source capsule beside it: four objects are shared. Mutable caches and measurements are separate. |
| Experimental B1 equality derivative | [P4-024 selected archive](../implementation/phase4/b1-native-equality-evidence/README.md) | Actual original/derived APIs, test variants, selected observations, outputs, validated caches and consumed tools. The derivative remains `newBootstrap:false`. |
| P4-024 complete frontend and full-source gates | [Frontend archive](../implementation/phase4/b1-native-equality-frontend-evidence/README.md), [full-source archive](../implementation/phase4/b1-native-equality-full-evidence/README.md) | Complete raw results, failures, real histories, actual emitted H, original proofs/source and audited consumed inputs. Both archives verify actual member paths and bytes. |
| Earlier private helper versions | [Preservation objects](../implementation/phase4/preservation-evidence/manifest.json) | 123 historical references to 48 deduplicated small source objects, including pre-fix versions. Exact scope and unresolved gaps remain below. |
| Rejected substitution workers, P4-025 | [P4-025 objects](../implementation/phase4/private-substitution-evidence/README.md) | 142 labels / 70 objects preserve all three controls, comparison, original/candidate images and historical test-source revisions. Rejection remains a rejection. |
| Controlled full-source B1 equality comparison, P4-026 | [Comparison archive](../implementation/phase4/b1-native-equality-full-comparison-evidence/README.md) | 259 historical file identities / 120 objects preserve all four successful runs, actual H outputs, configurations, equal Base payloads, original checked provenance and immutable preregistration. The independent audit verifies actual restored bytes and both paired reductions. |

From the repository root, the two portable capsule extractors verify their
compressed and restored hashes, sizes and historical proof inventories before
writing a **new** destination:

```sh
python3 implementation/phase4/final-source-capsule/extract.py --verify-only
python3 implementation/phase4/final-source-capsule/extract.py /tmp/phase4-source-NEW
python3 implementation/phase4/private-final-images/extract.py --verify-only
python3 implementation/phase4/private-final-images/extract.py /tmp/phase4-private-NEW
```

For object archives, choose the desired `files` entry in its manifest, verify the
compressed object's recorded hash, decompress it, then verify restored SHA and
length before use. P4-024's measured candidate is the entry for
`prepared/candidate.mjs`, **not** `candidate-test.mjs`. For tar archives, follow
the manifest's exact member paths and hashes. Extract into a fresh directory;
do not overwrite existing artifacts or rewrite historical reports.

The early source-overlay restorer remains available:

```sh
python3 implementation/phase4/preservation-evidence/restore.py
python3 implementation/phase4/preservation-evidence/restore.py \
  boolean/preparation /tmp/phase4-boolean-overlay-NEW
```

It restores only that group's repository-relative helper layout, not a complete
compiler image or a benchmark environment.

## Recover observations and replay histories

- [Final source proof](../implementation/phase4/final-source.md) and
  [canonical private integration](../implementation/phase4/private-profile-integration-evidence/manifest.json)
  retain checked provenance, exact image gates and the actual unit/guard results.
- [Final private frontend](../implementation/phase4/private-frontend-final-evidence/README.md)
  retains four raw reports and 176 actual persistent histories.
  [Full-source private observations](../implementation/phase4/private-full-final-evidence/manifest.json)
  and [small comparisons](../implementation/phase4/private-final-small-evidence/manifest.json)
  retain their own consumed versions, outputs and limitations.
- [P4-021 scheduling](../implementation/phase4/frontend-scheduling-evidence/README.md)
  preserves focused runs, loaded/idle serial controls, both four-worker runs,
  failed reproductions, frozen harness/cache and every actual history. Its speed
  claim concerns additional CPU resources; known conformance failures remain.
- [Native final](../implementation/phase4/native-final.md),
  [native frontend feasibility](../implementation/phase4/native-frontend-evidence/manifest.json)
  and [rejected native annotation](../implementation/phase4/native-annotation-evidence/manifest.json)
  retain checked build/config/source evidence and declared omissions. Native
  executables and toolchains are not generally bundled; use their recorded
  generation prerequisites rather than substituting an unrelated binary.
- [Residual profiles](../implementation/phase4/residual-profile-evidence/README.md)
  preserve diagnostic evidence separately from uninstrumented measurements.
- The [19:36 local-link audit](../implementation/phase4/evidence/link-audit-20260922-193625-preservation.json)
  preserves the exact script and report for 94 documents / 416 local targets,
  with zero broken targets **at that time**. It says nothing about later edits.

Restoring evidence creates no new checked build, relocated proof or conformance
pass. Exact historical execution needs the recorded Node/toolchain, canonical
source and Base identities, matching runtime/host/helpers, requested export
roots and validated cache policy. The capsule records pinned upstream revision
`6018e28ecc67cf1fffc0c20c64b11023474c2df8`; the checkout and external executables
remain prerequisites. Keep failed requests and the whole preceding worker
history for replay, not only the last request. If paths or inputs change, record
a new configuration/run and let identity checks reject an unsupported exact
replay. Changed Bend source requires a fresh checked build.

## Historical gaps stay explicit

The initial preservation archive separates preparation and comparison tool
versions and retains hash-matching historical copies for stability, rejected
weak-head memo and Boolean experiments. Rejected ordinary uncurrying includes
its original transform; additional preparation files lacking a completed input
report are labeled **archive identity only**.

The exact standalone sources for three early stability harness failures were
not saved before correction. Original stderr and surviving generated test
artifacts are retained, but the first tokenizer failure predates any generated
test. Those exact early-source versions remain unavailable; later tools do not
retroactively repair their provenance.

The [full-source lexical-capture failure](../implementation/phase4/private-scope-evidence/manifest.json)
retains the old call-transform/image metadata and `F is not defined` result;
it is no speed result. [P4-015](../implementation/phase4/private-con-arms-evidence/manifest.json)
retains its failed test, later controls and pre-fix consumed helpers. Final
capsules now preserve large winning compiler images that the early overlay
archive intentionally omitted, but they do not fill every older generated-image
or native-binary gap. Consult each manifest's included objects and omissions.
No missing historical source, artifact, failure or proof state is fabricated.
