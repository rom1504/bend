# Runtime-classifier experiment capsule

`capsule.zip` preserves 215 original files (4,433,916 uncompressed bytes),
including plans 01–06, all consumed classifier test/method versions, the plan04
forward-reference refusal, accepted plans05/06, complete 677-result controls,
native calibration/timing, and literal-pattern QBE identity evidence. The
593,495-byte archive SHA-256 is
`3745c36012a598058f7a98f86f165ac7837dee68ef8d348331259be8ea86162c`.
Every member was reopened and compared with its original file before test
consolidation. `manifest.json` records repository-relative paths, lengths,
hashes and modes; `verification.json` records that original-file verification.

Run `python3 -B verify.py` from this directory to verify the retained capsule.
This performs no compiler or program execution. Historical methods can be
recovered using the repository-relative archive paths into a separate checkout.
Do not extract over current tests: their stable filenames now contain the
production-bound controls. Absolute paths in old receipts are historical
locations, not instructions to substitute current files for archived inputs.

The capsule retains the exact small API/native sources, generated products,
receipts and relevant host methods. External operational assets, upstream
checkout and toolchains remain dependencies identified by the archived
acquisition/build receipts; this is not a standalone compiler distribution.
Static symbol-frequency counts describe three captured function cohorts,
not dynamic execution frequencies. The 10.85× result is classifier throughput,
not a whole-compiler gain. The compact literal version emitted byte-identical
1,188,233-byte QBE to the measured explicit-pattern version.

The current reusable finite controls are documented in
[`runtime-classifier.md`](../../../../selfhost/tests/phase147/runtime-classifier.md).
Production integration identity is recorded separately in
`selfhost/build/phase147/integrated-source03/classifier-literal-bridge.json` and
the Phase147 report. Those later integration records are outside this capsule.
