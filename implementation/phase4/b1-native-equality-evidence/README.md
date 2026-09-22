# P4-024 selected evidence

`manifest.json` preserves 101 files in 47 deduplicated gzip objects (783,413 bytes), including the actual unmodified control and derived candidate APIs, test-only variants, helper observations, all 12 selected process results, host adaptations, exact emitted outputs, separately validated Base caches, and consumed tools. Verify each compressed SHA, then the restored SHA and byte length. Historical absolute paths are retained; restoration is not a new checked bootstrap or a relocation of its proof.

`preparation.json` and `pilot.json` are readable copies of the complete selected reports. External upstream/Node/source prerequisites remain explicitly identified in the manifest. The original checked-source capsule is separate.

`frontend-independent-review.json` is a later, separate read-only audit of the full derived frontend gate: 2,756 exact raw observations/verdicts, 45 session histories, replay digests and recorded provenance. It adds no compiler execution or performance observation. Its inputs identify the separate complete frontend archive owned by that gate's runner.
