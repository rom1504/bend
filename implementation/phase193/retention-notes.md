# Phase193 retention result

**Completed after coordinator review.** All 109 reviewed assembly files were archived, verified and pruned. Observed free-space recovery was 195,670,016 bytes (186.61 MiB); compressed archives occupy 24,034,417 bytes. The minimum observed free space was 5.306 GiB, above the 5 GiB reserve. The shared lock inode remained 74853709. See `retention-result.json` for the pinned execution report and identities.

The file-level plan lists 109 exclusive regular `.s` files in 19 sealed, completed Phase190/191 roots. Gross release is 228,032,512 bytes (217.47 MiB). Streaming compression measurement estimates about 194.27 MiB net after new archives and the retained complete 411,108-byte assembly restore witness. Tar headers/receipts and concurrent writers make actual free-space change differ.

Each root is newly archived with existing `close.capsule`, reopened and hash-verified in full, then verified with `archive-v02.verify`. The first complete small assembly is restored into isolated retained scratch and hash/mode-checked. Only the exact reviewed assembly set is passed to `archive-v02.apply`, with its durable intent and unlink journal. All archives and reports remain. This provides byte-exact local recovery, not an independent backup.

All Phase192 artifacts remain hot. All nonselected files in Phase190–192, including compiler images, objects, APIs, source snapshots, profile evidence, runtime/sample binaries and metadata, are authenticated before and after. Current manifest/native-build JSON pins are included. No API deletion, target runs, directory deletion or lock replacement. The failed `phase191/loop-dev-emission01` root is excluded. Existing metadata capsules do not substitute for actual archived assembly bytes.

The method checks the unchanged shared Phase32 lock and the 5 GiB reserve plus bounded worst-case capsule scratch; it stops on stale identities, metadata, lifecycle closures or output reuse. The committed lifecycle and historical closure files are preserved unchanged. Historical assembly-consuming audit/rebuild recipes must restore archived files before replay; no claim is made that archived paths remain immediately consumable.

Reviewable root allocations:

| Root | Files | MiB |
| --- | ---: | ---: |
| `phase190-baseline-emit02` | 6 | 4.34 |
| `phase190-caller-emit01` | 6 | 3.94 |
| `phase190-candidate-emit01` | 6 | 4.28 |
| `phase190-final-emit01` | 6 | 3.90 |
| `phase190-joint-emit01` | 6 | 4.00 |
| `phase190-local-emit01` | 6 | 3.92 |
| `phase190-native-image01` | 1 | 73.14 |
| `phase190-operand-emit01` | 6 | 4.03 |
| `phase191-address-dev-emission01` | 8 | 4.96 |
| `phase191-address-dev-emission02` | 8 | 4.96 |
| `phase191-aligned-mini-emission01` | 3 | 2.46 |
| `phase191-both-dev-emission01` | 8 | 4.96 |
| `phase191-both-dev-emission02` | 8 | 4.96 |
| `phase191-call-dev-emission01` | 8 | 4.75 |
| `phase191-extra-dev-emission01` | 8 | 4.91 |
| `phase191-frame-mini-emission01` | 3 | 2.46 |
| `phase191-loop-dev-emission02` | 8 | 4.98 |
| `phase191-native-image01` | 1 | 74.05 |
| `phase191-select-mini-emission01` | 3 | 2.46 |

The coordinator executed this exact command from the repository root (do not rerun against the consumed output):

```sh
python3 -B selfhost/build/phase193/retention-method.py --approved-proposal-sha256 b62eca42440e1e1abd5da7cc3995c490c52255b5ce7c31a0b5b00354921cc451
```

The exact selected paths/hash/mode/inode records remain in the immutable reviewed `retention-plan.json`; its original `executed: false` records proposal-time state. Completed execution evidence is in `selfhost/build/phase193/retention-apply01/report.json` and the concise `retention-result.json`. No target jobs ran.

The method is preserved byte-for-byte at `selfhost/tests/phase193/retention-method.py`. The executed build-path method and its original execution identity remain unchanged; the copy has the same SHA-256 `ea85cb36b0fe639fc8c7f9c8f7a27fdfa47dce0926c2f8065bece26b6605bab3`. No further cleanup was performed.
