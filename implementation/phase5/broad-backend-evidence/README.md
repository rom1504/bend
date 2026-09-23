# Broad backend evidence

The archive is created only after the broad run closes. `archive.py` retains the complete run directory, preparation04, progress logs, failures and replay records, generated JavaScript/C, native binaries, frozen compiler/host inputs, genuine checked parent and separate equality derivation. Every archive member is read back and checked against `manifest.json`.

Preparations01–03 remain in [the earlier preparation archive](../broad-backend-preparation-evidence/README.md). They were not executed as broad compiler runs. Preparation04 changes the selected artifact prospectively to the maintained equality-derived compiler; it does not fabricate another bootstrap.

Recover with `cat raw.tar.gz.part* | tar -xz` into an empty directory (the ordered parts avoid repository file-size limits) and verify member SHA-256 values from the manifest. Recorded absolute paths are historical identities: reconstruct their paths for existing strict replay tools, or make a new explicitly relocated preparation. Never edit an old report to claim fresh verification. Node, Clang, system headers/libraries, and the upstream Git checkout metadata remain external prerequisites. The manifest preserves their recorded identities where available.

Coverage completion, strict fixture verdicts, and infrastructure health are separate. Unsupported Bun execution, compile failures, crashes, timeouts, and incomplete progress remain evidence, not passes. These correctness observations do not establish a timing comparison.
