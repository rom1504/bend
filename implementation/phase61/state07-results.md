# State07: defer the backend telescope cursor

The early B1 comparison did not show a useful improvement. The three-source confirmation's equal-source geometric mean was **1.01023× State06 elapsed time**: 1.02% higher. The backend telescope cursor is therefore deferred before spending work on B2 generation and broader qualification. This does **not** establish a B2 regression or isolate the cursor's effect: State07 combined the cursor with the two-line leaf-substitution change.

The roles are genuine checked B1 images, State06 `61761c02…` and State07 `e334010c…`, using the same direct output backend and private Base preparation. They are not the self-hosted B2 compiler images. Fresh preparation captures canonical workflow `cdd71b72…`; reviewed method05 remains unchanged. Each sample measures compiler/driver import, API load and one ordinary library request; full raw output bytes are compared afterward. There are no warm requests or TypeScript role.

| Confirmation input | State06 B1 ms | State07 B1 ms | New / old |
|---|---:|---:|---:|
| Numeric | 604.230 | 599.080 | 0.99148× |
| Map/Set | 2,191.590 | 2,264.589 | 1.03331× |
| Active raytrace | 1,365.984 | 1,374.666 | 1.00636× |

The [confirmation](../../selfhost/build/phase61/state07-b1-latency01/confirm60/report.json) used two fresh processes per role/input, 12 workers total, and completed in 21.870 s. Numeric ranges were 596.974–611.487 ms old and 597.878–600.282 ms new; Map/Set 2,188.445–2,194.736 versus 2,262.737–2,266.440 ms; raytrace 1,365.477–1,366.491 versus 1,374.547–1,374.785 ms. Compile-only geometric mean was 1.01040× old. These are observed ranges from two rounds, not confidence intervals or a significance test.

The preceding [two-input screen](../../selfhost/build/phase61/state07-b1-latency01/screen20/report.json) used four workers and completed in 7.713 s. Its combined ratio was 1.00769× old. Screen and confirmation remain separate; no rows were pooled. [The saved-data derivation](../../selfhost/build/phase61/state07-analysis01/report.json) rechecks worker receipts, actual image identities, complete output bytes and all reported medians/ratios.

Correctness evidence remains positive and preserved: both checked attempts have 36 matching focused outcomes; [leaf substitution](../../selfhost/build/phase61/leaf-controls-state07/report.json) passed 14 controls; [the backend cursor](../../selfhost/build/phase61/backend-telescope-state07/report.json) passed 24 cases and one bridge. Deferral is an efficiency decision from the combined B1 screen, not a semantic failure.

The selected next experiment retains the two-line leaf change, reverses the cursor's four call sites, manifest entry and 34-line helper, and adds the separately registered [P61-010 prefix-maximum reuse](../../experiments/phase61/P61-010-prefix-maximum-reuse.md). State08 was building when this note was written; no State08 result is asserted here. All State07 sources, controls and raw measurements remain retained.
